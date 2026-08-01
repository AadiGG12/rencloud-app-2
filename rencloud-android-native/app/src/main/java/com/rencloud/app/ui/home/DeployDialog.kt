package com.rencloud.app.ui.home

import androidx.compose.animation.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.rencloud.app.data.model.RenCloudPlan
import com.rencloud.app.ui.theme.*

@Composable
fun DeployDialog(
    plan: RenCloudPlan,
    onDismiss: () -> Unit,
    onConfirmLaunch: (String) -> Unit
) {
    val locations = remember { listOf("India (Mumbai - Asia South)", "Singapore (Asia Southeast)") }
    val nodes = remember { listOf("Node-01 (AMD Ryzen 9 7950X)", "Node-02 (AMD EPYC Milan)", "Node-03 (Intel Platinum)") }
    val eggsList = remember {
        listOf(
            "Paper (Minecraft Vanilla + Plugins)",
            "Purpur (High Performance Minecraft)",
            "Spigot (Minecraft)",
            "Forge (Modded Minecraft)",
            "Fabric (Lightweight Modded)",
            "BungeeCord Proxy",
            "Ubuntu 22.04 LTS (Cloud VPS)",
            "Debian 12 Bookworm (Cloud VPS)",
            "Docker Engine (Alpine)"
        )
    }

    var selectedLocation by remember { mutableStateOf(locations[0]) }
    var selectedNode by remember { mutableStateOf(nodes[0]) }
    var selectedEgg by remember { mutableStateOf(eggsList[0]) }
    var serverName by remember { mutableStateOf("${plan.name}-Server") }

    var expandedLocation by remember { mutableStateOf(false) }
    var expandedNode by remember { mutableStateOf(false) }
    var expandedEgg by remember { mutableStateOf(false) }

    Dialog(onDismissRequest = onDismiss) {
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .wrapContentHeight(),
            color = MaterialTheme.colorScheme.surface,
            shape = RoundedCornerShape(20.dp),
            border = BorderStroke(1.5.dp, Brush.linearGradient(listOf(MetallicPurple, ElectricCyan)))
        ) {
            Column(
                modifier = Modifier
                    .padding(20.dp)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                // Header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(Icons.Default.RocketLaunch, contentDescription = null, tint = ElectricCyan)
                        Text("Deploy ${plan.name}", fontSize = 18.sp, fontWeight = FontWeight.Black, color = MaterialTheme.colorScheme.onSurface)
                    }
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, contentDescription = "Close", tint = TextSecondaryDark)
                    }
                }

                // Server Name Input
                OutlinedTextField(
                    value = serverName,
                    onValueChange = { serverName = it },
                    label = { Text("Server Instance Name", color = TextSecondaryDark) },
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = ElectricCyan,
                        unfocusedBorderColor = MetallicBorderDark,
                        focusedTextColor = MaterialTheme.colorScheme.onSurface,
                        unfocusedTextColor = MaterialTheme.colorScheme.onSurface
                    ),
                    modifier = Modifier.fillMaxWidth()
                )

                // Datacenter Location Selector
                Text("Datacenter Location", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = TextSecondaryDark)
                ClickableDropdown(
                    selectedText = selectedLocation,
                    expanded = expandedLocation,
                    onExpandedChange = { expandedLocation = it },
                    options = locations,
                    onSelect = { selectedLocation = it; expandedLocation = false }
                )

                // Compute Node Selector
                Text("Compute Node", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = TextSecondaryDark)
                ClickableDropdown(
                    selectedText = selectedNode,
                    expanded = expandedNode,
                    onExpandedChange = { expandedNode = it },
                    options = nodes,
                    onSelect = { selectedNode = it; expandedNode = false }
                )

                // Pterodactyl Egg Selector (Replaced Minecraft Version)
                Text("Pterodactyl Egg / Software Image", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = TextSecondaryDark)
                ClickableDropdown(
                    selectedText = selectedEgg,
                    expanded = expandedEgg,
                    onExpandedChange = { expandedEgg = it },
                    options = eggsList,
                    onSelect = { selectedEgg = it; expandedEgg = false }
                )

                Spacer(Modifier.height(4.dp))

                // Launch Button
                Button(
                    onClick = {
                        onConfirmLaunch("Deployment triggered for '$serverName' on $selectedNode ($selectedLocation)!")
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = ElectricCyan),
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(Icons.Default.RocketLaunch, contentDescription = null, tint = Color.Black)
                        Text("LAUNCH SERVER NOW", color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                    }
                }
            }
        }
    }
}

@Composable
private fun ClickableDropdown(
    selectedText: String,
    expanded: Boolean,
    onExpandedChange: (Boolean) -> Unit,
    options: List<String>,
    onSelect: (String) -> Unit
) {
    Box(modifier = Modifier.fillMaxWidth()) {
        Surface(
            onClick = { onExpandedChange(!expanded) },
            color = MetallicNavy,
            shape = RoundedCornerShape(10.dp),
            border = BorderStroke(1.dp, if (expanded) ElectricCyan else MetallicBorderDark),
            modifier = Modifier.fillMaxWidth()
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(14.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(selectedText, color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Medium)
                Icon(
                    imageVector = if (expanded) Icons.Default.ExpandLess else Icons.Default.ExpandMore,
                    contentDescription = null,
                    tint = ElectricCyan
                )
            }
        }

        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { onExpandedChange(false) },
            modifier = Modifier
                .fillMaxWidth(0.85f)
                .background(MetallicCardDark)
        ) {
            options.forEach { item ->
                DropdownMenuItem(
                    text = { Text(item, color = Color.White, fontSize = 12.sp) },
                    onClick = { onSelect(item) }
                )
            }
        }
    }
}
