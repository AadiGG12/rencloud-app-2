package com.rencloud.app.ui.components

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.R
import com.rencloud.app.ui.theme.*
import kotlin.math.cos
import kotlin.math.sin

data class BoomMenuItem(
    val id: String,
    val title: String,
    val subtitle: String,
    val icon: ImageVector,
    val color: Color
)

@Composable
fun BoomMenu(
    items: List<BoomMenuItem>,
    onItemClick: (BoomMenuItem) -> Unit,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }

    val rotationAngle by animateFloatAsState(
        targetValue = if (expanded) 135f else 0f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessMedium
        ),
        label = "fab_rotation"
    )

    val scaleAnim by animateFloatAsState(
        targetValue = if (expanded) 1.1f else 1.0f,
        animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy),
        label = "fab_scale"
    )

    Box(
        modifier = modifier,
        contentAlignment = Alignment.BottomEnd
    ) {
        // Scrim background overlay when expanded
        if (expanded) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.65f))
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null
                    ) { expanded = false }
            )
        }

        // Expanded Boom items (Radial / Vertical explosion)
        Column(
            horizontalAlignment = Alignment.End,
            verticalArrangement = Arrangement.spacedBy(14.dp),
            modifier = Modifier.padding(bottom = 76.dp, end = 4.dp)
        ) {
            items.forEachIndexed { index, item ->
                val delayMs = if (expanded) index * 50 else (items.size - 1 - index) * 30
                
                AnimatedVisibility(
                    visible = expanded,
                    enter = fadeIn(tween(250, delayMillis = delayMs)) +
                            scaleIn(
                                initialScale = 0.3f,
                                animationSpec = spring(
                                    dampingRatio = Spring.DampingRatioMediumBouncy,
                                    stiffness = Spring.StiffnessLow
                                )
                            ) +
                            slideInVertically(
                                initialOffsetY = { it / 2 },
                                animationSpec = tween(300, delayMillis = delayMs)
                            ),
                    exit = fadeOut(tween(150, delayMillis = delayMs)) +
                            scaleOut(targetScale = 0.3f) +
                            slideOutVertically(
                                targetOffsetY = { it / 2 },
                                animationSpec = tween(150, delayMillis = delayMs)
                            )
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(10.dp),
                        modifier = Modifier.clickable {
                            expanded = false
                            onItemClick(item)
                        }
                    ) {
                        // Title Pill
                        Surface(
                            color = RenCloudCardDark.copy(alpha = 0.95f),
                            shape = RoundedCornerShape(12.dp),
                            border = androidx.compose.foundation.BorderStroke(1.dp, item.color.copy(alpha = 0.5f)),
                            shadowElevation = 6.dp
                        ) {
                            Column(
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                                horizontalAlignment = Alignment.End
                            ) {
                                Text(
                                    text = item.title,
                                    color = Color.White,
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.Bold
                                )
                                Text(
                                    text = item.subtitle,
                                    color = item.color,
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.Medium
                                )
                            }
                        }

                        // Circular Icon Button
                        Box(
                            modifier = Modifier
                                .size(50.dp)
                                .clip(CircleShape)
                                .background(
                                    Brush.linearGradient(
                                        listOf(
                                            item.color,
                                            item.color.copy(alpha = 0.7f)
                                        )
                                    )
                                )
                                .border(1.5.dp, Color.White.copy(alpha = 0.6f), CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = item.icon,
                                contentDescription = item.title,
                                tint = Color.White,
                                modifier = Modifier.size(24.dp)
                            )
                        }
                    }
                }
            }
        }

        // Main Trigger Boom Floating Action Button
        Box(
            modifier = Modifier
                .scale(scaleAnim)
                .size(64.dp)
                .clip(CircleShape)
                .background(
                    Brush.sweepGradient(
                        listOf(
                            RenCloudCyan,
                            RenCloudPurple,
                            RenCloudGold,
                            RenCloudCyan
                        )
                    )
                )
                .clickable { expanded = !expanded }
                .border(2.dp, Color.White.copy(alpha = 0.8f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            // Pulse glow background
            Box(
                modifier = Modifier
                    .size(64.dp)
                    .blur(16.dp)
                    .background(RenCloudCyan.copy(alpha = 0.4f), CircleShape)
            )

            // Inner icon (Plus / Close transition)
            Icon(
                imageVector = Icons.Default.Add,
                contentDescription = "Boom Menu",
                tint = Color.White,
                modifier = Modifier
                    .size(32.dp)
                    .rotate(rotationAngle)
            )
        }
    }
}
