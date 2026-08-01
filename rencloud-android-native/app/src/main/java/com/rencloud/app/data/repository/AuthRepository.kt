package com.rencloud.app.data.repository

import android.util.Log
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.rencloud.app.data.local.SessionManager
import com.rencloud.app.data.model.RenCloudUser
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton

sealed class AuthResult {
    data class Success(val user: RenCloudUser, val message: String) : AuthResult()
    data class Error(val message: String) : AuthResult()
}

@Singleton
class AuthRepository @Inject constructor(
    private val sessionManager: SessionManager,
    private val gson: Gson
) {
    // Connection Flow: Frontend (Android) -> Custom Backend Gateway -> Pterodactyl Panel
    private val backendUrl = "https://api.rencloud.online"

    private val httpClient = OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(15, TimeUnit.SECONDS)
        .build()

    suspend fun login(emailInput: String, passwordInput: String): AuthResult = withContext(Dispatchers.IO) {
        val cleanEmail = emailInput.trim().lowercase()
        val cleanPass = passwordInput.trim()

        if (cleanEmail.isEmpty()) {
            return@withContext AuthResult.Error("Please enter your email or username.")
        }
        if (cleanPass.isEmpty()) {
            return@withContext AuthResult.Error("Please enter your password.")
        }

        try {
            val jsonBody = JsonObject().apply {
                addProperty("email", cleanEmail)
                addProperty("password", cleanPass)
            }.toString()

            val request = Request.Builder()
                .url("$backendUrl/api/auth/login")
                .post(jsonBody.toRequestBody("application/json".toMediaType()))
                .build()

            val response = httpClient.newCall(request).execute()
            val rawJson = response.body?.string() ?: ""
            val jsonRes = gson.fromJson(rawJson, JsonObject::class.java)

            val success = jsonRes?.get("success")?.asBoolean ?: false
            val message = jsonRes?.get("message")?.asString ?: "Authentication failed."

            if (success && jsonRes != null && jsonRes.has("user")) {
                val userObj = jsonRes.getAsJsonObject("user")
                val user = RenCloudUser(
                    id = userObj.get("id")?.asString ?: "1",
                    fullName = userObj.get("fullName")?.asString ?: "RenCloud User",
                    email = userObj.get("email")?.asString ?: cleanEmail,
                    role = userObj.get("role")?.asString ?: "client"
                )
                val token = jsonRes.get("token")?.asString ?: "jwt_token"
                sessionManager.saveUserSession(user, token)
                return@withContext AuthResult.Success(user, message)
            } else {
                return@withContext AuthResult.Error(message)
            }
        } catch (e: Exception) {
            Log.e("AuthRepository", "Backend login connection failed: ${e.message}")
            
            // Fallback for Admin when backend is offline
            if (cleanEmail == "anshkumar19zx@gmail.com" || cleanEmail == "ansh") {
                if (cleanPass == "ANSHGAUR123" || cleanPass == "anshgaur") {
                    val adminUser = RenCloudUser("1", "Ansh Gaur", "anshkumar19zx@gmail.com", "admin")
                    sessionManager.saveUserSession(adminUser, "token_admin")
                    return@withContext AuthResult.Success(adminUser, "Welcome Super Admin!")
                } else {
                    return@withContext AuthResult.Error("Invalid credentials! The password you entered is incorrect for \"$cleanEmail\".")
                }
            }
            return@withContext AuthResult.Error("Could not connect to RenCloud Backend Gateway. Ensure server is online.")
        }
    }

    suspend fun register(fullName: String, email: String, password: String): AuthResult = withContext(Dispatchers.IO) {
        val cleanEmail = email.trim().lowercase()
        val cleanPass = password.trim()

        if (cleanEmail.isEmpty() || !cleanEmail.contains("@")) {
            return@withContext AuthResult.Error("Please enter a valid email address.")
        }

        try {
            val jsonBody = JsonObject().apply {
                addProperty("fullName", fullName)
                addProperty("email", cleanEmail)
                addProperty("password", cleanPass)
            }.toString()

            val request = Request.Builder()
                .url("$backendUrl/api/auth/register")
                .post(jsonBody.toRequestBody("application/json".toMediaType()))
                .build()

            val response = httpClient.newCall(request).execute()
            val rawJson = response.body?.string() ?: ""
            val jsonRes = gson.fromJson(rawJson, JsonObject::class.java)

            val success = jsonRes?.get("success")?.asBoolean ?: false
            val message = jsonRes?.get("message")?.asString ?: "Registration failed."

            if (success && jsonRes != null && jsonRes.has("user")) {
                val userObj = jsonRes.getAsJsonObject("user")
                val user = RenCloudUser(
                    id = userObj.get("id")?.asString ?: "1",
                    fullName = userObj.get("fullName")?.asString ?: fullName,
                    email = userObj.get("email")?.asString ?: cleanEmail,
                    role = "client"
                )
                val token = jsonRes.get("token")?.asString ?: "jwt_token"
                sessionManager.saveUserSession(user, token)
                return@withContext AuthResult.Success(user, message)
            } else {
                return@withContext AuthResult.Error(message)
            }
        } catch (e: Exception) {
            return@withContext AuthResult.Error("Could not connect to RenCloud Backend Gateway.")
        }
    }

    suspend fun restoreSession(): RenCloudUser? = withContext(Dispatchers.IO) {
        return@withContext sessionManager.getUser()
    }

    fun logout() {
        sessionManager.clearSession()
    }
}
