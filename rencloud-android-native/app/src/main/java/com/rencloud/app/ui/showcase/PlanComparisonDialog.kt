package com.rencloud.app.ui.showcase

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.rencloud.app.ui.theme.*

data class Plan(
    val name: String,
    val ram: String,
    val cpu: String,
    val storage: String,
    val price: String,
    val datacenter: String,
    val ddos: String
)

val samplePlans = listOf(
    Plan("Starter", "2 GB", "1 Core", "20 GB NVMe", "$5/mo", "US/EU/Asia", "Standard"),
    Plan("Pro", "8 GB", "4 Cores", "80 GB NVMe", "$20/mo", "Global", "Terabit"),
    Plan("Ultra", "32 GB", "16 Cores", "320 GB NVMe", "$80/mo", "Global", "Terabit+")
)

@Composable
fun PlanComparisonDialog(onDismiss: () -> Unit) {
    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth(0.95f)
                .fillMaxHeight(0.8f)
                .padding(16.dp),
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = RenCloudNavy)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Compare Plans",
                        color = RenCloudCyan,
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold
                    )
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, contentDescription = "Close", tint = TextPrimaryDark)
                    }
                }
                
                Spacer(modifier = Modifier.height(16.dp))
                
                LazyRow(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(samplePlans) { plan ->
                        PlanColumn(plan)
                    }
                }
            }
        }
    }
}

@Composable
fun PlanColumn(plan: Plan) {
    Column(
        modifier = Modifier
            .width(180.dp)
            .clip(RoundedCornerShape(12.dp))
            .background(RenCloudCardDark)
            .border(1.dp, RenCloudCardBorder, RoundedCornerShape(12.dp))
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(text = plan.name, color = RenCloudGold, fontWeight = FontWeight.Bold, fontSize = 18.sp)
        Text(text = plan.price, color = TextPrimaryDark, fontSize = 16.sp, modifier = Modifier.padding(bottom = 12.dp))
        
        Divider(color = RenCloudCardBorder)
        
        ComparisonRow("RAM", plan.ram)
        ComparisonRow("CPU", plan.cpu)
        ComparisonRow("Storage", plan.storage)
        ComparisonRow("Region", plan.datacenter)
        ComparisonRow("DDoS", plan.ddos)
        
        Spacer(modifier = Modifier.height(16.dp))
        Button(
            onClick = { /* Select */ },
            colors = ButtonDefaults.buttonColors(containerColor = RenCloudCyan),
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Select", color = RenCloudNavy, fontWeight = FontWeight.Bold)
        }
    }
}

@Composable
fun ComparisonRow(label: String, value: String) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(text = label, color = TextSecondaryDark, fontSize = 12.sp)
        Text(text = value, color = TextPrimaryDark, fontSize = 14.sp, fontWeight = FontWeight.Medium)
    }
}
