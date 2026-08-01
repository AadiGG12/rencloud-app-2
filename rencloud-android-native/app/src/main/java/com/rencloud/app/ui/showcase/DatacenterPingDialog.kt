package com.rencloud.app.ui.showcase

import androidx.compose.animation.core.*
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
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun DatacenterPingDialog(onDismiss: () -> Unit) {
    var isTesting by remember { mutableStateOf(false) }
    var mumbaiPing by remember { mutableStateOf<Int?>(null) }
    var singaporePing by remember { mutableStateOf<Int?>(null) }
    val scope = rememberCoroutineScope()
    
    val pulse by rememberInfiniteTransition(label = "").animateFloat(
        initialValue = 1f,
        targetValue = if (isTesting) 0.3f else 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(500, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ), label = ""
    )

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
                    Text("Datacenter Ping", color = RenCloudCyan, fontSize = 20.sp, fontWeight = FontWeight.Bold)
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, contentDescription = "Close", tint = TextPrimaryDark)
                    }
                }
                
                Spacer(modifier = Modifier.height(16.dp))
                
                DatacenterRow("Mumbai, India (Asia-South)", mumbaiPing, isTesting, pulse)
                Spacer(modifier = Modifier.height(8.dp))
                DatacenterRow("Singapore (Asia-Southeast)", singaporePing, isTesting, pulse)
                
                Spacer(modifier = Modifier.height(24.dp))
                
                Button(
                    onClick = {
                        scope.launch {
                            isTesting = true
                            mumbaiPing = null
                            singaporePing = null
                            delay(1500)
                            mumbaiPing = 28
                            delay(1000)
                            singaporePing = 54
                            isTesting = false
                        }
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = RenCloudPurple),
                    modifier = Modifier.fillMaxWidth(),
                    enabled = !isTesting
                ) {
                    Text(if (isTesting) "Testing..." else "Run Ping Test", color = TextPrimaryDark, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

@Composable
fun DatacenterRow(name: String, ping: Int?, isTesting: Boolean, pulse: Float) {
    Card(
        colors = CardDefaults.cardColors(containerColor = RenCloudCardDark),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(name, color = TextPrimaryDark, fontWeight = FontWeight.Medium)
            Spacer(modifier = Modifier.height(4.dp))
            
            if (isTesting && ping == null) {
                Text("Pinging...", color = RenCloudCyan.copy(alpha = pulse), fontSize = 14.sp)
            } else if (ping != null) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("${ping}ms", color = RenCloudGreen, fontWeight = FontWeight.Bold)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Optimal Latency", color = TextSecondaryDark, fontSize = 12.sp)
                }
                Spacer(modifier = Modifier.height(4.dp))
                Text("Terabit DDoS Protection | Direct Routing", color = TextMutedDark, fontSize = 11.sp)
            } else {
                Text("Not tested", color = TextSecondaryDark, fontSize = 14.sp)
            }
        }
    }
}
