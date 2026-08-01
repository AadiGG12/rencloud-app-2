package com.rencloud.app.ui.update

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.SystemUpdate
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.rencloud.app.data.remote.GitHubReleaseResponse
import com.rencloud.app.data.remote.UpdateService
import com.rencloud.app.ui.theme.*
import kotlinx.coroutines.launch

import com.rencloud.app.ui.components.glass.GlassDialog

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

    val apkAsset = release.assets?.firstOrNull { it.name.endsWith(".apk") }

    GlassDialog(
        onDismissRequest = onDismiss,
        accentGlow = ElectricCyan
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
                // Header Icon
                Box(
                    modifier = Modifier
                        .size(60.dp)
                        .clip(CircleShape)
                        .background(MetallicPurple.copy(alpha = 0.2f)),
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
                    text = "New Update Available!",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Black,
                    color = Color.White
                )

                Surface(
                    color = ElectricCyan.copy(alpha = 0.15f),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Text(
                        text = "Version ${release.tagName}",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = ElectricCyan,
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                    )
                }

                Text(
                    text = release.body.take(200) + if (release.body.length > 200) "..." else "",
                    fontSize = 12.sp,
                    color = TextSecondaryDark,
                    lineHeight = 16.sp
                )

                if (isDownloading) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(6.dp),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        LinearProgressIndicator(
                            progress = { downloadProgress },
                            modifier = Modifier.fillMaxWidth().height(8.dp).clip(RoundedCornerShape(4.dp)),
                            color = ElectricCyan,
                            trackColor = MetallicBorderDark
                        )
                        Text(
                            text = "Downloading update... ${(downloadProgress * 100).toInt()}%",
                            fontSize = 11.sp,
                            color = ElectricCyan
                        )
                    }
                } else {
                    Button(
                        onClick = {
                            apkAsset?.let { asset ->
                                isDownloading = true
                                scope.launch {
                                    updateService.downloadAndInstallApk(context, asset.downloadUrl) { prog ->
                                        downloadProgress = prog
                                    }
                                }
                            }
                        },
                        enabled = apkAsset != null,
                        colors = ButtonDefaults.buttonColors(containerColor = MetallicPurple),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.fillMaxWidth().height(48.dp)
                    ) {
                        Text(
                            text = "UPDATE & INSTALL NOW",
                            fontWeight = FontWeight.Bold,
                            color = Color.White,
                            fontSize = 13.sp
                        )
                    }

                    TextButton(onClick = onDismiss) {
                        Text("Remind Me Later", color = TextSecondaryDark, fontSize = 12.sp)
                    }
                }
            }
        }
}
