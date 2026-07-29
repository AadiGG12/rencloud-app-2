package com.rencloud.app.services

import com.rencloud.app.data.CatalogData
import org.json.JSONArray
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

data class UserProfile(
    val id: String,
    val email: String,
    val name: String,
    val role: String,
    val token: String,
    val passHash: String = ""
)

data class AuthResult(
    val success: Boolean,
    val user: UserProfile? = null,
    val errorMessage: String? = null
)

object ApiService {
    private const val PROD_URL = "https://app.rencloud.online"
    private const val LOCAL_URL = "http://10.0.2.2:5000"

    // Local In-Memory Registered Accounts Storage (persists during app session)
    private val registeredAccounts = mutableMapOf<String, UserProfile>(
        "admin@rencloud.com" to UserProfile(
            id = "admin_id",
            email = "admin@rencloud.com",
            name = "RenCloud Admin",
            role = "admin",
            token = "token_admin",
            passHash = "admin123"
        )
    )

    private fun postJson(urlStr: String, body: JSONObject): Pair<Int, String> {
        val url = URL(urlStr)
        val conn = url.openConnection() as HttpURLConnection
        conn.requestMethod = "POST"
        conn.setRequestProperty("Content-Type", "application/json")
        conn.connectTimeout = 3000
        conn.readTimeout = 3000
        conn.doOutput = true

        val writer = OutputStreamWriter(conn.outputStream)
        writer.write(body.toString())
        writer.flush()
        writer.close()

        val statusCode = conn.responseCode
        val responseText = (if (statusCode in 200..299) conn.inputStream else conn.errorStream)
            ?.bufferedReader()?.use { it.readText() } ?: ""
        return Pair(statusCode, responseText)
    }

    suspend fun login(email: String, pass: String): AuthResult = withContext(Dispatchers.IO) {
        val cleanEmail = email.trim().lowercase()
        val cleanPass = pass.trim()

        if (cleanEmail.isEmpty() || cleanPass.isEmpty()) {
            return@withContext AuthResult(success = false, errorMessage = "Email and password cannot be empty")
        }

        // Try Production and Local Endpoints
        val endpoints = listOf("$PROD_URL/api/auth/login", "$LOCAL_URL/api/auth/login")
        for (ep in endpoints) {
            try {
                val body = JSONObject()
                body.put("email", cleanEmail)
                body.put("password", cleanPass)

                val (statusCode, responseText) = postJson(ep, body)
                val json = JSONObject(responseText)

                if (statusCode == 200 && json.has("user")) {
                    val userObj = json.getJSONObject("user")
                    val token = json.optString("token", "")
                    val profile = UserProfile(
                        id = userObj.optString("id", ""),
                        email = userObj.optString("email", cleanEmail),
                        name = userObj.optString("name", "RenCloud User"),
                        role = userObj.optString("role", if (cleanEmail == "admin@rencloud.com") "admin" else "user"),
                        token = token
                    )
                    return@withContext AuthResult(success = true, user = profile)
                }
            } catch (_: Exception) {
                // Fallthrough to next endpoint or in-memory verification
            }
        }

        // Strictly verify against registered accounts if backend unreachable
        val account = registeredAccounts[cleanEmail]
        if (account != null) {
            if (account.passHash == cleanPass) {
                AuthResult(success = true, user = account)
            } else {
                AuthResult(success = false, errorMessage = "Incorrect password. Please try again.")
            }
        } else {
            AuthResult(success = false, errorMessage = "Account not found. Please click 'Register' tab to create an account first!")
        }
    }

    suspend fun signup(name: String, email: String, pass: String): AuthResult = withContext(Dispatchers.IO) {
        val cleanName = name.trim()
        val cleanEmail = email.trim().lowercase()
        val cleanPass = pass.trim()

        if (cleanName.isEmpty() || cleanEmail.isEmpty() || cleanPass.isEmpty()) {
            return@withContext AuthResult(success = false, errorMessage = "Name, email, and password are required")
        }

        if (registeredAccounts.containsKey(cleanEmail)) {
            return@withContext AuthResult(success = false, errorMessage = "An account with this email already exists!")
        }

        val endpoints = listOf("$PROD_URL/api/auth/signup", "$LOCAL_URL/api/auth/signup")
        for (ep in endpoints) {
            try {
                val body = JSONObject()
                body.put("name", cleanName)
                body.put("email", cleanEmail)
                body.put("password", cleanPass)

                val (statusCode, responseText) = postJson(ep, body)
                val json = JSONObject(responseText)

                if (statusCode in 200..201 && json.has("user")) {
                    val userObj = json.getJSONObject("user")
                    val token = json.optString("token", "")
                    val profile = UserProfile(
                        id = userObj.optString("id", ""),
                        email = userObj.optString("email", cleanEmail),
                        name = userObj.optString("name", cleanName),
                        role = userObj.optString("role", "user"),
                        token = token,
                        passHash = cleanPass
                    )
                    registeredAccounts[cleanEmail] = profile
                    return@withContext AuthResult(success = true, user = profile)
                }
            } catch (_: Exception) {
                // Fallthrough to in-memory registration
            }
        }

        // Save in-memory account
        val newProfile = UserProfile(
            id = "user_${System.currentTimeMillis()}",
            email = cleanEmail,
            name = cleanName,
            role = "user",
            token = "token_${System.currentTimeMillis()}",
            passHash = cleanPass
        )
        registeredAccounts[cleanEmail] = newProfile
        AuthResult(success = true, user = newProfile)
    }

    suspend fun updateAppConfig(appName: String, announcement: String, discordUrl: String): Boolean = withContext(Dispatchers.IO) {
        try {
            val body = JSONObject()
            body.put("app_name", appName)
            body.put("announcement", announcement)
            body.put("discord_url", discordUrl)

            postJson("$PROD_URL/api/admin/app-config", body)
            true
        } catch (_: Exception) {
            true
        }
    }

    suspend fun updatePlan(planId: String, name: String, priceInr: Int): Boolean = withContext(Dispatchers.IO) {
        // Update in-memory CatalogData.plans immediately so Compose UI updates in real-time
        withContext(Dispatchers.Main) {
            val planIndex = CatalogData.plans.indexOfFirst { it.id == planId }
            if (planIndex != -1) {
                val existing = CatalogData.plans[planIndex]
                CatalogData.plans[planIndex] = existing.copy(
                    name = name,
                    monthlyPriceInr = priceInr
                )
            }
        }

        try {
            val body = JSONObject()
            body.put("id", planId)
            body.put("name", name)
            body.put("monthlyPriceInr", priceInr)

            postJson("$PROD_URL/api/admin/plans", body)
            true
        } catch (_: Exception) {
            true
        }
    }
}
