package com.rencloud.app.data.remote

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import com.google.gson.annotations.SerializedName
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
    @SerializedName("assets") val assets: List<GitHubAsset>?
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

@Singleton
class UpdateService @Inject constructor() {

    private val api: GitHubUpdateApi by lazy {
        Retrofit.Builder()
            .baseUrl("https://api.github.com/")
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(GitHubUpdateApi::class.java)
    }

    suspend fun checkForUpdates(currentVersion: String): GitHubReleaseResponse? {
        return withContext(Dispatchers.IO) {
            try {
                val resp = api.getLatestRelease()
                if (resp.isSuccessful) {
                    val release = resp.body()
                    if (release != null && isNewerVersion(currentVersion, release.tagName)) {
                        return@withContext release
                    }
                }
                null
            } catch (e: Exception) {
                null
            }
        }
    }

    private fun isNewerVersion(current: String, latestTag: String): Boolean {
        val latest = latestTag.removePrefix("v").trim()
        val curr = current.removePrefix("v").trim()
        return latest != curr
    }

    suspend fun downloadAndInstallApk(context: Context, downloadUrl: String, onProgress: (Float) -> Unit): Boolean {
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

                val data = ByteArray(4096)
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

                // Install APK
                withContext(Dispatchers.Main) {
                    installApk(context, apkFile)
                }
                true
            } catch (e: Exception) {
                false
            }
        }
    }

    private fun installApk(context: Context, file: File) {
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
