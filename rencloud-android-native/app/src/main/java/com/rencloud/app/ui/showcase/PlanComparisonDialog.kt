package com.rencloud.app.ui.showcase

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Compare
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.rencloud.app.data.model.RenCloudPlan
import com.rencloud.app.data.repository.CatalogRepository
import com.rencloud.app.ui.theme.*

@Composable
fun PlanComparisonDialog(
    catalogRepository: CatalogRepository = CatalogRepository(),
    onDismiss: () -> Unit
) {
    val allPlans = remember { catalogRepository.getPlans() }
    
    // Default 3 plans to compare from actual catalog
    var selectedPlan1 by remember { mutableStateOf(allPlans.firstOrNull { it.id == "mc_b_iron" } ?: allPlans[0]) }
    var selectedPlan2 by remember { mutableStateOf(allPlans.firstOrNull { it.id == "mc_p_iron" } ?: allPlans.getOrElse(1) { allPlans[0] }) }
    var selectedPlan3 by remember { mutableStateOf(allPlans.firstOrNull { it.id == "vps_ryzen_16" } ?: allPlans.getOrElse(2) { allPlans[0] }) }

    Dialog(onDismissRequest = onDismiss) {
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.85f),
            color = RenCloudCardDark,
            shape = RoundedCornerShape(24.dp),
            border = BorderStroke(1.5.dp, Brush.linearGradient(listOf(MetallicPurple, ElectricCyan)))
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(18.dp)
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
                            text = "Compare RenCloud Plans",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Black,
                            color = Color.White
                        )
                    }

                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, contentDescription = "Close", tint = TextSecondaryDark)
                    }
                }

                Spacer(Modifier.height(12.dp))

                // Side-by-side comparison cards
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f)
                        .horizontalScroll(rememberScrollState()),
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    CompareColumn(selectedPlan1, allPlans) { selectedPlan1 = it }
                    CompareColumn(selectedPlan2, allPlans) { selectedPlan2 = it }
                    CompareColumn(selectedPlan3, allPlans) { selectedPlan3 = it }
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
    var expandedDropdown by remember { mutableStateOf(false) }

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
            // Plan Selector Dropdown Trigger
            Box(modifier = Modifier.fillMaxWidth()) {
                Surface(
                    onClick = { expandedDropdown = true },
                    color = MetallicCardDark,
                    shape = RoundedCornerShape(10.dp),
                    border = BorderStroke(1.dp, ElectricCyan.copy(alpha = 0.4f)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = currentPlan.name,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold,
                            color = RenCloudGold,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }

                DropdownMenu(
                    expanded = expandedDropdown,
                    onDismissRequest = { expandedDropdown = false },
                    modifier = Modifier
                        .height(280.dp)
                        .background(MetallicCardDark)
                ) {
                    allPlans.forEach { plan ->
                        DropdownMenuItem(
                            text = {
                                Text(
                                    "${plan.name} (${plan.categoryName})",
                                    fontSize = 12.sp,
                                    color = Color.White
                                )
                            },
                            onClick = {
                                onPlanSelected(plan)
                                expandedDropdown = false
                            }
                        )
                    }
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

            Divider(color = MetallicBorderDark)

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
}

@Composable
private fun SpecRow(label: String, value: String) {
    Column {
        Text(label, fontSize = 9.sp, fontWeight = FontWeight.Bold, color = TextMutedDark)
        Text(value, fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = Color.White, maxLines = 1, overflow = TextOverflow.Ellipsis)
    }
}
