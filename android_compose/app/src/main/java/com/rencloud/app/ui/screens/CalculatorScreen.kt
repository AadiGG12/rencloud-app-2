package com.rencloud.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.RocketLaunch
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.data.AppCurrency
import com.rencloud.app.data.RenCloudPlan

@Composable
fun CalculatorScreen(
    currency: AppCurrency,
    onDeployClick: (RenCloudPlan) -> Unit
) {
    var vcpuCores by remember { mutableFloatStateOf(4f) }
    var ramGb by remember { mutableFloatStateOf(16f) }
    var storageGb by remember { mutableFloatStateOf(80f) }
    val colorScheme = MaterialTheme.colorScheme

    val estimatedPriceInr = remember(vcpuCores, ramGb, storageGb) {
        (vcpuCores.toInt() * 150) + (ramGb.toInt() * 35) + (storageGb.toInt() * 5)
    }

    val formattedPrice = currency.format(estimatedPriceInr)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(colorScheme.background)
            .padding(16.dp)
            .verticalScroll(rememberScrollState())
    ) {
        Card(
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(containerColor = colorScheme.surface),
            border = androidx.compose.foundation.BorderStroke(1.dp, colorScheme.primary.copy(alpha = 0.3f)),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(20.dp)) {
                Row(
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.Top,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "⚡ Custom Resource Cost Estimator",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold,
                            color = colorScheme.onSurface
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Configure vCPUs, RAM, and NVMe Storage to build your custom cluster",
                            fontSize = 11.sp,
                            color = colorScheme.onSurface.copy(alpha = 0.6f)
                        )
                    }

                    Spacer(modifier = Modifier.width(12.dp))

                    Surface(
                        shape = RoundedCornerShape(14.dp),
                        color = colorScheme.secondary.copy(alpha = 0.15f),
                        border = androidx.compose.foundation.BorderStroke(1.dp, colorScheme.secondary.copy(alpha = 0.4f))
                    ) {
                        Column(
                            horizontalAlignment = Alignment.End,
                            modifier = Modifier.padding(horizontal = 14.dp, vertical = 8.dp)
                        ) {
                            Text("Estimated Cost", fontSize = 9.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))
                            Text(
                                text = "$formattedPrice/mo",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.ExtraBold,
                                color = colorScheme.secondary
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(20.dp))

                // vCPU Slider
                SliderRow(
                    label = "vCPU Cores",
                    valueText = "${vcpuCores.toInt()} vCores",
                    value = vcpuCores,
                    range = 1f..32f,
                    steps = 30,
                    onValueChange = { vcpuCores = it }
                )

                // RAM Slider
                SliderRow(
                    label = "RAM Memory",
                    valueText = "${ramGb.toInt()} GB DDR5 RAM",
                    value = ramGb,
                    range = 2f..128f,
                    steps = 62,
                    onValueChange = { ramGb = it }
                )

                // NVMe Storage Slider
                SliderRow(
                    label = "NVMe Storage",
                    valueText = "${storageGb.toInt()} GB NVMe SSD",
                    value = storageGb,
                    range = 10f..500f,
                    steps = 48,
                    onValueChange = { storageGb = it }
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Deploy Button
                Button(
                    onClick = {
                        val customPlan = RenCloudPlan(
                            id = "custom-config",
                            name = "Custom Cluster Config (${vcpuCores.toInt()} vCPU, ${ramGb.toInt()}GB RAM)",
                            categoryId = "custom",
                            categoryName = "Custom Config",
                            ram = "${ramGb.toInt()} GB DDR5 RAM",
                            cpu = "${vcpuCores.toInt()} Dedicated vCPU Cores",
                            nvmeStorage = "${storageGb.toInt()} GB High Speed NVMe",
                            monthlyPriceInr = estimatedPriceInr,
                            databases = 5,
                            backups = 7
                        )
                        onDeployClick(customPlan)
                    },
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = colorScheme.primary),
                    modifier = Modifier.fillMaxWidth().height(46.dp)
                ) {
                    Icon(Icons.Default.RocketLaunch, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Deploy Custom Configuration", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = Color.White)
                }
            }
        }
    }
}

@Composable
fun SliderRow(
    label: String,
    valueText: String,
    value: Float,
    range: ClosedFloatingPointRange<Float>,
    steps: Int,
    onValueChange: (Float) -> Unit
) {
    val colorScheme = MaterialTheme.colorScheme
    Column(modifier = Modifier.padding(bottom = 10.dp)) {
        Row(
            horizontalArrangement = Arrangement.SpaceBetween,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(label, fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = colorScheme.onSurface)
            Text(valueText, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = colorScheme.primary)
        }
        Slider(
            value = value,
            onValueChange = onValueChange,
            valueRange = range,
            steps = steps,
            colors = SliderDefaults.colors(
                thumbColor = colorScheme.secondary,
                activeTrackColor = colorScheme.primary,
                inactiveTrackColor = colorScheme.primary.copy(alpha = 0.15f)
            )
        )
    }
}
