package com.rencloud.app.ui.panel

import androidx.compose.animation.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.ui.theme.*

data class PanelMenuItem(
    val title: String,
    val icon: ImageVector,
    val category: String
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PanelScreen(
    onNavigateBack: () -> Unit = {}
) {
    var selectedTab by remember { mutableStateOf("Console") }
    var selectedServer by remember { mutableStateOf("Leachy | Paid | Dirt") }

    val userMenuCategories = remember {
        mapOf(
            "General" to listOf(
                PanelMenuItem("Workspace", Icons.Default.GridView, "General"),
                PanelMenuItem("Console", Icons.Default.Terminal, "General"),
                PanelMenuItem("Settings", Icons.Default.Settings, "General"),
                PanelMenuItem("Activity Log", Icons.Default.History, "General")
            ),
            "Management" to listOf(
                PanelMenuItem("File Manager", Icons.Default.Folder, "Management"),
                PanelMenuItem("Databases", Icons.Default.Storage, "Management"),
                PanelMenuItem("Backups", Icons.Default.CloudDownload, "Management"),
                PanelMenuItem("Network", Icons.Default.Router, "Management"),
                PanelMenuItem("Subdomain", Icons.Default.Public, "Management"),
                PanelMenuItem("Staff Request", Icons.Default.SupportAgent, "Management"),
                PanelMenuItem("Server Importer", Icons.Default.FileUpload, "Management"),
                PanelMenuItem("Custom Mod Manager", Icons.Default.Extension, "Management"),
                PanelMenuItem("Server Splitter", Icons.Default.CallSplit, "Management"),
                PanelMenuItem("Server Wiper", Icons.Default.CleaningServices, "Management"),
                PanelMenuItem("Reverse Proxy", Icons.Default.Dns, "Management"),
                PanelMenuItem("FastDL", Icons.Default.Speed, "Management")
            ),
            "Configuration" to listOf(
                PanelMenuItem("Schedules", Icons.Default.Schedule, "Configuration"),
                PanelMenuItem("Users", Icons.Default.People, "Configuration"),
                PanelMenuItem("Startup", Icons.Default.PowerSettingsNew, "Configuration"),
                PanelMenuItem("Config Editor", Icons.Default.EditNote, "Configuration")
            ),
            "Security" to listOf(
                PanelMenuItem("Network Statistics", Icons.Default.Security, "Security")
            ),
            "Minecraft" to listOf(
                PanelMenuItem("Configuration", Icons.Default.Tune, "Minecraft"),
                PanelMenuItem("Version Changer", Icons.Default.SystemUpdate, "Minecraft"),
                PanelMenuItem("Plugin Installer", Icons.Default.AddBox, "Minecraft")
            )
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("REN CLOUD PANEL", fontSize = 16.sp, fontWeight = FontWeight.Black, color = Color.White)
                        Text(selectedServer, fontSize = 11.sp, color = ElectricCyan, fontWeight = FontWeight.Bold)
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = Color.White)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = MetallicNavy)
            )
        },
        containerColor = MetallicNavy
    ) { innerPadding ->
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            // Sidebar based on screenshot user.png
            Column(
                modifier = Modifier
                    .width(220.dp)
                    .fillMaxHeight()
                    .background(MetallicBlack)
                    .verticalScroll(rememberScrollState())
                    .padding(12.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                userMenuCategories.forEach { (catName, items) ->
                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text(
                            text = catName.uppercase(),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold,
                            color = TextMutedDark,
                            letterSpacing = 1.sp,
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                        )

                        items.forEach { item ->
                            val isSelected = selectedTab == item.title
                            Surface(
                                onClick = { selectedTab = item.title },
                                color = if (isSelected) MetallicPurple else Color.Transparent,
                                shape = RoundedCornerShape(10.dp),
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Row(
                                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 8.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                                ) {
                                    Icon(
                                        imageVector = item.icon,
                                        contentDescription = item.title,
                                        tint = if (isSelected) Color.White else TextSecondaryDark,
                                        modifier = Modifier.size(18.dp)
                                    )
                                    Text(
                                        text = item.title,
                                        fontSize = 12.sp,
                                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                                        color = if (isSelected) Color.White else TextSecondaryDark
                                    )
                                }
                            }
                        }
                    }
                }
            }

            Divider(modifier = Modifier.fillMaxHeight().width(1.dp), color = MetallicBorderDark)

            // Content Panel Area
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight()
                    .padding(16.dp)
            ) {
                when (selectedTab) {
                    "Console" -> ConsoleTabContent()
                    "File Manager" -> SimplePanelPlaceholder("File Manager", Icons.Default.Folder, "Browse and edit server configuration files & directories.")
                    "Databases" -> SimplePanelPlaceholder("Databases", Icons.Default.Storage, "Manage MySQL/MariaDB database credentials & connections.")
                    "Backups" -> SimplePanelPlaceholder("Backups", Icons.Default.CloudDownload, "Create, restore, or download automated server backups.")
                    "Network" -> SimplePanelPlaceholder("Network", Icons.Default.Router, "Configure server IP allocations and port forwardings.")
                    "Plugin Installer" -> SimplePanelPlaceholder("Plugin Installer", Icons.Default.AddBox, "Search and install Spigot/Paper plugins with 1-tap.")
                    else -> SimplePanelPlaceholder(selectedTab, Icons.Default.Tune, "Feature module active for $selectedServer.")
                }
            }
        }
    }
}

@Composable
private fun ConsoleTabContent() {
    var commandInput by remember { mutableStateOf("") }
    val logs = remember {
        mutableStateListOf(
            "[10:14:02 INFO]: Starting Minecraft server version 1.20.4",
            "[10:14:03 INFO]: Loading properties from server.properties",
            "[10:14:04 INFO]: Default game type: SURVIVAL",
            "[10:14:05 INFO]: Generating keypair...",
            "[10:14:06 INFO]: Starting Minecraft server on *:25565",
            "[10:14:07 INFO]: Using epoll channel type",
            "[10:14:08 INFO]: Preparing level \"world\"",
            "[10:14:09 INFO]: Preparing start region for level 0",
            "[10:14:10 INFO]: Time elapsed: 4210 ms",
            "[10:14:10 INFO]: Done (4.21s)! For help, type \"help\""
        )
    }

    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Status Row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Box(modifier = Modifier.size(10.dp).background(RenCloudGreen, CircleShape))
                Text("RUNNING", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = RenCloudGreen)
            }

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Button(onClick = {}, colors = ButtonDefaults.buttonColors(containerColor = RenCloudGreen), shape = RoundedCornerShape(8.dp)) {
                    Text("START", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = Color.Black)
                }
                Button(onClick = {}, colors = ButtonDefaults.buttonColors(containerColor = RenCloudGold), shape = RoundedCornerShape(8.dp)) {
                    Text("RESTART", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = Color.Black)
                }
                Button(onClick = {}, colors = ButtonDefaults.buttonColors(containerColor = RenCloudRed), shape = RoundedCornerShape(8.dp)) {
                    Text("STOP", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = Color.White)
                }
            }
        }

        // Terminal Log Container
        Surface(
            modifier = Modifier.weight(1f).fillMaxWidth(),
            color = Color.Black,
            shape = RoundedCornerShape(12.dp),
            border = BorderStroke(1.dp, MetallicBorderDark)
        ) {
            LazyColumn(
                modifier = Modifier.padding(12.dp),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                items(logs) { log ->
                    Text(
                        text = log,
                        fontSize = 11.sp,
                        color = if (log.contains("INFO")) ElectricCyan else Color.White,
                        fontWeight = FontWeight.Medium
                    )
                }
            }
        }

        // Command Bar
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            OutlinedTextField(
                value = commandInput,
                onValueChange = { commandInput = it },
                placeholder = { Text("Type command (e.g. op player)...", color = TextSecondaryDark, fontSize = 12.sp) },
                singleLine = true,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = ElectricCyan,
                    unfocusedBorderColor = MetallicBorderDark,
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White
                ),
                modifier = Modifier.weight(1f)
            )
            Button(
                onClick = {
                    if (commandInput.isNotBlank()) {
                        logs.add("[CONSOLESAY]: $commandInput")
                        commandInput = ""
                    }
                },
                colors = ButtonDefaults.buttonColors(containerColor = ElectricCyan),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text("SEND", color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 11.sp)
            }
        }
    }
}

@Composable
private fun SimplePanelPlaceholder(title: String, icon: ImageVector, description: String) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(icon, contentDescription = null, tint = ElectricCyan, modifier = Modifier.size(54.dp))
        Spacer(Modifier.height(12.dp))
        Text(title, fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Color.White)
        Text(description, fontSize = 12.sp, color = TextSecondaryDark)
    }
}
