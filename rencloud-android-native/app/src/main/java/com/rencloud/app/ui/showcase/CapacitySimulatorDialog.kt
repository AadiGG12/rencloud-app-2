package com.rencloud.app.ui.showcase

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.RocketLaunch
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.rencloud.app.data.model.RenCloudPlan
import com.rencloud.app.data.repository.CatalogRepository
import com.rencloud.app.ui.theme.*
import kotlin.math.abs

@Composable
fun CapacitySimulatorDialog(
    catalogRepository: CatalogRepository = CatalogRepository(),
    onDismiss: () -> Unit,
    onDeployPlan: (RenCloudPlan) -> Unit = {}
) {
    val allPlans = remember { catalogRepository.getPlans() }

    var playerCount by remember { mutableFloatStateOf(30f) }
    var modCount by remember { mutableFloatStateOf(15f) }

    val requiredRamGb = (playerCount * 0.15f + modCount * 0.25f + 1.5f).toInt().coerceIn(2, 128)
    val requiredCpuCores = (playerCount * 0.05f + modCount * 0.08f + 1f).toInt().coerceIn(1, 16)

    val recommendedPlan = remember(requiredRamGb, requiredCpuCores) {
        val suitable = allPlans.filter { plan ->
            val planRamGb = plan.ram.split(" ").firstOrNull()?.toIntOrNull() ?: 4
            planRamGb >= requiredRamGb
        }
        suitable.minByOrNull { plan ->
            val planRamGb = plan.ram.split(" ").firstOrNull()?.toIntOrNull() ?: 4
            abs(planRamGb - requiredRamGb)
        } ?: allPlans.first()
    }

    Dialog(onDismissRequest = onDismiss) {
        Surface(
            modifier = Modifier.fillMaxWidth(),
            color = RenCloudCardDark,
            shape = RoundedCornerShape(24.dp),
            border = BorderStroke(1.5.dp, Brush.linearGradient(listOf(MetallicPurple, ElectricCyan)))
        ) {
            Column(
                modifier = Modifier.padding(20.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Capacity Simulator", fontSize = 18.sp, fontWeight = FontWeight.Black, color = Color.White)
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, contentDescription = "Close", tint = TextSecondaryDark)
                    }
                }

                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text("Estimated Online Players: ${playerCount.toInt()}", color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    Slider(
                        value = playerCount,
                        onValueChange = { playerCount = it },
                        valueRange = 1f..200f,
                        colors = SliderDefaults.colors(thumbColor = MetallicPurple, activeTrackColor = MetallicPurple)
                    )

                    Text("Active Mods / Plugins: ${modCount.toInt()}", color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    Slider(
                        value = modCount,
                        onValueChange = { modCount = it },
                        valueRange = 0f..100f,
                        colors = SliderDefaults.colors(thumbColor = RenCloudGold, activeTrackColor = RenCloudGold)
                    )
                }

                Surface(
                    color = MetallicNavy,
                    shape = RoundedCornerShape(16.dp),
                    border = BorderStroke(1.dp, MetallicBorderDark),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text("CALCULATED REQUIREMENTS", fontSize = 9.sp, fontWeight = FontWeight.Bold, color = TextMutedDark, letterSpacing = 1.sp)
                        Text("$requiredRamGb GB RAM • $requiredCpuCores vCores", fontSize = 16.sp, fontWeight = FontWeight.Black, color = Color.White)

                        Divider(color = MetallicBorderDark)

                        Text("RECOMMENDED RENCLOUD PLAN", fontSize = 9.sp, fontWeight = FontWeight.Bold, color = TextMutedDark, letterSpacing = 1.sp)
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column {
                                Text(recommendedPlan.name, fontSize = 18.sp, fontWeight = FontWeight.Bold, color = ElectricCyan)
                                Text("${recommendedPlan.categoryName} • ${recommendedPlan.ram}", fontSize = 11.sp, color = TextSecondaryDark)
                            }
                            Text("₹${recommendedPlan.monthlyPriceInr}/mo", fontSize = 18.sp, fontWeight = FontWeight.Black, color = RenCloudGold)
                        }
                    }
                }

                Button(
                    onClick = {
                        onDismiss()
                        onDeployPlan(recommendedPlan)
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = ElectricCyan),
                    shape = RoundedCornerShape(14.dp),
                    modifier = Modifier.fillMaxWidth().height(48.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(Icons.Default.RocketLaunch, contentDescription = null, tint = Color.Black)
                        Text("DEPLOY ${recommendedPlan.name.uppercase()}", color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                    }
                }
            }
        }
    }
}
