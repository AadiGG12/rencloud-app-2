package com.rencloud.app.data.remote

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.content.FileProvider
import com.google.gson.annotations.SerializedName
import com.rencloud.app.BuildConfig
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import java.io.File
import java.io.FileOutputStream
import java.net.URL
import javax.inject.Inject
import javax.inject.Singleton

data class GitHubReleaseResponse(
    @SerializedName("tag_name") val tagName: String,
    @SerializedName("name") val name: String,
    @SerializedName("body") val body: String,
    @SerializedName("html_url") val htmlUrl: String,
    @SerializedName("assets") val assets: List<GitHubAsset>?,
    var isMandatoryFromBackend: Boolean = false,
    var customChangelogFromBackend: String? = null
)

data class GitHubAsset(
    @SerializedName("name") val name: String,
    @SerializedName("browser_download_url") val downloadUrl: String,
    @SerializedName("size") val size: Long
)

interface GitHubUpdateApi {
    @GET("repos/AadiGG12/rencloud-app-2/releases/latest")
    suspend fun getLatestRelease(): Response<GitHubReleaseResponse>
}

interface ReleaseNotesBackendApi {
    @GET("api/release-notes/latest")
    suspend fun getLatestBackendReleaseNotes(): Response<Map<String, Any>>
}

@Singleton
class UpdateService @Inject constructor() {

    private val api: GitHubUpdateApi by lazy {
        Retrofit.Builder()
            .baseUrl("https://api.github.com/")
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(GitHubUpdateApi::class.java)
    }

    private val notesApi: ReleaseNotesBackendApi by lazy {
        Retrofit.Builder()
            .baseUrl("https://api.rencloud.online/")
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(ReleaseNotesBackendApi::class.java)
    }

    suspend fun checkForUpdates(currentVersionName: String = BuildConfig.VERSION_NAME): GitHubReleaseResponse? {
        return withContext(Dispatchers.IO) {
            try {
                val resp = api.getLatestRelease()
                if (resp.isSuccessful) {
                    val release = resp.body()
                    if (release != null) {
                        val currentCode = parseVersionCode(currentVersionName)
                        val latestCode = parseVersionCode(release.tagName)
                        Log.d("UpdateService", "Comparing current $currentCode (${currentVersionName}) vs latest $latestCode (${release.tagName})")
                        
                        if (latestCode > currentCode) {
                            // Check backend release notes for custom changelog & mandatory flag
                            try {
                                val notesResp = notesApi.getLatestBackendReleaseNotes()
                                if (notesResp.isSuccessful && notesResp.body()?.get("data") != null) {
                                    @Suppress("UNCHECKED_CAST")
                                    val data = notesResp.body()!!["data"] as? Map<String, Any>
                                    if (data != null) {
                                        release.isMandatoryFromBackend = data["is_mandatory"] as? Boolean ?: false
                                        release.customChangelogFromBackend = data["changelog"] as? String
                                    }
                                }
                            } catch (e: Exception) {
                                Log.e("UpdateService", "Backend release notes fetch error: ${e.message}")
                            }

                            return@withContext release
                        }
                    }
                }
                null
            } catch (e: Exception) {
                Log.e("UpdateService", "Update check failed: ${e.message}")
                null
            }
        }
    }

    fun parseVersionCode(versionStr: String): Int {
        val clean = versionStr.removePrefix("v").removePrefix("V").trim()
        val parts = clean.split(".")
        val major = parts.getOrNull(0)?.toIntOrNull() ?: 0
        val minor = parts.getOrNull(1)?.toIntOrNull() ?: 0
        val patch = parts.getOrNull(2)?.toIntOrNull() ?: 0
        return (major * 10000) + (minor * 100) + patch
    }

    suspend fun downloadAndInstallApk(
        context: Context,
        downloadUrl: String,
        onProgress: (Float) -> Unit
    ): Boolean {
        return withContext(Dispatchers.IO) {
            try {
                val url = URL(downloadUrl)
                val connection = url.openConnection()
                connection.connect()
                val fileLength = connection.contentLength

                val apkFile = File(context.cacheDir, "RenCloud-update.apk")
                if (apkFile.exists()) apkFile.delete()

                val input = connection.getInputStream()
                val output = FileOutputStream(apkFile)

                val data = ByteArray(8192)
                var total: Long = 0
                var count: Int

                while (input.read(data).also { count = it } != -1) {
                    total += count.toLong()
                    if (fileLength > 0) {
                        onProgress(total.toFloat() / fileLength.toFloat())
                    }
                    output.write(data, 0, count)
                }

                output.flush()
                output.close()
                input.close()

                withContext(Dispatchers.Main) {
                    installApk(context, apkFile)
                }
                true
            } catch (e: Exception) {
                false
            }
        }
    }

    fun installApk(context: Context, file: File) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (!context.packageManager.canRequestPackageInstalls()) {
                val settingsIntent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                    data = Uri.parse("package:${context.packageName}")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(settingsIntent)
                return
            }
        }

        val apkUri: Uri = FileProvider.getUriForFile(
            context,
            "${context.packageName}.fileprovider",
            file
        )

        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(apkUri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        context.startActivity(intent)
    }
}
