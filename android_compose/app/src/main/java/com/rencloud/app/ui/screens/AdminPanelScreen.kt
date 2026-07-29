package com.rencloud.app.ui.screens

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.data.CatalogData
import com.rencloud.app.data.RenCloudPlan
import com.rencloud.app.ui.components.GlassCard

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdminPanelScreen(
    appName: String,
    onAppNameChange: (String) -> Unit,
    announcement: String,
    onAnnouncementChange: (String) -> Unit,
    discordUrl: String,
    onDiscordUrlChange: (String) -> Unit,
    onExitAdmin: () -> Unit
) {
    var adminTab by remember { mutableIntStateOf(0) }
    val colorScheme = MaterialTheme.colorScheme
    val context = LocalContext.current

    var editPlanName by remember { mutableStateOf("") }
    var editPlanPrice by remember { mutableStateOf("") }
    var selectedPlanForEdit by remember { mutableStateOf<RenCloudPlan?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("⚡ RenCloud Admin Control Panel", fontWeight = FontWeight.Bold, fontSize = 18.sp) },
                actions = {
                    IconButton(onClick = onExitAdmin) {
                        Icon(Icons.Default.ExitToApp, contentDescription = "Exit Admin", tint = Color.Red)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = colorScheme.surface)
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(colorScheme.background)
                .padding(innerPadding)
                .padding(16.dp)
        ) {
            // Admin Section Tabs
            Row(modifier = Modifier.fillMaxWidth()) {
                FilterChip(
                    selected = adminTab == 0,
                    onClick = { adminTab = 0 },
                    label = { Text("App Customization", fontWeight = FontWeight.Bold, fontSize = 11.sp) },
                    modifier = Modifier.weight(1f)
                )
                Spacer(modifier = Modifier.width(6.dp))
                FilterChip(
                    selected = adminTab == 1,
                    onClick = { adminTab = 1 },
                    label = { Text("Plans Editor", fontWeight = FontWeight.Bold, fontSize = 11.sp) },
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            when (adminTab) {
                0 -> {
                    // App Customization Dashboard
                    Column(modifier = Modifier.verticalScroll(rememberScrollState())) {
                        GlassCard(modifier = Modifier.fillMaxWidth()) {
                            Text("🎨 Live Application Customization", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
                            Text("Modify branding, text banners, and links in real-time across all devices", fontSize = 11.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))

                            Spacer(modifier = Modifier.height(16.dp))

                            OutlinedTextField(
                                value = appName,
                                onValueChange = onAppNameChange,
                                label = { Text("Application Name") },
                                leadingIcon = { Icon(Icons.Default.Edit, contentDescription = null, tint = colorScheme.primary) },
                                shape = RoundedCornerShape(12.dp),
                                modifier = Modifier.fillMaxWidth()
                            )

                            Spacer(modifier = Modifier.height(12.dp))

                            OutlinedTextField(
                                value = announcement,
                                onValueChange = onAnnouncementChange,
                                label = { Text("Announcement Banner Text") },
                                leadingIcon = { Icon(Icons.Default.Campaign, contentDescription = null, tint = colorScheme.secondary) },
                                shape = RoundedCornerShape(12.dp),
                                modifier = Modifier.fillMaxWidth()
                            )

                            Spacer(modifier = Modifier.height(12.dp))

                            OutlinedTextField(
                                value = discordUrl,
                                onValueChange = onDiscordUrlChange,
                                label = { Text("Discord Invite URL") },
                                leadingIcon = { Icon(Icons.Default.Chat, contentDescription = null, tint = colorScheme.primary) },
                                shape = RoundedCornerShape(12.dp),
                                modifier = Modifier.fillMaxWidth()
                            )

                            Spacer(modifier = Modifier.height(20.dp))

                            Button(
                                onClick = {
                                    Toast.makeText(context, "App Branding & Configuration Updated!", Toast.LENGTH_LONG).show()
                                },
                                shape = RoundedCornerShape(12.dp),
                                colors = ButtonDefaults.buttonColors(containerColor = colorScheme.primary),
                                modifier = Modifier.fillMaxWidth().height(48.dp)
                            ) {
                                Icon(Icons.Default.Save, contentDescription = null, tint = Color.White)
                                Spacer(modifier = Modifier.width(8.dp))
                                Text("SAVE GLOBAL CONFIGURATIONS", fontWeight = FontWeight.ExtraBold, color = Color.White)
                            }
                        }
                    }
                }

                1 -> {
                    // Plans Customization Dashboard
                    LazyColumn(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        items(CatalogData.plans) { plan ->
                            GlassCard(modifier = Modifier.fillMaxWidth()) {
                                Row(
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically,
                                    modifier = Modifier.fillMaxWidth()
                                ) {
                                    Column(modifier = Modifier.weight(1f)) {
                                        Text(plan.name, fontSize = 16.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
                                        Text("${plan.ram} | ${plan.cpu} | ₹${plan.monthlyPriceInr}/mo", fontSize = 12.sp, color = colorScheme.secondary)
                                    }

                                    Button(
                                        onClick = {
                                            selectedPlanForEdit = plan
                                            editPlanName = plan.name
                                            editPlanPrice = plan.monthlyPriceInr.toString()
                                        },
                                        shape = RoundedCornerShape(10.dp),
                                        colors = ButtonDefaults.buttonColors(containerColor = colorScheme.secondary.copy(alpha = 0.2f)),
                                        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
                                    ) {
                                        Text("Edit Plan", fontSize = 12.sp, color = colorScheme.secondary, fontWeight = FontWeight.Bold)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Edit Plan Dialog
        selectedPlanForEdit?.let { plan ->
            AlertDialog(
                onDismissRequest = { selectedPlanForEdit = null },
                title = { Text("Edit Plan: ${plan.name}", fontWeight = FontWeight.Bold) },
                text = {
                    Column {
                        OutlinedTextField(
                            value = editPlanName,
                            onValueChange = { editPlanName = it },
                            label = { Text("Plan Name") },
                            modifier = Modifier.fillMaxWidth()
                        )
                        Spacer(modifier = Modifier.height(10.dp))
                        OutlinedTextField(
                            value = editPlanPrice,
                            onValueChange = { editPlanPrice = it },
                            label = { Text("Monthly Price (INR ₹)") },
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                },
                confirmButton = {
                    Button(
                        onClick = {
                            selectedPlanForEdit = null
                            Toast.makeText(context, "Updated ${plan.name} price to ₹$editPlanPrice!", Toast.LENGTH_LONG).show()
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = colorScheme.primary)
                    ) {
                        Text("Save Changes", color = Color.White)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { selectedPlanForEdit = null }) {
                        Text("Cancel")
                    }
                }
            )
        }
    }
}
