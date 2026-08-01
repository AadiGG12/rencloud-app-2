package com.rencloud.app.ui.calculator

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Calculate
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Public
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.ui.components.glass.*
import com.rencloud.app.ui.theme.*
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ResourceCalculatorScreen(
    onNavigateBack: () -> Unit = {}
) {
    var serviceType by remember { mutableStateOf("Minecraft") }
    var ramGb by remember { mutableStateOf(4f) }
    var cpuCores by remember { mutableStateOf(2f) }
    var storageGb by remember { mutableStateOf(50f) }
    var dedicatedIp by remember { mutableStateOf(false) }
    var currency by remember { mutableStateOf("INR") }
    
    val snackbarHostState = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()

    val baseRam = ramGb * 30f
    val baseCpu = cpuCores * 15f
    val baseStorage = storageGb * 0.5f
    
    val multiplier = when (serviceType) {
        "VPS" -> 1.25f
        "Other" -> 0.85f
        else -> 1.0f
    }
    
    var rawInr = (baseRam + baseCpu + baseStorage) * multiplier
    if (dedicatedIp) rawInr += 150f

    val priceText = if (currency == "INR") "₹${rawInr.toInt()}/mo" else "$${(rawInr * 0.012f).toInt()}/mo"

    LiquidGlassBackground {
        Scaffold(
            snackbarHost = { SnackbarHost(snackbarHostState) },
            topBar = {
                TopAppBar(
                    title = {
                        Text(
                            "Resource Estimator",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    },
                    navigationIcon = {
                        IconButton(onClick = onNavigateBack) {
                            Icon(
                                imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                                contentDescription = "Back",
                                tint = Color.White
                            )
                        }
                    },
                    actions = {
                        TextButton(onClick = { currency = if (currency == "INR") "USD" else "INR" }) {
                            Text(
                                text = if (currency == "INR") "₹ INR" else "$ USD",
                                color = RenCloudGold,
                                fontWeight = FontWeight.Bold,
                                fontSize = 12.sp
                            )
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.Transparent)
                )
            },
            containerColor = Color.Transparent
        ) { innerPadding ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
                    .verticalScroll(rememberScrollState())
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Price estimation glass card
                GlassCard(
                    modifier = Modifier.fillMaxWidth(),
                    accentGlow = ElectricCyan,
                    alpha = 0.85f
                ) {
                    Column(
                        modifier = Modifier.padding(20.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text("ESTIMATED MONTHLY COST", fontSize = 10.sp, color = ElectricCyan, fontWeight = FontWeight.Bold, letterSpacing = 1.5.sp)
                        Text(
                            text = priceText,
                            fontSize = 36.sp,
                            fontWeight = FontWeight.Black,
                            color = Color.White
                        )
                        Text(
                            text = "$serviceType • ${ramGb.toInt()}GB RAM • ${cpuCores.toInt()} vCores • ${storageGb.toInt()}GB NVMe",
                            fontSize = 11.sp,
                            color = TextSecondaryDark
                        )
                    }
                }

                // Service Type Filter Chips
                Text("SERVICE TYPE", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = TextSecondaryDark)
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    listOf("Minecraft", "VPS", "Other").forEach { type ->
                        FilterChip(
                            selected = serviceType == type,
                            onClick = { serviceType = type },
                            label = { Text(type, color = if (serviceType == type) Color.Black else Color.White) },
                            colors = FilterChipDefaults.filterChipColors(
                                selectedContainerColor = ElectricCyan,
                                containerColor = MetallicCardDark.copy(alpha = 0.6f)
                            )
                        )
                    }
                }

                // Sliders Glass Card
                GlassCard(
                    modifier = Modifier.fillMaxWidth(),
                    alpha = 0.8f
                ) {
                    Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text("RAM Allocation: ${ramGb.toInt()} GB", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                        Slider(
                            value = ramGb,
                            onValueChange = { ramGb = it },
                            valueRange = 1f..64f,
                            colors = SliderDefaults.colors(thumbColor = ElectricCyan, activeTrackColor = ElectricCyan)
                        )

                        Text("CPU Cores: ${cpuCores.toInt()} vCores", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                        Slider(
                            value = cpuCores,
                            onValueChange = { cpuCores = it },
                            valueRange = 1f..16f,
                            colors = SliderDefaults.colors(thumbColor = MetallicPurple, activeTrackColor = MetallicPurple)
                        )

                        Text("NVMe Storage: ${storageGb.toInt()} GB", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                        Slider(
                            value = storageGb,
                            onValueChange = { storageGb = it },
                            valueRange = 10f..500f,
                            colors = SliderDefaults.colors(thumbColor = RenCloudGold, activeTrackColor = RenCloudGold)
                        )
                    }
                }

                // Addons Glass Card
                GlassCard(
                    modifier = Modifier.fillMaxWidth(),
                    alpha = 0.8f
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text("Dedicated IPv4 Address", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                            Text("+₹150/mo dedicated IP allocation", color = TextSecondaryDark, fontSize = 10.sp)
                        }
                        Switch(
                            checked = dedicatedIp,
                            onCheckedChange = { dedicatedIp = it },
                            colors = SwitchDefaults.colors(checkedThumbColor = Color.Black, checkedTrackColor = ElectricCyan)
                        )
                    }
                }

                // Action button
                GlassButton(
                    onClick = {
                        scope.launch {
                            snackbarHostState.showSnackbar("Custom $serviceType server estimate: $priceText")
                        }
                    },
                    containerColor = ElectricCyan,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(50.dp)
                ) {
                    Text("SAVE ESTIMATE", color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                }
            }
        }
    }
}
