package com.rencloud.app.services

import com.google.gson.annotations.SerializedName
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET

data class ReleaseAsset(
    val name: String,
    @SerializedName("browser_download_url") val downloadUrl: String
)

data class GitHubRelease(
    @SerializedName("tag_name") val tagName: String,
    val body: String?,
    val assets: List<ReleaseAsset>?
)

interface GitHubApi {
    @GET("repos/ANSH9BOSS/rencloud-flutter-app/releases/latest")
    suspend fun getLatestRelease(): GitHubRelease
}

object UpdateService {
    // Current installed app version
    const val CURRENT_VERSION = "1.4.0"

    private val api: GitHubApi by lazy {
        Retrofit.Builder()
            .baseUrl("https://api.github.com/")
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(GitHubApi::class.java)
    }

    suspend fun checkForUpdates(): GitHubRelease? {
        return try {
            val release = api.getLatestRelease()
            val latestVersion = release.tagName.replace("v", "").replace("-compose", "").trim()
            if (isNewerVersion(latestVersion, CURRENT_VERSION)) {
                release
            } else {
                null
            }
        } catch (e: Exception) {
            null
        }
    }

    fun isNewerVersion(latest: String, current: String): Boolean {
        if (latest.isEmpty()) return false
        val latestParts = latest.split(".").mapNotNull { it.toIntOrNull() }
        val currentParts = current.split(".").mapNotNull { it.toIntOrNull() }

        for (i in 0 until minOf(latestParts.size, currentParts.size)) {
            if (latestParts[i] > currentParts[i]) return true
            if (latestParts[i] < currentParts[i]) return false
        }
        return latestParts.size > currentParts.size
    }
}
