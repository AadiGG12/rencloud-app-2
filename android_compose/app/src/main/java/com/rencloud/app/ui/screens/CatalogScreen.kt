package com.rencloud.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.SystemUpdate
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.data.AppCurrency
import com.rencloud.app.data.BillingCycle
import com.rencloud.app.data.CatalogData
import com.rencloud.app.data.RenCloudPlan
import com.rencloud.app.ui.components.PlanCard
import com.rencloud.app.ui.theme.*

@Composable
fun CatalogScreen(
    currency: AppCurrency,
    onDeployClick: (RenCloudPlan) -> Unit,
    onCheckUpdateClick: () -> Unit
) {
    var searchQuery by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf("all") }
    var billingCycle by remember { mutableStateOf(BillingCycle.MONTHLY) }

    val filteredPlans = remember(searchQuery, selectedCategory) {
        CatalogData.plans.filter { plan ->
            val matchesCategory = (selectedCategory == "all") || (plan.categoryId == selectedCategory)
            val matchesSearch = searchQuery.isEmpty() ||
                    plan.name.contains(searchQuery, ignoreCase = true) ||
                    plan.categoryName.contains(searchQuery, ignoreCase = true) ||
                    plan.ram.contains(searchQuery, ignoreCase = true) ||
                    plan.cpu.contains(searchQuery, ignoreCase = true)
            matchesCategory && matchesSearch
        }
    }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(BackgroundDark)
            .padding(horizontal = 16.dp),
        contentPadding = PaddingValues(bottom = 24.dp)
    ) {
        item {
            Spacer(modifier = Modifier.height(16.dp))

            // Search Bar
            OutlinedTextField(
                value = searchQuery,
                onValueChange = { searchQuery = it },
                placeholder = { Text("Search 55 server plans...", color = TextSecondary) },
                leadingIcon = { Icon(Icons.Default.Search, contentDescription = null, tint = PrimaryPurple) },
                shape = RoundedCornerShape(14.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedContainerColor = SurfaceDark,
                    unfocusedContainerColor = SurfaceDark,
                    focusedBorderColor = PrimaryPurple,
                    unfocusedBorderColor = BorderDark,
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White
                ),
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Billing Cycle Toggle Chips
            Row(
                horizontalArrangement = Arrangement.Center,
                modifier = Modifier.fillMaxWidth()
            ) {
                FilterChip(
                    selected = billingCycle == BillingCycle.MONTHLY,
                    onClick = { billingCycle = BillingCycle.MONTHLY },
                    label = { Text("Monthly", fontWeight = FontWeight.Bold) },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = PrimaryPurple,
                        selectedLabelColor = Color.White,
                        containerColor = SurfaceDark,
                        labelColor = Color.White
                    )
                )

                Spacer(modifier = Modifier.width(8.dp))

                FilterChip(
                    selected = billingCycle == BillingCycle.ANNUAL,
                    onClick = { billingCycle = BillingCycle.ANNUAL },
                    label = { Text("Annual (Save 15%)", fontWeight = FontWeight.Bold) },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = AccentAqua,
                        selectedLabelColor = Color.White,
                        containerColor = SurfaceDark,
                        labelColor = Color.White
                    )
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Category Chips Row
            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                items(CatalogData.categories) { (catId, catName) ->
                    val isSelected = selectedCategory == catId
                    Surface(
                        shape = RoundedCornerShape(20.dp),
                        color = if (isSelected) PrimaryPurple else SurfaceDark,
                        border = androidx.compose.foundation.BorderStroke(1.dp, if (isSelected) PrimaryPurple else BorderDark),
                        modifier = Modifier.clickable { selectedCategory = catId }
                    ) {
                        Text(
                            text = catName,
                            fontSize = 12.sp,
                            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                            color = Color.White,
                            modifier = Modifier.padding(horizontal = 14.dp, vertical = 8.dp)
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }

        // Plans List
        items(filteredPlans) { plan ->
            PlanCard(
                plan = plan,
                billingCycle = billingCycle,
                currency = currency,
                onDeployClick = onDeployClick
            )
            Spacer(modifier = Modifier.height(12.dp))
        }
    }
}
