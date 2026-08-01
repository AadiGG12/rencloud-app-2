package com.rencloud.app.ui.home

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.rencloud.app.R
import com.rencloud.app.data.model.RenCloudPlan
import com.rencloud.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DeployDialog(
    plan: RenCloudPlan,
    onDismiss: () -> Unit,
    onConfirmLaunch: (String) -> Unit
) {
    val isMinecraft = plan.categoryName.contains("Minecraft", ignoreCase = true)
    val isGame = plan.categoryName.contains("Game", ignoreCase = true)
    val isVps = plan.categoryName.contains("VPS", ignoreCase = true) || plan.categoryName.contains("Cloud", ignoreCase = true)
    val isDedicated = plan.categoryName.contains("Dedicated", ignoreCase = true)

    val categoryColor = when {
        isMinecraft -> MinecraftColor
        isVps -> VpsColor
        isDedicated -> DediColor
        isGame -> GameColor
        else -> RenCloudCyan
    }

    val locations = listOf(
        "India — Asia South (Mumbai)",
        "Singapore — Asia Southeast"
    )
    var selectedLocation by remember { mutableStateOf(locations.first()) }
    var locationExpanded by remember { mutableStateOf(false) }

    val nodes = listOf(
        "India-amd-at3  [Node #9]",
        "at-intel-in6   [Node #14]",
        "at-intel-in7   [Node #15]",
        "at-ryzen-in    [Node #16]",
        "free-sg2       [Node #17]",
        "free-sg3       [Node #19]"
    )
    var selectedNode by remember { mutableStateOf(nodes.first()) }
    var nodeExpanded by remember { mutableStateOf(false) }

    val softwareOptions = when {
        isMinecraft -> listOf(
            "Paper  (Egg #4 — Recommended)",
            "Vanilla Minecraft  (Egg #5)",
            "Forge  (Egg #2)",
            "Bungeecord Proxy  (Egg #1)",
            "Pocketmine-MP Bedrock  (Egg #19)",
            "Fabric  (Egg #20)"
        )
        isGame -> listOf(
            "Game Server — Default Image",
            "Ubuntu 22.04 LTS",
            "Debian 12"
        )
        else -> listOf(
            "Ubuntu 24.04 LTS — Recommended",
            "Ubuntu 22.04 LTS",
            "Debian 12 Bookworm",
            "Alpine Linux 3.20",
            "Rocky Linux 9",
            "Node.js 21 Environment"
        )
    }
    var selectedSoftware by remember { mutableStateOf(softwareOptions.first()) }
    var softwareExpanded by remember { mutableStateOf(false) }

    var isLaunching by remember { mutableStateOf(false) }

    // Launch animation
    val infiniteTransition = rememberInfiniteTransition(label = "deployDlg")
    val borderAnim by infiniteTransition.animateFloat(
        initialValue = 0f, targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(3000, easing = LinearEasing)),
        label = "border"
    )

    Dialog(onDismissRequest = onDismiss) {
        Surface(
            modifier = Modifier.fillMaxWidth(),
            color = RenCloudCardDark,
            shape = RoundedCornerShape(24.dp),
            border = BorderStroke(
                1.5.dp,
                Brush.sweepGradient(
                    listOf(
                        categoryColor.copy(alpha = borderAnim * 0.8f + 0.2f),
                        RenCloudCardBorder,
                        categoryColor.copy(alpha = (1f - borderAnim) * 0.8f + 0.2f)
                    )
                )
            )
        ) {
            Column(
                modifier = Modifier
                    .padding(24.dp)
                    .verticalScroll(rememberScrollState())
            ) {
                // ── Dialog Header ──────────────────────────────────────────
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(36.dp)
                                .clip(CircleShape)
                                .background(categoryColor.copy(alpha = 0.15f))
                                .border(1.dp, categoryColor.copy(alpha = 0.4f), CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = Icons.Default.Launch,
                                contentDescription = null,
                                tint = categoryColor,
                                modifier = Modifier.size(20.dp)
                            )
                        }
                        Column {
                            Text(
                                text = "Deploy Server",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Black,
                                color = Color.White
                            )
                            Text(
                                text = "Configure your instance",
                                fontSize = 11.sp,
                                color = TextSecondaryDark
                            )
                        }
                    }
                    IconButton(onClick = onDismiss) {
                        Icon(
                            Icons.Default.Close,
                            contentDescription = "Close",
                            tint = TextSecondaryDark
                        )
                    }
                }

                Spacer(Modifier.height(16.dp))

                // ── Plan Summary Card ──────────────────────────────────────
                Surface(
                    color = categoryColor.copy(alpha = 0.07f),
                    shape = RoundedCornerShape(14.dp),
                    border = BorderStroke(1.dp, categoryColor.copy(alpha = 0.2f))
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(14.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                            Surface(
                                color = categoryColor.copy(alpha = 0.15f),
                                shape = RoundedCornerShape(6.dp)
                            ) {
                                Text(
                                    plan.categoryName.uppercase(),
                                    fontSize = 8.sp,
                                    color = categoryColor,
                                    fontWeight = FontWeight.Bold,
                                    letterSpacing = 1.sp,
                                    modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                                )
                            }
                            Text(
                                plan.name,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color.White
                            )
                            Text(
                                "${plan.cpu}  •  ${plan.ram}  •  ${plan.nvmeStorage}",
                                fontSize = 10.sp,
                                color = TextSecondaryDark
                            )
                        }
                        Column(horizontalAlignment = Alignment.End) {
                            Text(
                                "₹${plan.monthlyPriceInr}",
                                fontSize = 20.sp,
                                fontWeight = FontWeight.Black,
                                color = RenCloudCyan
                            )
                            Text("per month", fontSize = 9.sp, color = TextSecondaryDark)
                        }
                    }
                }

                Spacer(Modifier.height(20.dp))

                // ── Section: Location ──────────────────────────────────────
                DeployDropdownSection(
                    label = "Data Center Location",
                    icon = Icons.Default.LocationOn,
                    selectedValue = selectedLocation,
                    expanded = locationExpanded,
                    onExpand = { locationExpanded = !locationExpanded },
                    onDismiss = { locationExpanded = false },
                    options = locations,
                    onSelect = { selectedLocation = it; locationExpanded = false },
                    accentColor = categoryColor
                )

                Spacer(Modifier.height(14.dp))

                // ── Section: Node ──────────────────────────────────────────
                DeployDropdownSection(
                    label = "Target Node",
                    icon = Icons.Default.Dns,
                    selectedValue = selectedNode,
                    expanded = nodeExpanded,
                    onExpand = { nodeExpanded = !nodeExpanded },
                    onDismiss = { nodeExpanded = false },
                    options = nodes,
                    onSelect = { selectedNode = it; nodeExpanded = false },
                    accentColor = categoryColor
                )

                Spacer(Modifier.height(14.dp))

                // ── Section: Software / OS ─────────────────────────────────
                DeployDropdownSection(
                    label = if (isMinecraft) "Minecraft Egg / Software" else "Operating System",
                    icon = if (isMinecraft) Icons.Default.Code else Icons.Default.Terminal,
                    selectedValue = selectedSoftware,
                    expanded = softwareExpanded,
                    onExpand = { softwareExpanded = !softwareExpanded },
                    onDismiss = { softwareExpanded = false },
                    options = softwareOptions,
                    onSelect = { selectedSoftware = it; softwareExpanded = false },
                    accentColor = categoryColor
                )

                Spacer(Modifier.height(20.dp))

                // ── Info row ───────────────────────────────────────────────
                Surface(
                    color = RenCloudCyan.copy(alpha = 0.06f),
                    shape = RoundedCornerShape(10.dp),
                    border = BorderStroke(0.5.dp, RenCloudCyan.copy(alpha = 0.2f))
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            Icons.Default.Info,
                            null,
                            tint = RenCloudCyan,
                            modifier = Modifier.size(14.dp)
                        )
                        Text(
                            "Server will be provisioned via Pterodactyl Panel and ready in 60-120 seconds.",
                            fontSize = 10.sp,
                            color = TextSecondaryDark,
                            lineHeight = 14.sp
                        )
                    }
                }

                Spacer(Modifier.height(20.dp))

                // ── Confirm Button ─────────────────────────────────────────
                Button(
                    onClick = {
                        isLaunching = true
                        onConfirmLaunch(
                            "${plan.name} provisioning started at $selectedLocation on ${selectedNode.trim()} — ${selectedSoftware.split("(").first().trim()}"
                        )
                    },
                    enabled = !isLaunching,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = categoryColor,
                        disabledContainerColor = categoryColor.copy(alpha = 0.4f)
                    ),
                    shape = RoundedCornerShape(14.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                ) {
                    AnimatedContent(
                        targetState = isLaunching,
                        transitionSpec = { fadeIn() togetherWith fadeOut() },
                        label = "launchBtn"
                    ) { launching ->
                        if (launching) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(10.dp)
                            ) {
                                CircularProgressIndicator(
                                    color = Color.White,
                                    modifier = Modifier.size(18.dp),
                                    strokeWidth = 2.dp
                                )
                                Text("Provisioning...", fontWeight = FontWeight.Bold)
                            }
                        } else {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                Icon(
                                    Icons.Default.Launch,
                                    null,
                                    modifier = Modifier.size(18.dp)
                                )
                                Text(
                                    "CONFIRM & LAUNCH",
                                    fontWeight = FontWeight.Black,
                                    letterSpacing = 0.5.sp,
                                    fontSize = 14.sp
                                )
                            }
                        }
                    }
                }

                // Dismiss
                TextButton(
                    onClick = onDismiss,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Cancel", color = TextSecondaryDark, fontSize = 13.sp)
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun DeployDropdownSection(
    label: String,
    icon: ImageVector,
    selectedValue: String,
    expanded: Boolean,
    onExpand: () -> Unit,
    onDismiss: () -> Unit,
    options: List<String>,
    onSelect: (String) -> Unit,
    accentColor: Color
) {
    Column {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            modifier = Modifier.padding(bottom = 6.dp)
        ) {
            Icon(icon, null, tint = accentColor, modifier = Modifier.size(14.dp))
            Text(
                text = label,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White,
                letterSpacing = 0.3.sp
            )
        }

        ExposedDropdownMenuBox(
            expanded = expanded,
            onExpandedChange = { onExpand() }
        ) {
            OutlinedTextField(
                value = selectedValue,
                onValueChange = {},
                readOnly = true,
                trailingIcon = {
                    Icon(
                        if (expanded) Icons.Default.ExpandLess else Icons.Default.ExpandMore,
                        null,
                        tint = accentColor
                    )
                },
                modifier = Modifier
                    .menuAnchor()
                    .fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = accentColor,
                    unfocusedBorderColor = RenCloudCardBorder,
                    focusedContainerColor = RenCloudNavy.copy(alpha = 0.5f),
                    unfocusedContainerColor = RenCloudNavy.copy(alpha = 0.5f),
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White
                ),
                shape = RoundedCornerShape(12.dp),
                textStyle = androidx.compose.ui.text.TextStyle(fontSize = 13.sp)
            )
            ExposedDropdownMenu(
                expanded = expanded,
                onDismissRequest = onDismiss,
                modifier = Modifier.background(RenCloudSurfaceDark)
            ) {
                options.forEach { option ->
                    DropdownMenuItem(
                        text = {
                            Text(
                                option,
                                fontSize = 13.sp,
                                color = if (option == selectedValue) accentColor else Color.White
                            )
                        },
                        onClick = { onSelect(option) },
                        leadingIcon = {
                            if (option == selectedValue) {
                                Icon(
                                    Icons.Default.CheckCircle,
                                    null,
                                    tint = accentColor,
                                    modifier = Modifier.size(14.dp)
                                )
                            }
                        },
                        colors = MenuDefaults.itemColors(
                            textColor = Color.White
                        )
                    )
                }
            }
        }
    }
}
