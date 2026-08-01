package com.rencloud.app.ui.components

import androidx.compose.animation.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.NotificationsActive
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.ui.components.glass.GlassSurface
import com.rencloud.app.ui.theme.*

data class AnnouncementItem(
    val id: String,
    val message: String,
    val style: String = "info",
    val isDismissible: Boolean = true
)

@Composable
fun AnnouncementBanner(
    announcements: List<AnnouncementItem>,
    modifier: Modifier = Modifier
) {
    var dismissedIds by remember { mutableStateOf(setOf<String>()) }
    val activeAnnouncements = announcements.filter { !dismissedIds.contains(it.id) }

    if (activeAnnouncements.isNotEmpty()) {
        Column(
            modifier = modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 6.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            activeAnnouncements.forEach { ann ->
                val accentColor = when (ann.style.lowercase()) {
                    "warning" -> RenCloudGold
                    "success" -> RenCloudGreen
                    else -> ElectricCyan
                }
                val icon = when (ann.style.lowercase()) {
                    "warning" -> Icons.Default.Warning
                    "success" -> Icons.Default.NotificationsActive
                    else -> Icons.Default.Info
                }

                GlassSurface(
                    shape = RoundedCornerShape(14.dp),
                    borderColor = accentColor,
                    accentGlow = accentColor,
                    alpha = 0.85f,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 14.dp, vertical = 10.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Icon(
                            imageVector = icon,
                            contentDescription = null,
                            tint = accentColor,
                            modifier = Modifier.size(20.dp)
                        )

                        Text(
                            text = ann.message,
                            color = Color.White,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.SemiBold,
                            modifier = Modifier.weight(1f)
                        )

                        if (ann.isDismissible) {
                            IconButton(
                                onClick = { dismissedIds = dismissedIds + ann.id },
                                modifier = Modifier.size(24.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Close,
                                    contentDescription = "Dismiss",
                                    tint = TextSecondaryDark,
                                    modifier = Modifier.size(16.dp)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
