package com.rencloud.app.ui.update

import androidx.compose.animation.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.SystemUpdate
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.BuildConfig
import com.rencloud.app.data.remote.GitHubReleaseResponse
import com.rencloud.app.data.remote.UpdateService
import com.rencloud.app.ui.components.glass.GlassButton
import com.rencloud.app.ui.components.glass.GlassDialog
import com.rencloud.app.ui.theme.*
import kotlinx.coroutines.launch

@Composable
fun UpdateDialog(
    release: GitHubReleaseResponse,
    updateService: UpdateService,
    onDismiss: () -> Unit
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var isDownloading by remember { mutableStateOf(false) }
    var downloadProgress by remember { mutableFloatStateOf(0f) }
    var downloadFailed by remember { mutableStateOf(false) }

    val apkAsset = release.assets?.firstOrNull { it.name.endsWith(".apk") }
    val isMandatory = remember(release) {
        release.name.contains("[MANDATORY]", ignoreCase = true) ||
        release.body.contains("[MANDATORY]", ignoreCase = true)
    }

    GlassDialog(
        onDismissRequest = { if (!isMandatory) onDismiss() },
        accentGlow = ElectricCyan
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(60.dp)
                    .clip(CircleShape)
                    .background(MetallicPurple.copy(alpha = 0.25f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.SystemUpdate,
                    contentDescription = "Update",
                    tint = ElectricCyan,
                    modifier = Modifier.size(32.dp)
                )
            }

            Text(
                text = if (isMandatory) "Mandatory Update Required!" else "New Version Available!",
                fontSize = 20.sp,
                fontWeight = FontWeight.Black,
                color = Color.White
            )

            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Surface(
                    color = MetallicCardDark.copy(alpha = 0.8f),
                    shape = RoundedCornerShape(8.dp),
                    border = BorderStroke(1.dp, MetallicBorderDark)
                ) {
                    Text(
                        text = "Current: v${BuildConfig.VERSION_NAME}",
                        fontSize = 11.sp,
                        color = TextSecondaryDark,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                    )
                }

                Surface(
                    color = ElectricCyan.copy(alpha = 0.15f),
                    shape = RoundedCornerShape(8.dp),
                    border = BorderStroke(1.dp, ElectricCyan)
                ) {
                    Text(
                        text = "Latest: ${release.tagName}",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = ElectricCyan,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                    )
                }
            }

            if (release.body.isNotEmpty()) {
                Surface(
                    color = MetallicCardDark.copy(alpha = 0.5f),
                    shape = RoundedCornerShape(12.dp),
                    border = BorderStroke(0.5.dp, MetallicBorderDark),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = release.body.take(220) + if (release.body.length > 220) "..." else "",
                        fontSize = 11.sp,
                        color = TextSecondaryDark,
                        lineHeight = 15.sp,
                        modifier = Modifier.padding(12.dp)
                    )
                }
            }

            if (downloadFailed) {
                Text(
                    text = "Download failed. Please check network connection.",
                    color = RenCloudRed,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.SemiBold,
                    textAlign = TextAlign.Center
                )
            }

            if (isDownloading) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    LinearProgressIndicator(
                        progress = { downloadProgress },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(8.dp)
                            .clip(RoundedCornerShape(4.dp)),
                        color = ElectricCyan,
                        trackColor = MetallicBorderDark
                    )
                    Text(
                        text = "Downloading APK update... ${(downloadProgress * 100).toInt()}%",
                        fontSize = 11.sp,
                        color = ElectricCyan,
                        fontWeight = FontWeight.Bold
                    )
                }
            } else {
                GlassButton(
                    onClick = {
                        apkAsset?.let { asset ->
                            isDownloading = true
                            downloadFailed = false
                            scope.launch {
                                val success = updateService.downloadAndInstallApk(context, asset.downloadUrl) { prog ->
                                    downloadProgress = prog
                                }
                                if (!success) {
                                    isDownloading = false
                                    downloadFailed = true
                                }
                            }
                        }
                    },
                    enabled = apkAsset != null,
                    containerColor = ElectricCyan,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp)
                ) {
                    Icon(
                        imageVector = if (downloadFailed) Icons.Default.Refresh else Icons.Default.SystemUpdate,
                        contentDescription = null,
                        tint = Color.Black,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(Modifier.width(8.dp))
                    Text(
                        text = if (downloadFailed) "RETRY DOWNLOAD" else "UPDATE & INSTALL NOW",
                        fontWeight = FontWeight.Bold,
                        color = Color.Black,
                        fontSize = 13.sp
                    )
                }

                if (!isMandatory) {
                    TextButton(onClick = onDismiss) {
                        Text("Remind Me Later", color = TextSecondaryDark, fontSize = 12.sp)
                    }
                }
            }
        }
    }
}
