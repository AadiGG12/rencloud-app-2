package com.rencloud.app.ui.showcase

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.ui.theme.*

data class FaqItem(val question: String, val answer: String)

val faqs = listOf(
    FaqItem("How fast is server provisioning?", "Instant setup under 60 seconds"),
    FaqItem("What DDoS protection is included?", "Terabit-scale anti-DDoS mitigation included free"),
    FaqItem("Can I upgrade/downgrade plans anytime?", "Yes, upgrade seamlessly without data loss"),
    FaqItem("Are backups included?", "Automated daily backups included")
)

val badges = listOf("99.9% SLA Uptime", "24/7 Live Support", "Instant 60s Deploy", "DDoS Protected")

@Composable
fun FaqSection() {
    Column(modifier = Modifier.fillMaxWidth().padding(16.dp)) {
        Text("Frequently Asked Questions", color = RenCloudCyan, fontSize = 20.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(16.dp))
        
        faqs.forEach { faq ->
            FaqItemCard(faq)
            Spacer(modifier = Modifier.height(8.dp))
        }
        
        Spacer(modifier = Modifier.height(24.dp))
        
        LazyRow(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(badges) { badge ->
                BadgeChip(badge)
            }
        }
    }
}

@Composable
fun FaqItemCard(faq: FaqItem) {
    var expanded by remember { mutableStateOf(false) }
    
    Card(
        modifier = Modifier.fillMaxWidth().clickable { expanded = !expanded },
        colors = CardDefaults.cardColors(containerColor = RenCloudCardDark),
        shape = RoundedCornerShape(8.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(faq.question, color = TextPrimaryDark, fontWeight = FontWeight.Medium)
                Icon(
                    if (expanded) Icons.Default.KeyboardArrowUp else Icons.Default.KeyboardArrowDown,
                    contentDescription = null,
                    tint = RenCloudCyan
                )
            }
            AnimatedVisibility(visible = expanded) {
                Column {
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(faq.answer, color = TextSecondaryDark, fontSize = 14.sp)
                }
            }
        }
    }
}

@Composable
fun BadgeChip(text: String) {
    Surface(
        color = RenCloudNavy,
        shape = RoundedCornerShape(16.dp),
        border = androidx.compose.foundation.BorderStroke(1.dp, RenCloudCardBorder)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(Icons.Default.CheckCircle, contentDescription = null, tint = RenCloudGreen, modifier = Modifier.size(14.dp))
            Spacer(modifier = Modifier.width(6.dp))
            Text(text, color = TextPrimaryDark, fontSize = 12.sp)
        }
    }
}
