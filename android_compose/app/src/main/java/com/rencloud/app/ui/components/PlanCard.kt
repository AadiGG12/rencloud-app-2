package com.rencloud.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Dns
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material.icons.filled.SdCard
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
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

    val borderBrush = if (plan.isPopular) {
        Brush.linearGradient(listOf(colorScheme.primary, colorScheme.secondary))
    } else {
        Brush.linearGradient(listOf(colorScheme.outlineVariant, colorScheme.outlineVariant.copy(alpha = 0.5f)))
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .background(borderBrush)
            .padding(1.8.dp)
    ) {
        Card(
            shape = RoundedCornerShape(18.dp),
            colors = CardDefaults.cardColors(containerColor = colorScheme.surface),
            modifier = Modifier.fillMaxWidth()
        ) {
            Box {
                Column(
                    modifier = Modifier.padding(18.dp)
                ) {
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
                        fontSize = 19.sp,
                        fontWeight = FontWeight.Bold,
                        color = colorScheme.onSurface
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    // Price Section
                    Row(verticalAlignment = Alignment.Bottom) {
                        Text(
                            text = formattedPrice,
                            fontSize = 26.sp,
                            fontWeight = FontWeight.Black,
                            color = colorScheme.primary
                        )
                        Text(
                            text = if (plan.isOneTime) " one-time" else if (billingCycle == BillingCycle.ANNUAL) "/mo (yearly)" else "/mo",
                            fontSize = 11.sp,
                            color = colorScheme.onSurface.copy(alpha = 0.6f),
                            modifier = Modifier.padding(bottom = 3.dp, start = 4.dp)
                        )
                    }

                    Spacer(modifier = Modifier.height(10.dp))
                    HorizontalDivider(color = colorScheme.outlineVariant, thickness = 1.dp)
                    Spacer(modifier = Modifier.height(12.dp))

                    // Spec Rows
                    SpecRow(icon = Icons.Default.Memory, label = "RAM", value = plan.ram)
                    SpecRow(icon = Icons.Default.SdCard, label = "Storage", value = plan.nvmeStorage)
                    SpecRow(icon = Icons.Default.Speed, label = "CPU", value = plan.cpu)

                    plan.databases?.let { dbs ->
                        SpecRow(icon = Icons.Default.Dns, label = "Databases", value = "$dbs Included")
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Deploy Button
                    Button(
                        onClick = { onDeployClick(plan) },
                        shape = RoundedCornerShape(12.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = if (plan.isPopular) colorScheme.primary else colorScheme.secondary
                        ),
                        modifier = Modifier.fillMaxWidth().height(44.dp)
                    ) {
                        Text(
                            text = if (plan.isOneTime) "Order Plan" else "Deploy Server",
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp,
                            color = Color.White
                        )
                    }
                }

                // Popular Badge
                if (plan.isPopular) {
                    Surface(
                        shape = RoundedCornerShape(bottomStart = 8.dp, bottomEnd = 8.dp),
                        color = colorScheme.secondary,
                        modifier = Modifier.align(Alignment.TopEnd).padding(end = 18.dp)
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
            color = colorScheme.primary.copy(alpha = 0.1f),
            modifier = Modifier.size(22.dp)
        ) {
            Box(contentAlignment = Alignment.Center) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = colorScheme.primary,
                    modifier = Modifier.size(14.dp)
                )
            }
        }
        Spacer(modifier = Modifier.width(8.dp))
        Text(text = "$label: ", fontSize = 11.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))
        Text(text = value, fontSize = 12.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
    }
}
