package com.rencloud.app.data.local

import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import com.google.gson.Gson
import com.rencloud.app.data.model.RenCloudUser
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SessionManager @Inject constructor(
    @ApplicationContext private val context: Context,
    private val gson: Gson
) {
    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    private val prefs = EncryptedSharedPreferences.create(
        context,
        "rencloud_secure_prefs",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    fun saveUserSession(user: RenCloudUser, token: String) {
        val userJson = gson.toJson(user)
        prefs.edit()
            .putString("user_data", userJson)
            .putString("auth_token", token)
            .apply()
    }

    fun getUser(): RenCloudUser? {
        val userJson = prefs.getString("user_data", null) ?: return null
        return try {
            gson.fromJson(userJson, RenCloudUser::class.java)
        } catch (e: Exception) {
            null
        }
    }

    fun getToken(): String? {
        return prefs.getString("auth_token", null)
    }

    fun clearSession() {
        prefs.edit()
            .remove("user_data")
            .remove("auth_token")
            .apply()
    }
}
