package com.rencloud.app.ui.showcase

import androidx.compose.animation.AnimatedVisibility
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
import com.google.gson.annotations.SerializedName
import com.rencloud.app.ui.components.glass.GlassCard
import com.rencloud.app.ui.theme.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET

data class FaqItem(
    @SerializedName("id") val id: String = "",
    @SerializedName("question") val question: String,
    @SerializedName("answer") val answer: String,
    @SerializedName("category") val category: String = "Hosting"
)

private interface FaqPublicApi {
    @GET("api/faqs")
    suspend fun getFaqs(): retrofit2.Response<com.rencloud.app.data.model.GatewayListResponse<FaqItem>>
}

val defaultFaqs = listOf(
    FaqItem("faq_1", "Where are RenCloud datacenters located?", "RenCloud servers are hosted in Tier-4 datacenters in Mumbai (India) and Singapore (Asia-Southeast).", "Servers"),
    FaqItem("faq_2", "What hardware specs do Minecraft servers use?", "Budget tiers use DDR4 ECC memory with Intel Scalable processors, while Premium tiers feature DDR5 memory with AMD EPYC & Ryzen 9 7950X CPUs.", "Hosting"),
    FaqItem("faq_3", "What payment methods are supported?", "We accept UPI, Credit/Debit Cards, NetBanking, PayPal, and major cryptocurrencies.", "Billing"),
    FaqItem("faq_4", "Is DDoS protection included with all plans?", "Yes! All RenCloud plans include enterprise-grade 1.2 Tbps+ DDoS protection.", "Servers")
)

val badges = listOf("99.9% SLA Uptime", "24/7 Live Support", "Instant 60s Deploy", "DDoS Protected")

@Composable
fun FaqSection() {
    var faqList by remember { mutableStateOf(defaultFaqs) }

    LaunchedEffect(Unit) {
        withContext(Dispatchers.IO) {
            try {
                val api = Retrofit.Builder()
                    .baseUrl("https://panel.bihariaayu.indevs.in/")
                    .addConverterFactory(GsonConverterFactory.create())
                    .build()
                    .create(FaqPublicApi::class.java)

                val resp = api.getFaqs()
                if (resp.isSuccessful && resp.body()?.dataList != null) {
                    val live = resp.body()!!.dataList!!
                    if (live.isNotEmpty()) {
                        withContext(Dispatchers.Main) {
                            faqList = live
                        }
                    }
                }
            } catch (e: Exception) {
                // Keep defaultFaqs
            }
        }
    }

    Column(modifier = Modifier.fillMaxWidth().padding(16.dp)) {
        Text("Frequently Asked Questions", color = ElectricCyan, fontSize = 20.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(16.dp))
        
        faqList.forEach { faq ->
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
    
    GlassCard(
        onClick = { expanded = !expanded },
        modifier = Modifier.fillMaxWidth(),
        accentGlow = ElectricCyan,
        alpha = 0.8f
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(faq.question, color = Color.White, fontWeight = FontWeight.Medium)
                Icon(
                    if (expanded) Icons.Default.KeyboardArrowUp else Icons.Default.KeyboardArrowDown,
                    contentDescription = null,
                    tint = ElectricCyan
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
    GlassCard(
        shape = RoundedCornerShape(16.dp),
        accentGlow = RenCloudGreen,
        alpha = 0.85f
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(Icons.Default.CheckCircle, contentDescription = null, tint = RenCloudGreen, modifier = Modifier.size(14.dp))
            Spacer(modifier = Modifier.width(6.dp))
            Text(text, color = Color.White, fontSize = 12.sp)
        }
    }
}
