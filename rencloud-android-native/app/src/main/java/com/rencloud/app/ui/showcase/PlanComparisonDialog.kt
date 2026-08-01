package com.rencloud.app.ui.showcase

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Compare
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.rencloud.app.data.model.RenCloudPlan
import com.rencloud.app.data.repository.CatalogRepository
import com.rencloud.app.ui.theme.*
import com.rencloud.app.util.SoundEffects

@Composable
fun PlanComparisonDialog(
    catalogRepository: CatalogRepository = CatalogRepository(),
    onDismiss: () -> Unit
) {
    val view = LocalView.current
    val allPlans = remember { catalogRepository.getPlans() }

    var selectedPlan1 by remember { mutableStateOf(allPlans.firstOrNull { it.id == "mc_b_iron" } ?: allPlans[0]) }
    var selectedPlan2 by remember { mutableStateOf(allPlans.firstOrNull { it.id == "mc_p_iron" } ?: allPlans.getOrElse(1) { allPlans[0] }) }
    var selectedPlan3 by remember { mutableStateOf(allPlans.firstOrNull { it.id == "vps_ryzen_16" } ?: allPlans.getOrElse(2) { allPlans[0] }) }

    Dialog(onDismissRequest = onDismiss) {
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.88f),
            color = MaterialTheme.colorScheme.surface,
            shape = RoundedCornerShape(24.dp),
            border = BorderStroke(1.5.dp, Brush.linearGradient(listOf(MetallicPurple, ElectricCyan)))
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp)
            ) {
                // Title header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Compare,
                            contentDescription = null,
                            tint = ElectricCyan,
                            modifier = Modifier.size(24.dp)
                        )
                        Text(
                            text = "Compare Any Plan",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Black,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                    }

                    IconButton(onClick = {
                        SoundEffects.playClickSound(view)
                        onDismiss()
                    }) {
                        Icon(Icons.Default.Close, contentDescription = "Close", tint = TextSecondaryDark)
                    }
                }

                Spacer(Modifier.height(10.dp))

                // Side-by-side comparison columns for ANY plan
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f)
                        .horizontalScroll(rememberScrollState()),
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    CompareColumn(selectedPlan1, allPlans) { selectedPlan1 = it; SoundEffects.playClickSound(view) }
                    CompareColumn(selectedPlan2, allPlans) { selectedPlan2 = it; SoundEffects.playClickSound(view) }
                    CompareColumn(selectedPlan3, allPlans) { selectedPlan3 = it; SoundEffects.playClickSound(view) }
                }
            }
        }
    }
}

@Composable
private fun CompareColumn(
    currentPlan: RenCloudPlan,
    allPlans: List<RenCloudPlan>,
    onPlanSelected: (RenCloudPlan) -> Unit
) {
    var showPlanPickerModal by remember { mutableStateOf(false) }

    Surface(
        modifier = Modifier
            .width(180.dp)
            .fillMaxHeight(),
        color = MetallicNavy,
        shape = RoundedCornerShape(16.dp),
        border = BorderStroke(1.dp, MetallicBorderDark)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(12.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            // Plan Selector Trigger (Select ANY of the 55 Plans)
            Surface(
                onClick = { showPlanPickerModal = true },
                color = MetallicCardDark,
                shape = RoundedCornerShape(10.dp),
                border = BorderStroke(1.dp, ElectricCyan.copy(alpha = 0.5f)),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 8.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = currentPlan.name,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = RenCloudGold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f)
                    )
                    Icon(Icons.Default.ExpandMore, contentDescription = null, tint = ElectricCyan, modifier = Modifier.size(16.dp))
                }
            }

            Text(
                text = "₹${currentPlan.monthlyPriceInr}/mo",
                fontSize = 18.sp,
                fontWeight = FontWeight.Black,
                color = ElectricCyan,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )

            HorizontalDivider(color = MetallicBorderDark)

            // Specs Matrix
            SpecRow("CATEGORY", currentPlan.categoryName)
            SpecRow("RAM", currentPlan.ram)
            SpecRow("CPU CORES", currentPlan.cpu)
            SpecRow("STORAGE", currentPlan.nvmeStorage)
            SpecRow("BANDWIDTH", currentPlan.bandwidth)
            SpecRow("LOCATION", currentPlan.location)

            Spacer(Modifier.weight(1f))

            Surface(
                color = MetallicPurple.copy(alpha = 0.2f),
                shape = RoundedCornerShape(8.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(6.dp),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(Icons.Default.Check, contentDescription = null, tint = MetallicPurple, modifier = Modifier.size(14.dp))
                    Spacer(Modifier.width(4.dp))
                    Text("Terabit DDoS", fontSize = 10.sp, color = MetallicPurple, fontWeight = FontWeight.Bold)
                }
            }
        }
    }

    if (showPlanPickerModal) {
        Dialog(onDismissRequest = { showPlanPickerModal = false }) {
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .fillMaxHeight(0.7f),
                color = RenCloudCardDark,
                shape = RoundedCornerShape(20.dp),
                border = BorderStroke(1.dp, ElectricCyan)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Choose Any Plan (${allPlans.size})", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White)
                    Spacer(Modifier.height(10.dp))
                    LazyColumn(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        items(allPlans) { plan ->
                            Surface(
                                onClick = {
                                    onPlanSelected(plan)
                                    showPlanPickerModal = false
                                },
                                color = if (plan.id == currentPlan.id) MetallicPurple else MetallicNavy,
                                shape = RoundedCornerShape(10.dp),
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Row(
                                    modifier = Modifier.padding(12.dp),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Column {
                                        Text(plan.name, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                        Text("${plan.categoryName} • ${plan.ram}", color = TextSecondaryDark, fontSize = 10.sp)
                                    }
                                    Text("₹${plan.monthlyPriceInr}", color = ElectricCyan, fontWeight = FontWeight.Black, fontSize = 13.sp)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun SpecRow(label: String, value: String) {
    Column {
        Text(label, fontSize = 9.sp, fontWeight = FontWeight.Bold, color = TextMutedDark)
        Text(value, fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = Color.White, maxLines = 1, overflow = TextOverflow.Ellipsis)
    }
}
