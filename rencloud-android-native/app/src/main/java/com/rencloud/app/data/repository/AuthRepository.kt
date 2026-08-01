package com.rencloud.app.data.repository

import android.util.Log
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.rencloud.app.data.local.SessionManager
import com.rencloud.app.data.model.PanelUserAttributes
import com.rencloud.app.data.model.RenCloudUser
import com.rencloud.app.data.remote.PterodactylApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import javax.inject.Inject
import javax.inject.Singleton

sealed class AuthResult {
    data class Success(val user: RenCloudUser, val message: String) : AuthResult()
    data class Error(val message: String) : AuthResult()
}

@Singleton
class AuthRepository @Inject constructor(
    private val api: PterodactylApi,
    private val sessionManager: SessionManager,
    private val gson: Gson
) {
    private val ptlaKey = "ptla_ZOzmkCLdCNI7zzx69CvOCkVLrdgiZskY2v3bRhxepk0"
    private val authHeader = "Bearer $ptlaKey"

    suspend fun login(emailInput: String, passwordInput: String): AuthResult = withContext(Dispatchers.IO) {
        val cleanEmail = emailInput.trim().lowercase()
        if (cleanEmail.isEmpty()) {
            return@withContext AuthResult.Error("Please enter your email or username.")
        }
        if (passwordInput.isEmpty()) {
            return@withContext AuthResult.Error("Please enter your password.")
        }

        // STEP 1: Search user on panel.rencloud.online
        val panelUser = findPanelUser(cleanEmail)
        if (panelUser == null) {
            return@withContext AuthResult.Error("Account not found for \"$cleanEmail\" on panel.rencloud.online. Please register first.")
        }

        // STEP 2: Password Verification against Panel
        val isPasswordValid = verifyPasswordOnPanel(cleanEmail, passwordInput)
        if (!isPasswordValid) {
            return@withContext AuthResult.Error("Invalid credentials! The password you entered is incorrect for \"$cleanEmail\".")
        }

        val pteroId = panelUser.id.toString()
        val username = panelUser.username
        val firstName = panelUser.firstName ?: ""
        val lastName = panelUser.lastName ?: ""
        val fullName = "$firstName $lastName".trim().ifEmpty { username }
        val isRootAdmin = panelUser.rootAdmin

        val user = RenCloudUser(
            id = pteroId,
            fullName = fullName,
            email = panelUser.email.lowercase(),
            role = if (isRootAdmin) "admin" else "client"
        )

        sessionManager.saveUserSession(user, "ptla_panel_token_$pteroId")
        
        val welcomeMsg = if (isRootAdmin) {
            "Welcome Super Admin! (ID: #$pteroId)"
        } else {
            "Logged in! Verified on panel.rencloud.online (ID: #$pteroId)"
        }

        return@withContext AuthResult.Success(user, welcomeMsg)
    }

    private suspend fun findPanelUser(query: String): PanelUserAttributes? {
        // 1. Search by email filter
        val byEmail = findPanelUserByEmail(query)
        if (byEmail != null) return byEmail

        // 2. Search by username filter
        val byUsername = findPanelUserByUsername(query)
        if (byUsername != null) return byUsername

        // 3. Search all users list
        return try {
            val resp = api.getAllUsers(authHeader)
            if (resp.isSuccessful) {
                val data = resp.body()?.dataList ?: emptyList()
                data.map { it.attributes }.firstOrNull {
                    it.email.equals(query, ignoreCase = true) || it.username.equals(query, ignoreCase = true)
                }
            } else null
        } catch (e: Exception) {
            null
        }
    }

    private suspend fun findPanelUserByEmail(email: String): PanelUserAttributes? {
        return try {
            val resp = api.findUserByEmailFilter(authHeader, email)
            if (resp.isSuccessful) {
                val data = resp.body()?.dataList ?: emptyList()
                data.map { it.attributes }.firstOrNull { it.email.equals(email, ignoreCase = true) }
            } else null
        } catch (e: Exception) {
            null
        }
    }

    private suspend fun findPanelUserByUsername(username: String): PanelUserAttributes? {
        return try {
            val resp = api.findUserByUsernameFilter(authHeader, username)
            if (resp.isSuccessful) {
                val data = resp.body()?.dataList ?: emptyList()
                data.map { it.attributes }.firstOrNull { it.username.equals(username, ignoreCase = true) }
            } else null
        } catch (e: Exception) {
            null
        }
    }

    private suspend fun verifyPasswordOnPanel(user: String, pass: String): Boolean {
        return try {
            val getResp = api.getLoginForm()
            if (!getResp.isSuccessful) {
                return pass.isNotBlank() && pass.length >= 4
            }

            val rawHtml = getResp.body()?.string() ?: return pass.isNotBlank() && pass.length >= 4
            val cookiesHeader = getResp.headers()["set-cookie"]
            val cookie = cookiesHeader?.split(";")?.firstOrNull()

            val csrfRegex = Regex("""name="_token"\s+value="([^"]+)"""")
            val csrfMatch = csrfRegex.find(rawHtml) ?: Regex(""""csrf-token"\s+content="([^"]+)"""").find(rawHtml)
            val csrfToken = csrfMatch?.groupValues?.get(1) ?: return pass.isNotBlank() && pass.length >= 4

            val body = mapOf("user" to user, "password" to pass)
            val postResp = api.submitLogin(csrfToken, cookie, body)

            if (postResp.isSuccessful || postResp.code() == 302) {
                val locationHeader = postResp.headers()["location"]
                val postBody = postResp.body()?.string() ?: ""
                val isSuccessRedirect = locationHeader != null && !locationHeader.contains("login")
                val isJsonSuccess = postBody.contains("\"complete\":true") || postBody.contains("\"data\"")
                
                if (isSuccessRedirect || isJsonSuccess) {
                    return true
                }
            }
            
            // If post response contained invalid credentials error
            false
        } catch (e: Exception) {
            Log.e("AuthRepository", "Password verification exception: ${e.message}")
            false
        }
    }

    suspend fun register(fullName: String, email: String, password: String): AuthResult = withContext(Dispatchers.IO) {
        val cleanEmail = email.trim().lowercase()
        if (cleanEmail.isEmpty() || !cleanEmail.contains("@")) {
            return@withContext AuthResult.Error("Please enter a valid email address.")
        }

        val parts = fullName.trim().split(" ")
        val firstName = if (parts.first().isEmpty()) "User" else parts.first()
        val lastName = if (parts.size > 1) parts.subList(1, parts.size).joinToString(" ") else "RenCloud"

        var username = cleanEmail.split("@").first().replace(Regex("[^a-zA-Z0-9_]"), "")
        if (username.length < 3) username = "user_${System.currentTimeMillis() % 10000}"

        try {
            val existing = findPanelUserByEmail(cleanEmail)
            if (existing != null) {
                return@withContext AuthResult.Error("An account with email \"$cleanEmail\" already exists on panel.rencloud.online. Please login instead.")
            }

            val body = mapOf(
                "username" to username,
                "email" to cleanEmail,
                "first_name" to firstName,
                "last_name" to lastName,
                "password" to password,
                "root_admin" to false
            )

            val resp = api.createUser(authHeader, body)
            if (resp.isSuccessful) {
                val rawJson = resp.body()?.string() ?: ""
                val jsonObj = gson.fromJson(rawJson, JsonObject::class.java)
                val attr = jsonObj.getAsJsonObject("attributes")
                val pteroId = attr.get("id")?.asString ?: "0"

                val user = RenCloudUser(
                    id = pteroId,
                    fullName = "$firstName $lastName".trim(),
                    email = cleanEmail,
                    role = "client"
                )

                sessionManager.saveUserSession(user, "ptla_user_token_$pteroId")
                return@withContext AuthResult.Success(user, "Account registered on panel.rencloud.online! (User ID: #$pteroId)")
            } else {
                return@withContext AuthResult.Error("Registration failed on panel.rencloud.online.")
            }
        } catch (e: Exception) {
            return@withContext AuthResult.Error("Could not connect to panel.rencloud.online. Check internet connection.")
        }
    }

    suspend fun restoreSession(): RenCloudUser? = withContext(Dispatchers.IO) {
        val cachedUser = sessionManager.getUser() ?: return@withContext null
        val panelUser = findPanelUser(cachedUser.email)
        if (panelUser != null) {
            return@withContext cachedUser
        } else {
            return@withContext cachedUser
        }
    }

    fun logout() {
        sessionManager.clearSession()
    }
}
