package com.rencloud.app.ui.admin

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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.painterResource
import androidx.compose.foundation.Image
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.R
import com.rencloud.app.data.model.PanelUserAttributes
import com.rencloud.app.data.model.RenCloudPlan
import com.rencloud.app.data.remote.*
import com.rencloud.app.ui.components.AnnouncementItem
import com.rencloud.app.ui.components.glass.*
import com.rencloud.app.ui.showcase.FaqItem
import com.rencloud.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdminControlCenter(
    adminViewModel: AdminViewModel,
    onNavigateBack: () -> Unit = {}
) {
    val state by adminViewModel.uiState.collectAsState()
    
    // Dialog state handlers
    var editingPlan by remember { mutableStateOf<RenCloudPlan?>(null) }
    var isAddPlanOpen by remember { mutableStateOf(false) }
    var planToDelete by remember { mutableStateOf<RenCloudPlan?>(null) }
    
    var editingFaq by remember { mutableStateOf<FaqItem?>(null) }
    var isAddFaqOpen by remember { mutableStateOf(false) }
    
    var isAddAnnOpen by remember { mutableStateOf(false) }
    var isAddCatOpen by remember { mutableStateOf(false) }
    var isAddRelOpen by remember { mutableStateOf(false) }
    var isAddRoleOpen by remember { mutableStateOf(false) }
    var userToToggleAdmin by remember { mutableStateOf<PanelUserAttributes?>(null) }

    LiquidGlassBackground {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = {
                        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            Icon(Icons.Default.AdminPanelSettings, contentDescription = null, tint = RenCloudGold)
                            Text("Admin Control Center v4.1", fontSize = 17.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        }
                    },
                    navigationIcon = {
                        IconButton(onClick = onNavigateBack) {
                            Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = Color.White)
                        }
                    },
                    actions = {
                        IconButton(onClick = { adminViewModel.refreshAllData() }) {
                            Icon(Icons.Default.Refresh, contentDescription = "Refresh", tint = ElectricCyan)
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.Transparent)
                )
            },
            floatingActionButton = {
                when (state.activeTab) {
                    1 -> FloatingActionButton(onClick = { isAddPlanOpen = true }, containerColor = ElectricCyan, contentColor = Color.Black) { Icon(Icons.Default.Add, contentDescription = "Add Plan") }
                    3 -> FloatingActionButton(onClick = { isAddFaqOpen = true }, containerColor = ElectricCyan, contentColor = Color.Black) { Icon(Icons.Default.Add, contentDescription = "Add FAQ") }
                    4 -> FloatingActionButton(onClick = { isAddAnnOpen = true }, containerColor = ElectricCyan, contentColor = Color.Black) { Icon(Icons.Default.Add, contentDescription = "Add Banner") }
                    5 -> FloatingActionButton(onClick = { isAddCatOpen = true }, containerColor = ElectricCyan, contentColor = Color.Black) { Icon(Icons.Default.Add, contentDescription = "Add Category") }
                    6 -> FloatingActionButton(onClick = { isAddRelOpen = true }, containerColor = ElectricCyan, contentColor = Color.Black) { Icon(Icons.Default.Add, contentDescription = "Add Release Note") }
                    8 -> FloatingActionButton(onClick = { isAddRoleOpen = true }, containerColor = RenCloudGold, contentColor = Color.Black) { Icon(Icons.Default.AddModerator, contentDescription = "Add Staff Role") }
                }
            },
            containerColor = Color.Transparent
        ) { innerPadding ->

            Column(modifier = Modifier.fillMaxSize().padding(innerPadding)) {
                // Scrollable Tab Menu for all 9 sections
                ScrollableTabRow(
                    selectedTabIndex = state.activeTab,
                    containerColor = Color.Transparent,
                    contentColor = ElectricCyan,
                    edgePadding = 16.dp,
                    divider = {}
                ) {
                    Tab(selected = state.activeTab == 0, onClick = { adminViewModel.setActiveTab(0) }, text = { Text("Overview", fontWeight = FontWeight.Bold) })
                    Tab(selected = state.activeTab == 1, onClick = { adminViewModel.setActiveTab(1) }, text = { Text("Plans (${state.plans.size})", fontWeight = FontWeight.Bold) })
                    Tab(selected = state.activeTab == 2, onClick = { adminViewModel.setActiveTab(2) }, text = { Text("Users (${state.totalUsersCount})", fontWeight = FontWeight.Bold) })
                    Tab(selected = state.activeTab == 3, onClick = { adminViewModel.setActiveTab(3) }, text = { Text("FAQs (${state.faqs.size})", fontWeight = FontWeight.Bold) })
                    Tab(selected = state.activeTab == 4, onClick = { adminViewModel.setActiveTab(4) }, text = { Text("Banners (${state.announcements.size})", fontWeight = FontWeight.Bold) })
                    Tab(selected = state.activeTab == 5, onClick = { adminViewModel.setActiveTab(5) }, text = { Text("Categories (${state.categories.size})", fontWeight = FontWeight.Bold) })
                    Tab(selected = state.activeTab == 6, onClick = { adminViewModel.setActiveTab(6) }, text = { Text("What's New", fontWeight = FontWeight.Bold) })
                    Tab(selected = state.activeTab == 7, onClick = { adminViewModel.setActiveTab(7) }, text = { Text("Infra Telemetry", fontWeight = FontWeight.Bold) })
                    Tab(selected = state.activeTab == 8, onClick = { adminViewModel.setActiveTab(8) }, text = { Text("Audit Logs (${state.activityLogs.size})", fontWeight = FontWeight.Bold) })
                    Tab(selected = state.activeTab == 9, onClick = { adminViewModel.setActiveTab(9) }, text = { Text("Staff Roles", fontWeight = FontWeight.Bold) })
                }

                Spacer(Modifier.height(8.dp))

                state.errorMessage?.let { err ->
                    Surface(color = RenCloudRed.copy(alpha = 0.2f), shape = RoundedCornerShape(8.dp), modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 4.dp)) {
                        Text(err, color = RenCloudRed, fontSize = 12.sp, modifier = Modifier.padding(10.dp), fontWeight = FontWeight.SemiBold)
                    }
                }

                state.successMessage?.let { msg ->
                    Surface(color = RenCloudGreen.copy(alpha = 0.2f), shape = RoundedCornerShape(8.dp), modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 4.dp)) {
                        Text(msg, color = RenCloudGreen, fontSize = 12.sp, modifier = Modifier.padding(10.dp), fontWeight = FontWeight.SemiBold)
                    }
                }

                LazyColumn(modifier = Modifier.fillMaxSize(), contentPadding = PaddingValues(bottom = 80.dp)) {
                    when (state.activeTab) {
                        0 -> item { OverviewDashboardTab(state) }
                        1 -> {
                            items(state.filteredPlans) { plan ->
                                AdminPlanCard(plan, onEdit = { editingPlan = plan }, onToggleActive = { adminViewModel.togglePlanActive(plan.id) }, onDelete = { planToDelete = plan }, modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp))
                            }
                        }
                        2 -> {
                            items(state.filteredUsers) { user ->
                                AdminUserCard(user, onToggleAdmin = { userToToggleAdmin = user }, modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp))
                            }
                        }
                        3 -> {
                            items(state.filteredFaqs) { faq ->
                                AdminFaqCard(faq, onEdit = { editingFaq = faq }, onDelete = { adminViewModel.deleteFaq(faq.id) }, modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp))
                            }
                        }
                        4 -> {
                            items(state.announcements) { ann ->
                                AdminAnnouncementCard(ann, onDelete = { adminViewModel.deleteAnnouncement(ann.id) }, modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp))
                            }
                        }
                        5 -> {
                            items(state.categories) { cat ->
                                AdminCategoryCard(cat, onDelete = { adminViewModel.deleteCategory(cat.id) }, modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp))
                            }
                        }
                        6 -> {
                            items(state.releaseNotes) { note ->
                                AdminReleaseNoteCard(note, modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp))
                            }
                        }
                        7 -> item { AdminInfraTelemetrySection(state.infraTelemetry) }
                        8 -> {
                            items(state.activityLogs) { log ->
                                AdminActivityLogCard(log, modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp))
                            }
                        }
                        9 -> {
                            items(state.staffRoles) { role ->
                                AdminStaffRoleCard(role, modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp))
                            }
                        }
                    }
                }
            }
        }
    }

    // Modal Form & Action Dialogs
    if (isAddPlanOpen || editingPlan != null) {
        PlanFormDialog(
            initialPlan = editingPlan,
            onDismiss = { isAddPlanOpen = false; editingPlan = null },
            onSave = { plan ->
                adminViewModel.savePlan(plan, editingPlan != null)
                isAddPlanOpen = false
                editingPlan = null
            }
        )
    }

    planToDelete?.let { plan ->
        GlassConfirmDialog(
            title = "Delete Catalog Plan",
            message = "Are you sure you want to deactivate/delete plan '${plan.name}'? Users will no longer see this plan in the catalog.",
            onConfirm = {
                adminViewModel.deletePlan(plan.id)
                planToDelete = null
            },
            onDismiss = { planToDelete = null },
            confirmText = "DELETE PLAN",
            confirmColor = RenCloudRed
        )
    }

    userToToggleAdmin?.let { user ->
        val newAdminState = !user.rootAdmin
        GlassConfirmDialog(
            title = if (newAdminState) "Grant Root Admin" else "Revoke Root Admin",
            message = "Are you sure you want to ${if (newAdminState) "promote" else "demote"} @${user.username} ${if (newAdminState) "to Root Admin" else "from Root Admin"}?",
            onConfirm = {
                adminViewModel.toggleUserRootAdmin(user.id, user.rootAdmin)
                userToToggleAdmin = null
            },
            onDismiss = { userToToggleAdmin = null },
            confirmText = if (newAdminState) "GRANT ADMIN" else "REVOKE ADMIN",
            confirmColor = if (newAdminState) RenCloudGold else RenCloudRed
        )
    }

    if (isAddFaqOpen || editingFaq != null) {
        FaqFormDialog(
            initialFaq = editingFaq,
            onDismiss = { isAddFaqOpen = false; editingFaq = null },
            onSave = { faq ->
                adminViewModel.saveFaq(faq, editingFaq != null)
                isAddFaqOpen = false
                editingFaq = null
            }
        )
    }

    if (isAddAnnOpen) {
        AnnouncementFormDialog(onDismiss = { isAddAnnOpen = false }, onSave = { ann -> adminViewModel.saveAnnouncement(ann); isAddAnnOpen = false })
    }

    if (isAddCatOpen) {
        SimpleInputDialog(title = "Create New Category", label = "Category Name", onDismiss = { isAddCatOpen = false }, onConfirm = { adminViewModel.createCategory(it); isAddCatOpen = false })
    }

    if (isAddRelOpen) {
        ReleaseNoteFormDialog(onDismiss = { isAddRelOpen = false }, onSave = { note -> adminViewModel.saveReleaseNote(note); isAddRelOpen = false })
    }

    if (isAddRoleOpen) {
        StaffRoleFormDialog(onDismiss = { isAddRoleOpen = false }, onSave = { name, perms -> adminViewModel.createStaffRole(name, perms); isAddRoleOpen = false })
    }
}

@Composable
private fun OverviewDashboardTab(state: AdminUiState) {
    Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        GlassCard(modifier = Modifier.fillMaxWidth(), accentGlow = RenCloudGold, alpha = 0.85f) {
            Row(modifier = Modifier.padding(18.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween) {
                Column(modifier = Modifier.weight(1f)) {
                    Surface(color = RenCloudGold.copy(alpha = 0.15f), shape = RoundedCornerShape(6.dp)) {
                        Text("SUPER ADMIN CENTER", fontSize = 8.sp, fontWeight = FontWeight.Bold, color = RenCloudGold, letterSpacing = 1.5.sp, modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp))
                    }
                    Spacer(Modifier.height(6.dp))
                    Text("RenCloud Control Hub", fontSize = 20.sp, fontWeight = FontWeight.Black, color = Color.White)
                    Text("Full 7-Feature Admin Suite Synced with Backend", fontSize = 11.sp, color = TextSecondaryDark)
                }
                Image(painter = painterResource(id = R.drawable.rencloud_logo), contentDescription = "RenCloud", modifier = Modifier.size(50.dp))
            }
        }

        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            AdminMetricCard("Users", state.totalUsersCount.toString(), Icons.Default.Group, ElectricCyan, Modifier.weight(1f))
            AdminMetricCard("Plans", state.plans.size.toString(), Icons.Default.List, MetallicPurple, Modifier.weight(1f))
        }

        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            AdminMetricCard("FAQs", state.faqs.size.toString(), Icons.Default.HelpOutline, RenCloudGreen, Modifier.weight(1f))
            AdminMetricCard("Banners", state.announcements.size.toString(), Icons.Default.Campaign, RenCloudGold, Modifier.weight(1f))
        }
    }
}

@Composable
private fun AdminInfraTelemetrySection(telemetry: InfraTelemetryData?) {
    Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("Node & Location Capacity Dashboard", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White)
        
        telemetry?.nodes?.forEach { node ->
            GlassCard(modifier = Modifier.fillMaxWidth(), accentGlow = ElectricCyan) {
                Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Node: ${node.name}", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        Surface(color = ElectricCyan.copy(0.15f), shape = RoundedCornerShape(4.dp)) {
                            Text("${node.server_count} Servers", color = ElectricCyan, fontSize = 10.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp))
                        }
                    }

                    val ramPct = if (node.memory_total_mb > 0) (node.memory_used_mb.toFloat() / node.memory_total_mb.toFloat()).coerceIn(0f, 1f) else 0f
                    Text("RAM Allocation (${node.memory_used_mb / 1024}GB / ${node.memory_total_mb / 1024}GB)", color = TextSecondaryDark, fontSize = 11.sp)
                    LinearProgressIndicator(progress = { ramPct }, color = ElectricCyan, trackColor = MetallicBorderDark, modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(3.dp)))
                }
            }
        }
    }
}

@Composable private fun AdminPlanCard(plan: RenCloudPlan, onEdit: () -> Unit, onToggleActive: () -> Unit, onDelete: () -> Unit, modifier: Modifier = Modifier) {
    GlassCard(modifier = modifier.fillMaxWidth(), accentGlow = if (plan.isActive) ElectricCyan else null) {
        Row(modifier = Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text(plan.name, fontSize = 15.sp, fontWeight = FontWeight.Bold, color = Color.White)
                    if (plan.isFeatured) {
                        Surface(color = RenCloudGold.copy(0.2f), shape = RoundedCornerShape(4.dp)) {
                            Text("FEATURED", color = RenCloudGold, fontSize = 8.sp, fontWeight = FontWeight.Bold, modifier = Modifier.padding(horizontal = 4.dp, vertical = 1.dp))
                        }
                    }
                }
                Text("${plan.categoryName} • ₹${plan.monthlyPriceInr}/mo ($${plan.monthlyPriceUsd})", fontSize = 11.sp, color = ElectricCyan, fontWeight = FontWeight.SemiBold)
                Text("${plan.ram} • ${plan.cpu} • ${plan.nvmeStorage}", fontSize = 10.sp, color = TextSecondaryDark)
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                Switch(checked = plan.isActive, onCheckedChange = { onToggleActive() })
                IconButton(onClick = onEdit) { Icon(Icons.Default.Edit, contentDescription = null, tint = ElectricCyan) }
                IconButton(onClick = onDelete) { Icon(Icons.Default.Delete, contentDescription = null, tint = RenCloudRed) }
            }
        }
    }
}

@Composable private fun AdminUserCard(user: PanelUserAttributes, onToggleAdmin: () -> Unit, modifier: Modifier = Modifier) {
    GlassCard(modifier = modifier.fillMaxWidth(), accentGlow = if (user.rootAdmin) RenCloudGold else null) {
        Row(modifier = Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            Column(modifier = Modifier.weight(1f)) {
                Text(user.username, fontSize = 14.sp, fontWeight = FontWeight.Bold, color = Color.White)
                Text(user.email, fontSize = 11.sp, color = TextSecondaryDark)
            }
            IconButton(onClick = onToggleAdmin) { Icon(Icons.Default.Shield, contentDescription = null, tint = if (user.rootAdmin) RenCloudGold else TextSecondaryDark) }
        }
    }
}

@Composable private fun AdminFaqCard(faq: FaqItem, onEdit: () -> Unit, onDelete: () -> Unit, modifier: Modifier = Modifier) {
    GlassCard(modifier = modifier.fillMaxWidth()) {
        Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text(faq.question, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp, modifier = Modifier.weight(1f))
                Row {
                    IconButton(onClick = onEdit) { Icon(Icons.Default.Edit, contentDescription = null, tint = ElectricCyan, modifier = Modifier.size(18.dp)) }
                    IconButton(onClick = onDelete) { Icon(Icons.Default.Delete, contentDescription = null, tint = RenCloudRed, modifier = Modifier.size(18.dp)) }
                }
            }
            Text(faq.answer, color = TextSecondaryDark, fontSize = 11.sp)
        }
    }
}

@Composable private fun AdminAnnouncementCard(ann: AnnouncementItem, onDelete: () -> Unit, modifier: Modifier = Modifier) {
    GlassCard(modifier = modifier.fillMaxWidth(), accentGlow = ElectricCyan) {
        Row(modifier = Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween) {
            Text(ann.message, color = Color.White, fontSize = 12.sp, modifier = Modifier.weight(1f))
            IconButton(onClick = onDelete) { Icon(Icons.Default.Delete, contentDescription = null, tint = RenCloudRed) }
        }
    }
}

@Composable private fun AdminCategoryCard(cat: CategoryItem, onDelete: () -> Unit, modifier: Modifier = Modifier) {
    GlassCard(modifier = modifier.fillMaxWidth()) {
        Row(modifier = Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween) {
            Text(cat.name, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
            IconButton(onClick = onDelete) { Icon(Icons.Default.Delete, contentDescription = null, tint = RenCloudRed) }
        }
    }
}

@Composable private fun AdminReleaseNoteCard(note: ReleaseNoteItem, modifier: Modifier = Modifier) {
    GlassCard(modifier = modifier.fillMaxWidth(), accentGlow = RenCloudGold) {
        Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Text("v${note.version_name} (Code: ${note.version_code})", color = RenCloudGold, fontWeight = FontWeight.Bold, fontSize = 14.sp)
            Text(note.changelog, color = Color.White, fontSize = 11.sp)
        }
    }
}

@Composable private fun AdminActivityLogCard(log: ActivityLogItem, modifier: Modifier = Modifier) {
    GlassCard(modifier = modifier.fillMaxWidth()) {
        Column(modifier = Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text("@${log.admin_username} • ${log.action_type}", color = ElectricCyan, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                Text(log.timestamp.take(16).replace("T", " "), color = TextMutedDark, fontSize = 10.sp)
            }
            Text(log.details, color = Color.White, fontSize = 11.sp)
        }
    }
}

@Composable private fun AdminStaffRoleCard(role: StaffRoleItem, modifier: Modifier = Modifier) {
    GlassCard(modifier = modifier.fillMaxWidth(), accentGlow = RenCloudGold) {
        Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Text(role.name, color = RenCloudGold, fontWeight = FontWeight.Bold, fontSize = 14.sp)
            Text(role.description, color = TextSecondaryDark, fontSize = 11.sp)
            Text("Permissions: ${role.permissions.joinToString(", ")}", color = Color.White, fontSize = 10.sp, fontWeight = FontWeight.SemiBold)
        }
    }
}

@Composable private fun AdminMetricCard(title: String, value: String, icon: ImageVector, color: Color, modifier: Modifier = Modifier) {
    GlassCard(modifier = modifier, accentGlow = color, alpha = 0.8f) {
        Column(modifier = Modifier.padding(14.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Icon(icon, contentDescription = null, tint = color, modifier = Modifier.size(20.dp))
            Text(value, fontSize = 20.sp, fontWeight = FontWeight.Black, color = Color.White)
            Text(title, fontSize = 10.sp, color = TextSecondaryDark, fontWeight = FontWeight.Medium)
        }
    }
}

@Composable private fun PlanFormDialog(initialPlan: RenCloudPlan?, onDismiss: () -> Unit, onSave: (RenCloudPlan) -> Unit) {
    var name by remember { mutableStateOf(initialPlan?.name ?: "") }
    var category by remember { mutableStateOf(initialPlan?.categoryName ?: "Minecraft Budget") }
    var priceInr by remember { mutableStateOf(initialPlan?.monthlyPriceInr?.toString() ?: "100") }
    var priceUsd by remember { mutableStateOf(initialPlan?.monthlyPriceUsd?.toString() ?: "1.25") }
    var ram by remember { mutableStateOf(initialPlan?.ram ?: "4 GB DDR4") }
    var cpu by remember { mutableStateOf(initialPlan?.cpu ?: "2 Cores") }
    var storage by remember { mutableStateOf(initialPlan?.nvmeStorage ?: "20 GB NVMe") }
    var bandwidth by remember { mutableStateOf(initialPlan?.bandwidth ?: "Unmetered") }
    var slots by remember { mutableStateOf(initialPlan?.slots ?: "Unlimited") }
    var tagline by remember { mutableStateOf(initialPlan?.tagline ?: "RenCloud Plan") }
    var location by remember { mutableStateOf(initialPlan?.location ?: "India") }
    var isFeatured by remember { mutableStateOf(initialPlan?.isFeatured ?: false) }
    var isActive by remember { mutableStateOf(initialPlan?.isActive ?: true) }

    GlassDialog(onDismissRequest = onDismiss, accentGlow = ElectricCyan) {
        Column(
            modifier = Modifier
                .padding(20.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Text(if (initialPlan != null) "Edit Catalog Plan" else "Create Catalog Plan", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color.White)
            
            OutlinedTextField(value = name, onValueChange = { name = it }, label = { Text("Plan Name") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = category, onValueChange = { category = it }, label = { Text("Category (e.g. Minecraft Budget)") }, modifier = Modifier.fillMaxWidth())
            
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(value = priceInr, onValueChange = { priceInr = it }, label = { Text("Price (INR ₹)") }, modifier = Modifier.weight(1f))
                OutlinedTextField(value = priceUsd, onValueChange = { priceUsd = it }, label = { Text("Price (USD $)") }, modifier = Modifier.weight(1f))
            }

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(value = ram, onValueChange = { ram = it }, label = { Text("RAM (e.g. 4 GB DDR4)") }, modifier = Modifier.weight(1f))
                OutlinedTextField(value = cpu, onValueChange = { cpu = it }, label = { Text("CPU (e.g. 2 vCores)") }, modifier = Modifier.weight(1f))
            }

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(value = storage, onValueChange = { storage = it }, label = { Text("Storage (NVMe)") }, modifier = Modifier.weight(1f))
                OutlinedTextField(value = bandwidth, onValueChange = { bandwidth = it }, label = { Text("Bandwidth") }, modifier = Modifier.weight(1f))
            }

            OutlinedTextField(value = slots, onValueChange = { slots = it }, label = { Text("Databases / Tier Specs") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = tagline, onValueChange = { tagline = it }, label = { Text("Tagline / Subtitle") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = location, onValueChange = { location = it }, label = { Text("Datacenter Location") }, modifier = Modifier.fillMaxWidth())

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Text("Featured Plan Overlay", color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                Switch(checked = isFeatured, onCheckedChange = { isFeatured = it })
            }

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Text("Active / Published in Catalog", color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                Switch(checked = isActive, onCheckedChange = { isActive = it })
            }

            Spacer(Modifier.height(6.dp))

            GlassButton(
                onClick = {
                    val savedPlan = RenCloudPlan(
                        id = initialPlan?.id ?: "plan_${System.currentTimeMillis()}",
                        name = name.ifBlank { "RenCloud Custom Plan" },
                        categoryName = category.ifBlank { "Minecraft Budget" },
                        monthlyPriceInr = priceInr.toIntOrNull() ?: 100,
                        monthlyPriceUsd = priceUsd.toDoubleOrNull() ?: 1.25,
                        ram = ram.ifBlank { "4 GB DDR4" },
                        cpu = cpu.ifBlank { "2 Cores" },
                        nvmeStorage = storage.ifBlank { "20 GB NVMe" },
                        bandwidth = bandwidth.ifBlank { "Unmetered" },
                        slots = slots.ifBlank { "Unlimited" },
                        isFeatured = isFeatured,
                        tagline = tagline.ifBlank { "RenCloud Showcase Plan" },
                        location = location.ifBlank { "India" },
                        displayOrder = initialPlan?.displayOrder ?: 0,
                        isActive = isActive
                    )
                    onSave(savedPlan)
                },
                containerColor = ElectricCyan,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(if (initialPlan != null) "UPDATE PLAN" else "CREATE PLAN", color = Color.Black, fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable private fun FaqFormDialog(initialFaq: FaqItem?, onDismiss: () -> Unit, onSave: (FaqItem) -> Unit) {
    var question by remember { mutableStateOf(initialFaq?.question ?: "") }
    var answer by remember { mutableStateOf(initialFaq?.answer ?: "") }
    var category by remember { mutableStateOf(initialFaq?.category ?: "Hosting") }

    GlassDialog(onDismissRequest = onDismiss, accentGlow = ElectricCyan) {
        Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text(if (initialFaq != null) "Edit FAQ" else "Create FAQ", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color.White)
            OutlinedTextField(value = question, onValueChange = { question = it }, label = { Text("Question") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = answer, onValueChange = { answer = it }, label = { Text("Answer") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = category, onValueChange = { category = it }, label = { Text("Category (Hosting/Billing/Servers)") }, modifier = Modifier.fillMaxWidth())
            GlassButton(onClick = { onSave(FaqItem(id = initialFaq?.id ?: "faq_${System.currentTimeMillis()}", question = question, answer = answer, category = category)) }, containerColor = ElectricCyan, modifier = Modifier.fillMaxWidth()) { Text("SAVE FAQ", color = Color.Black, fontWeight = FontWeight.Bold) }
        }
    }
}

@Composable private fun AnnouncementFormDialog(onDismiss: () -> Unit, onSave: (AnnouncementItem) -> Unit) {
    var message by remember { mutableStateOf("") }
    GlassDialog(onDismissRequest = onDismiss, accentGlow = ElectricCyan) {
        Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text("New Announcement Banner", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color.White)
            OutlinedTextField(value = message, onValueChange = { message = it }, label = { Text("Message Text") }, modifier = Modifier.fillMaxWidth())
            GlassButton(onClick = { onSave(AnnouncementItem(id = "ann_${System.currentTimeMillis()}", message = message, style = "info")) }, containerColor = ElectricCyan, modifier = Modifier.fillMaxWidth()) { Text("PUBLISH BANNER", color = Color.Black, fontWeight = FontWeight.Bold) }
        }
    }
}

@Composable private fun ReleaseNoteFormDialog(onDismiss: () -> Unit, onSave: (ReleaseNoteItem) -> Unit) {
    var verName by remember { mutableStateOf("4.0") }
    var changelog by remember { mutableStateOf("") }
    GlassDialog(onDismissRequest = onDismiss, accentGlow = ElectricCyan) {
        Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text("Publish Release Notes", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color.White)
            OutlinedTextField(value = verName, onValueChange = { verName = it }, label = { Text("Version Name (e.g. 4.0)") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = changelog, onValueChange = { changelog = it }, label = { Text("Changelog Notes") }, modifier = Modifier.fillMaxWidth())
            GlassButton(onClick = { onSave(ReleaseNoteItem(id = "rel_${System.currentTimeMillis()}", version_code = 40000, version_name = verName, changelog = changelog)) }, containerColor = ElectricCyan, modifier = Modifier.fillMaxWidth()) { Text("PUBLISH NOTES", color = Color.Black, fontWeight = FontWeight.Bold) }
        }
    }
}

@Composable private fun StaffRoleFormDialog(onDismiss: () -> Unit, onSave: (String, List<String>) -> Unit) {
    var roleName by remember { mutableStateOf("") }
    GlassDialog(onDismissRequest = onDismiss, accentGlow = RenCloudGold) {
        Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text("Create Staff Role Tier", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color.White)
            OutlinedTextField(value = roleName, onValueChange = { roleName = it }, label = { Text("Role Name (e.g. Support Manager)") }, modifier = Modifier.fillMaxWidth())
            GlassButton(onClick = { onSave(roleName, listOf("plans.write", "faq.write")) }, containerColor = RenCloudGold, modifier = Modifier.fillMaxWidth()) { Text("CREATE ROLE", color = Color.Black, fontWeight = FontWeight.Bold) }
        }
    }
}

@Composable private fun SimpleInputDialog(title: String, label: String, onDismiss: () -> Unit, onConfirm: (String) -> Unit) {
    var input by remember { mutableStateOf("") }
    GlassDialog(onDismissRequest = onDismiss) {
        Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text(title, fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color.White)
            OutlinedTextField(value = input, onValueChange = { input = it }, label = { Text(label) }, modifier = Modifier.fillMaxWidth())
            GlassButton(onClick = { onConfirm(input) }, containerColor = ElectricCyan, modifier = Modifier.fillMaxWidth()) { Text("CONFIRM", color = Color.Black, fontWeight = FontWeight.Bold) }
        }
    }
}

