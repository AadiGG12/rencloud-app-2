package com.rencloud.app.ui.home

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.zIndex
import com.rencloud.app.R
import com.rencloud.app.data.model.RenCloudPlan
import com.rencloud.app.ui.auth.AuthViewModel
import com.rencloud.app.ui.components.BoomMenu
import com.rencloud.app.ui.components.BoomMenuItem
import com.rencloud.app.ui.theme.*
import com.rencloud.app.ui.showcase.*
import android.content.Intent
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.abs

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    catalogViewModel: CatalogViewModel,
    authViewModel: AuthViewModel,
    onNavigateAdmin: () -> Unit,
    onNavigateCalculator: () -> Unit = {},
    onNavigateAuth: () -> Unit
) {
    val catalogState by catalogViewModel.uiState.collectAsState()
    val authState by authViewModel.uiState.collectAsState()
    val configuration = LocalConfiguration.current
    val context = LocalContext.current
    val isLandscape = configuration.orientation == android.content.res.Configuration.ORIENTATION_LANDSCAPE

    var selectedPlanForDeploy by remember { mutableStateOf<RenCloudPlan?>(null) }
    var showDiscordDialog by remember { mutableStateOf(false) }
    var showCompareDialog by remember { mutableStateOf(false) }
    var showSimulatorDialog by remember { mutableStateOf(false) }
    var showPingDialog by remember { mutableStateOf(false) }
    val snackbarHostState = remember { SnackbarHostState() }
    var snackbarMessage by remember { mutableStateOf<String?>(null) }
    val scope = rememberCoroutineScope()

    LaunchedEffect(snackbarMessage) {
        snackbarMessage?.let { msg ->
            snackbarHostState.showSnackbar(msg)
            snackbarMessage = null
        }
    }

    val categories = listOf(
        "All",
        "Minecraft Budget",
        "Minecraft Premium",
        "Minecraft Enterprise",
        "VPS Intel",
        "VPS AMD EPYC",
        "VPS AMD Ryzen",
        "Hytale Hosting",
        "ARK Ascended",
        "Web Hosting",
        "Discord Bot",
        "VIP Memberships",
        "Setup Services"
    )

    val boomMenuItems = remember {
        listOf(
            BoomMenuItem("compare", "Compare Plans", "Side-by-side specs", Icons.Default.Compare, RenCloudGold),
            BoomMenuItem("simulator", "Capacity Simulator", "Estimate resources", Icons.Default.Storage, RenCloudCyan),
            BoomMenuItem("ping", "Datacenter Ping", "Check latency", Icons.Default.NetworkCheck, RenCloudPurple),
            BoomMenuItem("discord", "Discord Community", "24/7 Live Support", Icons.Default.Forum, RenCloudPurple),
            BoomMenuItem("deploy", "Quick Deploy", "Deploy Top Server", Icons.Default.RocketLaunch, RenCloudGreen)
        )
    }

    // Animated gradient background
    val infiniteTransition = rememberInfiniteTransition(label = "bg")

    Scaffold(
        snackbarHost = { SnackbarHost(snackbarHostState) },
        topBar = {
            TopAppBar(
                title = {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        // Real RenCloud PNG Logo
                        Image(
                            painter = painterResource(id = R.drawable.rencloud_logo),
                            contentDescription = "RenCloud",
                            modifier = Modifier.size(36.dp)
                        )
                        Column {
                            Text(
                                "RenCloud",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Black,
                                color = Color.White
                            )
                            Text(
                                "v3.4 Enterprise",
                                fontSize = 9.sp,
                                color = RenCloudCyan,
                                letterSpacing = 1.sp
                            )
                        }
                    }
                },
                actions = {
                    // Currency toggle pill
                    Surface(
                        onClick = { catalogViewModel.toggleCurrency() },
                        color = RenCloudGold.copy(alpha = 0.15f),
                        shape = RoundedCornerShape(20.dp),
                        border = BorderStroke(1.dp, RenCloudGold.copy(alpha = 0.4f))
                    ) {
                        AnimatedContent(
                            targetState = catalogState.currency,
                            transitionSpec = {
                                slideInVertically { -it } + fadeIn() togetherWith
                                slideOutVertically { it } + fadeOut()
                            },
                            label = "currency"
                        ) { currency ->
                            Text(
                                text = if (currency == "INR") "₹ INR" else "$ USD",
                                color = RenCloudGold,
                                fontWeight = FontWeight.Bold,
                                fontSize = 11.sp,
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp)
                            )
                        }
                    }

                    // Admin panel button
                    if (authState.user?.isAdmin == true) {
                        IconButton(onClick = onNavigateAdmin) {
                            Icon(
                                imageVector = Icons.Default.ManageAccounts,
                                contentDescription = "Admin",
                                tint = RenCloudGold
                            )
                        }
                    }

                    // Account button
                    IconButton(onClick = onNavigateAuth) {
                        Icon(
                            imageVector = Icons.Default.AccountCircle,
                            contentDescription = "Account",
                            tint = RenCloudCyan
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = RenCloudNavy
                )
            )
        },
        bottomBar = {
            if (!isLandscape) {
                NavigationBar(
                    containerColor = RenCloudSurfaceDark,
                    contentColor = RenCloudCyan,
                    tonalElevation = 0.dp
                ) {
                    NavigationBarItem(
                        selected = true,
                        onClick = {},
                        icon = { Icon(Icons.Default.Cloud, contentDescription = "Plans") },
                        label = { Text("Plans", fontSize = 10.sp) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = RenCloudCyan,
                            selectedTextColor = RenCloudCyan,
                            indicatorColor = RenCloudCyan.copy(alpha = 0.12f),
                            unselectedIconColor = TextSecondaryDark
                        )
                    )
                    NavigationBarItem(
                        selected = false,
                        onClick = onNavigateCalculator,
                        icon = { Icon(Icons.Default.Calculate, contentDescription = "Calculator") },
                        label = { Text("Calculator", fontSize = 10.sp) },
                        colors = NavigationBarItemDefaults.colors(
                            unselectedIconColor = TextSecondaryDark,
                            unselectedTextColor = TextSecondaryDark
                        )
                    )
                    NavigationBarItem(
                        selected = false,
                        onClick = { showDiscordDialog = true },
                        icon = { Icon(Icons.Default.Forum, contentDescription = "Community") },
                        label = { Text("Community", fontSize = 10.sp) },
                        colors = NavigationBarItemDefaults.colors(
                            unselectedIconColor = TextSecondaryDark,
                            unselectedTextColor = TextSecondaryDark
                        )
                    )
                    NavigationBarItem(
                        selected = false,
                        onClick = onNavigateAuth,
                        icon = { Icon(Icons.Default.Person, contentDescription = "Account") },
                        label = { Text("Account", fontSize = 10.sp) },
                        colors = NavigationBarItemDefaults.colors(
                            unselectedIconColor = TextSecondaryDark,
                            unselectedTextColor = TextSecondaryDark
                        )
                    )
                }
            }
        },
        containerColor = RenCloudNavy
    ) { innerPadding ->

        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            if (isLandscape) {
                Row(modifier = Modifier.fillMaxSize()) {
                    NavigationRail(
                        containerColor = RenCloudSurfaceDark,
                        contentColor = RenCloudCyan
                    ) {
                        Spacer(Modifier.height(8.dp))
                        NavigationRailItem(
                            selected = true,
                            onClick = {},
                            icon = { Icon(Icons.Default.Cloud, contentDescription = "Plans") },
                            label = { Text("Plans", fontSize = 9.sp) },
                            colors = NavigationRailItemDefaults.colors(
                                selectedIconColor = RenCloudCyan,
                                selectedTextColor = RenCloudCyan,
                                indicatorColor = RenCloudCyan.copy(alpha = 0.12f)
                            )
                        )
                        NavigationRailItem(
                            selected = false,
                            onClick = onNavigateCalculator,
                            icon = { Icon(Icons.Default.Calculate, contentDescription = "Calculator") },
                            label = { Text("Calculator", fontSize = 9.sp) }
                        )
                        NavigationRailItem(
                            selected = false,
                            onClick = { showDiscordDialog = true },
                            icon = { Icon(Icons.Default.Forum, contentDescription = "Community") },
                            label = { Text("Discord", fontSize = 9.sp) }
                        )
                        NavigationRailItem(
                            selected = false,
                            onClick = onNavigateAuth,
                            icon = { Icon(Icons.Default.Person, contentDescription = "Account") },
                            label = { Text("Account", fontSize = 9.sp) }
                        )
                    }

                    HomeContent(
                        catalogViewModel = catalogViewModel,
                        categories = categories,
                        currency = catalogState.currency,
                        selectedCategory = catalogState.selectedCategory,
                        searchQuery = catalogState.searchQuery,
                        onPlanDeploy = { selectedPlanForDeploy = it },
                        modifier = Modifier.weight(1f)
                    )
                }
            } else {
                HomeContent(
                    catalogViewModel = catalogViewModel,
                    categories = categories,
                    currency = catalogState.currency,
                    selectedCategory = catalogState.selectedCategory,
                    searchQuery = catalogState.searchQuery,
                    onPlanDeploy = { selectedPlanForDeploy = it },
                    modifier = Modifier.fillMaxSize()
                )
            }

            // BoomMenu Radial Action FAB (Explosion menu)
            BoomMenu(
                items = boomMenuItems,
                onItemClick = { item ->
                    when (item.id) {
                        "compare" -> showCompareDialog = true
                        "simulator" -> showSimulatorDialog = true
                        "ping" -> showPingDialog = true
                        "discord" -> showDiscordDialog = true
                        "currency" -> catalogViewModel.toggleCurrency()
                        "deploy" -> {
                            val topPlan = catalogViewModel.getFilteredPlans().firstOrNull { it.isFeatured }
                                ?: catalogViewModel.getFilteredPlans().firstOrNull()
                            topPlan?.let { selectedPlanForDeploy = it }
                        }
                    }
                },
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(16.dp)
            )
        }
    }

    if (showCompareDialog) {
        PlanComparisonDialog(onDismiss = { showCompareDialog = false })
    }
    if (showSimulatorDialog) {
        CapacitySimulatorDialog(onDismiss = { showSimulatorDialog = false })
    }
    if (showPingDialog) {
        DatacenterPingDialog(onDismiss = { showPingDialog = false })
    }

    // Deploy Dialog
    selectedPlanForDeploy?.let { plan ->
        DeployDialog(
            plan = plan,
            onDismiss = { selectedPlanForDeploy = null },
            onConfirmLaunch = { msg ->
                selectedPlanForDeploy = null
                snackbarMessage = msg
            }
        )
    }

    // Discord Dialog
    if (showDiscordDialog) {
        AlertDialog(
            onDismissRequest = { showDiscordDialog = false },
            title = {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Forum,
                        contentDescription = null,
                        tint = RenCloudPurple,
                        modifier = Modifier.size(28.dp)
                    )
                    Text(
                        "RenCloud Discord",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
            },
            text = {
                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text(
                        "Join our official 24/7 Discord Community for instant support, server status & giveaways:",
                        fontSize = 13.sp,
                        color = TextSecondaryDark
                    )
                    Surface(
                        color = RenCloudCyan.copy(alpha = 0.1f),
                        shape = RoundedCornerShape(10.dp),
                        border = BorderStroke(1.dp, RenCloudCyan.copy(alpha = 0.3f))
                    ) {
                        Text(
                            "https://discord.gg/rencloud",
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            color = RenCloudCyan,
                            modifier = Modifier.padding(12.dp)
                        )
                    }
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                        val clip = ClipData.newPlainText("Discord Link", "https://discord.gg/rencloud")
                        clipboard.setPrimaryClip(clip)
                        showDiscordDialog = false
                        snackbarMessage = "Copied https://discord.gg/rencloud to clipboard!"
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = RenCloudPurple)
                ) {
                    Text("Copy Discord Link", fontWeight = FontWeight.Bold, color = Color.White)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDiscordDialog = false }) {
                    Text("Close", color = TextSecondaryDark)
                }
            },
            containerColor = RenCloudCardDark,
            shape = RoundedCornerShape(20.dp)
        )
    }
}

@Composable
private fun HomeContent(
    catalogViewModel: CatalogViewModel,
    categories: List<String>,
    currency: String,
    selectedCategory: String,
    searchQuery: String,
    onPlanDeploy: (RenCloudPlan) -> Unit,
    modifier: Modifier = Modifier
) {
    val allPlans = catalogViewModel.getFilteredPlans()
    val featuredPlans = allPlans.filter { it.isFeatured }

    androidx.compose.foundation.lazy.LazyColumn(
        modifier = modifier,
        contentPadding = PaddingValues(bottom = 90.dp)
    ) {
        item { AnimatedHeroBanner() }

        if (featuredPlans.isNotEmpty() && searchQuery.isEmpty()) {
            item {
                Column {
                    SectionHeader(
                        title = "Featured Servers",
                        icon = Icons.Default.Star
                    )
                    FeaturedCarousel(
                        plans = featuredPlans,
                        currency = currency,
                        onDeploy = onPlanDeploy
                    )
                }
            }
        }

        item {
            Spacer(Modifier.height(8.dp))
            RenCloudSearchBar(
                query = searchQuery,
                onQueryChange = { catalogViewModel.setSearchQuery(it) },
                modifier = Modifier.padding(horizontal = 16.dp)
            )
            Spacer(Modifier.height(12.dp))
        }

        item {
            LazyRow(
                contentPadding = PaddingValues(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(categories) { category ->
                    CategoryChip(
                        category = category,
                        isSelected = selectedCategory == category,
                        onClick = { catalogViewModel.selectCategory(category) }
                    )
                }
            }
            Spacer(Modifier.height(16.dp))
        }

        item {
            SectionHeader(
                title = if (searchQuery.isNotEmpty()) "Search Results (${allPlans.size})" else "Catalog Plans (${allPlans.size})",
                icon = if (searchQuery.isNotEmpty()) Icons.Default.Search else Icons.Default.GridView
            )
        }

        if (allPlans.isEmpty()) {
            item { EmptyState(query = searchQuery) }
        } else {
            items(allPlans.size) { index ->
                EnhancedPlanCard(
                    plan = allPlans[index],
                    currency = currency,
                    onDeployClick = { onPlanDeploy(allPlans[index]) },
                    animationDelay = (index % 10) * 40,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp)
                )
            }
        }

        item {
            FaqSection()
            Spacer(Modifier.height(30.dp))
        }
    }
}

@Composable
private fun AnimatedHeroBanner() {
    val infiniteTransition = rememberInfiniteTransition(label = "hero")
    val pulse by infiniteTransition.animateFloat(
        initialValue = 0.98f,
        targetValue = 1.02f,
        animationSpec = infiniteRepeatable(tween(3000, easing = FastOutSlowInEasing), RepeatMode.Reverse),
        label = "pulse"
    )

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
            .scale(pulse)
            .clip(RoundedCornerShape(24.dp))
            .background(
                Brush.linearGradient(
                    colors = listOf(
                        Color(0xFF1E1B4B),
                        Color(0xFF0F172A),
                        Color(0xFF06B6D4).copy(alpha = 0.2f)
                    )
                )
            )
            .border(
                BorderStroke(1.dp, Brush.linearGradient(listOf(RenCloudPurple, RenCloudCyan))),
                RoundedCornerShape(24.dp)
            )
            .padding(20.dp)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Surface(
                    color = RenCloudCyan.copy(alpha = 0.15f),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Text(
                        "55 HIGH PERFORMANCE PLANS",
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold,
                        color = RenCloudCyan,
                        letterSpacing = 1.5.sp,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                    )
                }
                Spacer(Modifier.height(8.dp))
                Text(
                    "Deploy Anything.",
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Black,
                    color = Color.White
                )
                Text(
                    "Minecraft • Cloud VPS • Hytale • ARK • Web • Bots",
                    fontSize = 11.sp,
                    color = TextSecondaryDark
                )
            }

            Image(
                painter = painterResource(id = R.drawable.rencloud_logo),
                contentDescription = "RenCloud Logo",
                modifier = Modifier.size(64.dp)
            )
        }
    }
}

@Composable
private fun SectionHeader(title: String, icon: ImageVector) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
    ) {
        Icon(icon, contentDescription = null, tint = RenCloudCyan, modifier = Modifier.size(18.dp))
        Text(
            text = title,
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = Color.White
        )
    }
}

@Composable
private fun RenCloudSearchBar(
    query: String,
    onQueryChange: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    OutlinedTextField(
        value = query,
        onValueChange = onQueryChange,
        placeholder = { Text("Search 55 plans, specs, prices...", color = TextSecondaryDark, fontSize = 13.sp) },
        leadingIcon = { Icon(Icons.Default.Search, contentDescription = null, tint = RenCloudCyan) },
        trailingIcon = {
            if (query.isNotEmpty()) {
                IconButton(onClick = { onQueryChange("") }) {
                    Icon(Icons.Default.Clear, contentDescription = "Clear", tint = TextSecondaryDark)
                }
            }
        },
        singleLine = true,
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = RenCloudCyan,
            unfocusedBorderColor = RenCloudCardBorder,
            focusedContainerColor = RenCloudCardDark,
            unfocusedContainerColor = RenCloudCardDark,
            focusedTextColor = Color.White,
            unfocusedTextColor = Color.White
        ),
        shape = RoundedCornerShape(16.dp),
        modifier = modifier.fillMaxWidth()
    )
}

@Composable
private fun CategoryChip(
    category: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Surface(
        onClick = onClick,
        color = if (isSelected) RenCloudCyan else RenCloudSurfaceDark,
        shape = RoundedCornerShape(12.dp),
        border = BorderStroke(1.dp, if (isSelected) RenCloudCyan else RenCloudCardBorder)
    ) {
        Text(
            text = category,
            fontSize = 12.sp,
            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
            color = if (isSelected) Color.Black else Color.White,
            modifier = Modifier.padding(horizontal = 14.dp, vertical = 8.dp)
        )
    }
}

@Composable
private fun FeaturedCarousel(
    plans: List<RenCloudPlan>,
    currency: String,
    onDeploy: (RenCloudPlan) -> Unit
) {
    var currentIndex by remember { mutableIntStateOf(0) }

    LaunchedEffect(plans.size) {
        while (true) {
            delay(4500)
            if (plans.isNotEmpty()) {
                currentIndex = (currentIndex + 1) % plans.size
            }
        }
    }

    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(210.dp)
                .pointerInput(Unit) {
                    detectHorizontalDragGestures { _, dragAmount ->
                        if (dragAmount < -30) {
                            currentIndex = (currentIndex + 1) % plans.size
                        } else if (dragAmount > 30) {
                            currentIndex = if (currentIndex > 0) currentIndex - 1 else plans.size - 1
                        }
                    }
                },
            contentAlignment = Alignment.Center
        ) {
            plans.forEachIndexed { index, plan ->
                val offset = index - currentIndex
                val isSelected = index == currentIndex
                val scale = if (isSelected) 1.0f else 0.85f
                val alpha = if (isSelected) 1.0f else 0.4f

                val translationX = offset * 260.dp.value

                Card(
                    modifier = Modifier
                        .width(280.dp)
                        .height(190.dp)
                        .graphicsLayer {
                            scaleX = scale
                            scaleY = scale
                            this.alpha = alpha
                            this.translationX = translationX
                        }
                        .clickable { onDeploy(plan) },
                    colors = CardDefaults.cardColors(containerColor = RenCloudCardDark),
                    shape = RoundedCornerShape(20.dp),
                    border = BorderStroke(
                        if (isSelected) 2.dp else 1.dp,
                        if (isSelected) RenCloudCyan else RenCloudCardBorder
                    )
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(18.dp),
                        verticalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Surface(
                                color = RenCloudPurple.copy(alpha = 0.2f),
                                shape = RoundedCornerShape(8.dp)
                            ) {
                                Text(
                                    plan.categoryName.uppercase(),
                                    fontSize = 9.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = RenCloudPurple,
                                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                                )
                            }
                            Text(
                                if (currency == "INR") "₹${plan.monthlyPriceInr}/mo" else "$${plan.monthlyPriceUsd}/mo",
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Black,
                                color = RenCloudCyan
                            )
                        }

                        Column {
                            Text(
                                plan.name,
                                fontSize = 20.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color.White
                            )
                            Text(
                                plan.tagline,
                                fontSize = 11.sp,
                                color = TextSecondaryDark,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        }

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                "${plan.ram} • ${plan.cpu}",
                                fontSize = 11.sp,
                                color = TextSecondaryDark
                            )
                            Button(
                                onClick = { onDeploy(plan) },
                                colors = ButtonDefaults.buttonColors(containerColor = RenCloudCyan),
                                shape = RoundedCornerShape(10.dp),
                                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 4.dp)
                            ) {
                                Text("DEPLOY", color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 11.sp)
                            }
                        }
                    }
                }
            }
        }

        // Indicators
        Row(
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            modifier = Modifier.padding(top = 8.dp)
        ) {
            plans.indices.forEach { idx ->
                Box(
                    modifier = Modifier
                        .size(if (idx == currentIndex) 20.dp else 6.dp, 6.dp)
                        .clip(CircleShape)
                        .background(if (idx == currentIndex) RenCloudCyan else RenCloudCardBorder)
                )
            }
        }
    }
}

@Composable
private fun EnhancedPlanCard(
    plan: RenCloudPlan,
    currency: String,
    onDeployClick: () -> Unit,
    animationDelay: Int,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val categoryColor = when {
        plan.categoryName.contains("Minecraft", ignoreCase = true) -> MinecraftColor
        plan.categoryName.contains("VPS", ignoreCase = true) -> VpsColor
        plan.categoryName.contains("Hytale", ignoreCase = true) -> GameColor
        plan.categoryName.contains("ARK", ignoreCase = true) -> GameColor
        plan.categoryName.contains("Web", ignoreCase = true) -> RenCloudCyan
        plan.categoryName.contains("Bot", ignoreCase = true) -> RenCloudPurple
        else -> RenCloudGold
    }

    Surface(
        onClick = onDeployClick,
        color = RenCloudCardDark,
        shape = RoundedCornerShape(18.dp),
        border = BorderStroke(1.dp, categoryColor.copy(alpha = 0.3f)),
        modifier = modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Surface(
                        color = categoryColor.copy(alpha = 0.15f),
                        shape = RoundedCornerShape(6.dp)
                    ) {
                        Text(
                            plan.categoryName.uppercase(),
                            fontSize = 8.sp,
                            fontWeight = FontWeight.Bold,
                            color = categoryColor,
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                    if (plan.isFeatured) {
                        Surface(
                            color = RenCloudGold.copy(alpha = 0.2f),
                            shape = RoundedCornerShape(6.dp)
                        ) {
                            Text(
                                "POPULAR",
                                fontSize = 8.sp,
                                fontWeight = FontWeight.Black,
                                color = RenCloudGold,
                                modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                            )
                        }
                    }
                }

                Text(
                    text = if (currency == "INR") "₹${plan.monthlyPriceInr}/mo" else "$${plan.monthlyPriceUsd}/mo",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Black,
                    color = RenCloudCyan
                )
            }

            Spacer(Modifier.height(8.dp))

            Text(
                text = plan.name,
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )

            Text(
                text = plan.tagline,
                fontSize = 11.sp,
                color = TextSecondaryDark,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            Spacer(Modifier.height(12.dp))

            // Specs badges
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    SpecPill(plan.ram, categoryColor)
                    SpecPill(plan.cpu, categoryColor)
                    SpecPill(plan.nvmeStorage, categoryColor)
                }
                IconButton(
                    onClick = {
                        val price = if (currency == "INR") "₹${plan.monthlyPriceInr}/mo" else "$${plan.monthlyPriceUsd}/mo"
                        val shareText = "Check out this RenCloud plan: ${plan.name} (${plan.ram}, ${plan.cpu}) for just $price!"
                        val sendIntent = Intent().apply {
                            action = Intent.ACTION_SEND
                            putExtra(Intent.EXTRA_TEXT, shareText)
                            type = "text/plain"
                        }
                        val shareIntent = Intent.createChooser(sendIntent, "Share Quote")
                        context.startActivity(shareIntent)
                    },
                    modifier = Modifier.size(32.dp)
                ) {
                    Icon(Icons.Default.Share, contentDescription = "Share Quote", tint = TextSecondaryDark, modifier = Modifier.size(16.dp))
                }
            }
        }
    }
}

@Composable
private fun SpecPill(text: String, color: Color) {
    Surface(
        color = color.copy(alpha = 0.08f),
        shape = RoundedCornerShape(8.dp),
        border = BorderStroke(0.5.dp, color.copy(alpha = 0.25f))
    ) {
        Text(
            text = text,
            fontSize = 10.sp,
            color = Color.White,
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
        )
    }
}

@Composable
private fun EmptyState(query: String) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(40.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Icon(Icons.Default.SearchOff, contentDescription = null, tint = TextMutedDark, modifier = Modifier.size(48.dp))
        Text("No plans match '$query'", color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
        Text("Try searching for 'Minecraft', 'VPS', 'DDR5', or 'Ryzen'", color = TextSecondaryDark, fontSize = 12.sp)
    }
}
