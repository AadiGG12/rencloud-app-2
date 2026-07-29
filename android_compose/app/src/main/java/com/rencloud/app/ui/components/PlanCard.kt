package com.rencloud.app.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Dns
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material.icons.filled.SdCard
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.data.AppCurrency
import com.rencloud.app.data.BillingCycle
import com.rencloud.app.data.RenCloudPlan

@Composable
fun PlanCard(
    plan: RenCloudPlan,
    billingCycle: BillingCycle,
    currency: AppCurrency,
    onDeployClick: (RenCloudPlan) -> Unit
) {
    val priceInr = plan.getPriceForCycle(billingCycle)
    val formattedPrice = currency.format(priceInr)
    val colorScheme = MaterialTheme.colorScheme

    // Pulsing Neon Glow Animation for Popular Plans
    val infiniteTransition = rememberInfiniteTransition(label = "glow")
    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.4f,
        targetValue = 1.0f,
        animationSpec = infiniteRepeatable(
            animation = tween(1400, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "glowAlpha"
    )

    // Button Press Animation
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val buttonScale by animateFloatAsState(
        targetValue = if (isPressed) 0.95f else 1.0f,
        animationSpec = spring(stiffness = Spring.StiffnessMedium),
        label = "scale"
    )

    val borderBrush = if (plan.isPopular) {
        Brush.linearGradient(
            listOf(
                colorScheme.primary.copy(alpha = glowAlpha),
                colorScheme.secondary.copy(alpha = glowAlpha),
                colorScheme.primary.copy(alpha = glowAlpha)
            )
        )
    } else {
        Brush.linearGradient(
            listOf(
                colorScheme.outlineVariant.copy(alpha = 0.6f),
                colorScheme.outlineVariant.copy(alpha = 0.2f)
            )
        )
    }

    GlassCard(
        borderGlow = borderBrush,
        modifier = Modifier.fillMaxWidth()
    ) {
        Box {
            Column {
                // Category & Tier Badge Row
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Surface(
                        shape = RoundedCornerShape(14.dp),
                        color = colorScheme.secondary.copy(alpha = 0.12f),
                        border = androidx.compose.foundation.BorderStroke(1.dp, colorScheme.secondary.copy(alpha = 0.35f))
                    ) {
                        Text(
                            text = plan.categoryName.uppercase(),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = colorScheme.secondary,
                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                        )
                    }

                    plan.tierType?.let { tier ->
                        Spacer(modifier = Modifier.width(6.dp))
                        Surface(
                            shape = RoundedCornerShape(14.dp),
                            color = colorScheme.primary.copy(alpha = 0.15f)
                        ) {
                            Text(
                                text = tier,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Bold,
                                color = colorScheme.primary,
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(10.dp))

                // Plan Name
                Text(
                    text = plan.name,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = colorScheme.onSurface
                )

                Spacer(modifier = Modifier.height(10.dp))

                // Price Section
                Row(verticalAlignment = Alignment.Bottom) {
                    Text(
                        text = formattedPrice,
                        fontSize = 28.sp,
                        fontWeight = FontWeight.Black,
                        color = colorScheme.primary
                    )
                    Text(
                        text = if (plan.isOneTime) " one-time" else if (billingCycle == BillingCycle.ANNUAL) "/mo (yearly)" else "/mo",
                        fontSize = 11.sp,
                        color = colorScheme.onSurface.copy(alpha = 0.6f),
                        modifier = Modifier.padding(bottom = 4.dp, start = 4.dp)
                    )
                }

                Spacer(modifier = Modifier.height(10.dp))
                HorizontalDivider(color = colorScheme.outlineVariant.copy(alpha = 0.4f), thickness = 1.dp)
                Spacer(modifier = Modifier.height(12.dp))

                // Spec Rows
                SpecRow(icon = Icons.Default.Memory, label = "RAM Memory", value = plan.ram)
                SpecRow(icon = Icons.Default.SdCard, label = "NVMe Storage", value = plan.nvmeStorage)
                SpecRow(icon = Icons.Default.Speed, label = "vCPU Cores", value = plan.cpu)

                plan.databases?.let { dbs ->
                    SpecRow(icon = Icons.Default.Dns, label = "Databases", value = "$dbs Included")
                }

                plan.extraInfo?.let { info ->
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "✨ $info",
                        fontSize = 11.sp,
                        color = colorScheme.secondary,
                        fontWeight = FontWeight.SemiBold
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Deploy Button with Press Animation
                Button(
                    onClick = { onDeployClick(plan) },
                    interactionSource = interactionSource,
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = if (plan.isPopular) colorScheme.primary else colorScheme.secondary
                    ),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(44.dp)
                        .scale(buttonScale)
                ) {
                    Text(
                        text = if (plan.isOneTime) "Order Service" else "Deploy Server",
                        fontWeight = FontWeight.ExtraBold,
                        fontSize = 14.sp,
                        color = Color.White
                    )
                }
            }

            // Popular Sparkle Badge
            if (plan.isPopular) {
                Surface(
                    shape = RoundedCornerShape(bottomStart = 8.dp, bottomEnd = 8.dp),
                    color = colorScheme.secondary,
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.AutoAwesome,
                            contentDescription = null,
                            tint = Color.White,
                            modifier = Modifier.size(11.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = "POPULAR",
                            fontSize = 9.sp,
                            fontWeight = FontWeight.Black,
                            color = Color.White
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun SpecRow(icon: ImageVector, label: String, value: String) {
    val colorScheme = MaterialTheme.colorScheme
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.padding(bottom = 6.dp)
    ) {
        Surface(
            shape = RoundedCornerShape(6.dp),
            color = colorScheme.primary.copy(alpha = 0.12f),
            modifier = Modifier.size(22.dp)
        ) {
            Box(contentAlignment = Alignment.Center) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = colorScheme.primary,
                    modifier = Modifier.size(13.dp)
                )
            }
        }
        Spacer(modifier = Modifier.width(8.dp))
        Text(text = "$label: ", fontSize = 11.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))
        Text(text = value, fontSize = 12.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
    }
}
