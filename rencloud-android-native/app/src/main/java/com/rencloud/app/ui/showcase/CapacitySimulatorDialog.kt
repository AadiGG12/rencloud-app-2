package com.rencloud.app.ui.showcase

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.rencloud.app.ui.theme.*
import kotlin.math.roundToInt

@Composable
fun CapacitySimulatorDialog(onDismiss: () -> Unit) {
    var players by remember { mutableStateOf(10f) }
    var plugins by remember { mutableStateOf(5f) }
    
    val requiredRam = (players * 0.05 + plugins * 0.1 + 2).coerceAtLeast(2.0).roundToInt()
    val requiredCpu = ((players + plugins) / 25.0 + 1).coerceAtLeast(1.0).roundToInt()
    
    val recommendedPlan = when {
        requiredRam <= 4 -> "Starter Plan"
        requiredRam <= 8 -> "Pro Plan"
        else -> "Ultra Plan"
    }

    Dialog(onDismissRequest = onDismiss) {
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = RenCloudNavy)
        ) {
            Column(
                modifier = Modifier.padding(24.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Capacity Simulator", color = RenCloudCyan, fontSize = 20.sp, fontWeight = FontWeight.Bold)
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, contentDescription = "Close", tint = TextPrimaryDark)
                    }
                }
                
                Spacer(modifier = Modifier.height(16.dp))
                
                Text("Estimated Online Players: ${players.roundToInt()}", color = TextPrimaryDark)
                Slider(
                    value = players,
                    onValueChange = { players = it },
                    valueRange = 1f..200f,
                    colors = SliderDefaults.colors(
                        thumbColor = RenCloudPurple,
                        activeTrackColor = RenCloudPurpleLight
                    )
                )
                
                Spacer(modifier = Modifier.height(8.dp))
                
                Text("Active Mods / Plugins: ${plugins.roundToInt()}", color = TextPrimaryDark)
                Slider(
                    value = plugins,
                    onValueChange = { plugins = it },
                    valueRange = 0f..100f,
                    colors = SliderDefaults.colors(
                        thumbColor = RenCloudGold,
                        activeTrackColor = RenCloudGoldDim
                    )
                )
                
                Spacer(modifier = Modifier.height(24.dp))
                
                Card(
                    colors = CardDefaults.cardColors(containerColor = RenCloudCardDark),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text("Requirements", color = TextSecondaryDark, fontSize = 14.sp)
                        Text("$requiredRam GB RAM  •  $requiredCpu Cores", color = TextPrimaryDark, fontWeight = FontWeight.Medium)
                        Spacer(modifier = Modifier.height(8.dp))
                        Text("Recommended:", color = TextSecondaryDark, fontSize = 14.sp)
                        Text(recommendedPlan, color = RenCloudGreen, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                    }
                }
                
                Spacer(modifier = Modifier.height(16.dp))
                
                Button(
                    onClick = onDismiss,
                    colors = ButtonDefaults.buttonColors(containerColor = RenCloudCyan),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Deploy Plan", color = RenCloudNavy, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}
