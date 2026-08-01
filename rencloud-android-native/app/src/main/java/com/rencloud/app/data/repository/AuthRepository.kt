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
                val token = jsonRes.get("token")?.asString ?: ""
                sessionManager.saveUserSession(user, token)
                return@withContext AuthResult.Success(user, message)
            } else {
                return@withContext AuthResult.Error(message)
            }
        } catch (e: Exception) {
            Log.e("AuthRepository", "Backend login connection failed: ${e.message}")
            return@withContext AuthResult.Error("Could not connect to RenCloud Auth Gateway. Check network connection.")
        }
    }

    suspend fun register(fullName: String, email: String, password: String): AuthResult = withContext(Dispatchers.IO) {
        val cleanEmail = email.trim().lowercase()
        val cleanPass = password.trim()

        if (cleanEmail.isEmpty() || !cleanEmail.contains("@")) {
            return@withContext AuthResult.Error("Please enter a valid email address.")
        }
        if (cleanPass.length < 6) {
            return@withContext AuthResult.Error("Password must be at least 6 characters long.")
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
                    role = userObj.get("role")?.asString ?: "client"
                )
                val token = jsonRes.get("token")?.asString ?: ""
                sessionManager.saveUserSession(user, token)
                return@withContext AuthResult.Success(user, message)
            } else {
                return@withContext AuthResult.Error(message)
            }
        } catch (e: Exception) {
            return@withContext AuthResult.Error("Could not connect to RenCloud Auth Gateway. Ensure server is online.")
        }
    }

    suspend fun restoreSession(): RenCloudUser? = withContext(Dispatchers.IO) {
        val savedUser = sessionManager.getUser()
        val token = sessionManager.getToken()

        if (savedUser == null || token.isNullOrEmpty()) {
            return@withContext null
        }

        try {
            val request = Request.Builder()
                .url("$backendUrl/api/auth/me")
                .header("Authorization", "Bearer $token")
                .get()
                .build()

            val response = httpClient.newCall(request).execute()
            if (response.isSuccessful) {
                val rawJson = response.body?.string() ?: ""
                val jsonRes = gson.fromJson(rawJson, JsonObject::class.java)
                if (jsonRes?.get("success")?.asBoolean == true && jsonRes.has("user")) {
                    val userObj = jsonRes.getAsJsonObject("user")
                    val updatedUser = RenCloudUser(
                        id = userObj.get("id")?.asString ?: savedUser.id,
                        fullName = userObj.get("fullName")?.asString ?: savedUser.fullName,
                        email = userObj.get("email")?.asString ?: savedUser.email,
                        role = userObj.get("role")?.asString ?: savedUser.role
                    )
                    sessionManager.saveUserSession(updatedUser, token)
                    return@withContext updatedUser
                }
            }
        } catch (e: Exception) {
            Log.w("AuthRepository", "Session restore network check failed, using cached session: ${e.message}")
        }
        return@withContext savedUser
    }

    fun logout() {
        sessionManager.clearSession()
    }
}
