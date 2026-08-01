package com.rencloud.app.ui.home

import android.content.Intent
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.R
import com.rencloud.app.data.model.RenCloudPlan
import com.rencloud.app.ui.auth.AuthViewModel
import com.rencloud.app.ui.components.BoomMenu
import com.rencloud.app.ui.components.BoomMenuItem
import com.rencloud.app.ui.components.glass.*
import com.rencloud.app.ui.showcase.*
import com.rencloud.app.ui.theme.*
import com.rencloud.app.util.SoundEffects
import kotlin.math.absoluteValue

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
    val view = LocalView.current

    val themeIsDark = LocalThemeIsDark.current
    var activeBottomTab by remember { mutableIntStateOf(0) }

    var showCompareDialog by remember { mutableStateOf(false) }
    var showSimulatorDialog by remember { mutableStateOf(false) }
    var showPingDialog by remember { mutableStateOf(false) }
    val snackbarHostState = remember { SnackbarHostState() }
    var snackbarMessage by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(snackbarMessage) {
        snackbarMessage?.let { msg ->
            snackbarHostState.showSnackbar(msg)
            snackbarMessage = null
        }
    }

    val handlePlanAction: (RenCloudPlan) -> Unit = { plan ->
        SoundEffects.playClickSound(view)
        val price = if (catalogState.currency == "INR") "₹${plan.monthlyPriceInr}/mo" else "$${plan.monthlyPriceUsd}/mo"
        snackbarMessage = "${plan.name} ($price) — Order & provision via RenCloud Web Portal or Discord."
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
            BoomMenuItem("simulator", "Capacity Simulator", "Estimate resources", Icons.Default.Storage, ElectricCyan),
            BoomMenuItem("ping", "Datacenter Ping", "Check latency", Icons.Default.NetworkCheck, MetallicPurple)
        )
    }

    LiquidGlassBackground {
        Scaffold(
            snackbarHost = { SnackbarHost(snackbarHostState) },
            topBar = {
                CenterAlignedTopAppBar(
                    title = {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.Center
                        ) {
                            Image(
                                painter = painterResource(id = R.drawable.rencloud_logo),
                                contentDescription = "RenCloud Logo",
                                modifier = Modifier.size(32.dp)
                            )
                            Spacer(Modifier.width(8.dp))
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text(
                                    "RenCloud",
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.Black,
                                    color = Color.White
                                )
                                Text(
                                    "v4.0 Enterprise Showcase",
                                    fontSize = 8.sp,
                                    color = ElectricCyan,
                                    letterSpacing = 1.sp
                                )
                            }
                        }
                    },
                    actions = {
                        IconButton(onClick = {
                            SoundEffects.playThemeToggleSound()
                            themeIsDark.value = !themeIsDark.value
                        }) {
                            Icon(
                                imageVector = if (themeIsDark.value) Icons.Default.WbSunny else Icons.Default.NightsStay,
                                contentDescription = "Switch Theme",
                                tint = RenCloudGold
                            )
                        }

                        Surface(
                            onClick = {
                                SoundEffects.playClickSound(view)
                                catalogViewModel.toggleCurrency()
                            },
                            color = RenCloudGold.copy(alpha = 0.15f),
                            shape = RoundedCornerShape(20.dp),
                            border = BorderStroke(1.dp, RenCloudGold.copy(alpha = 0.4f))
                        ) {
                            Text(
                                text = if (catalogState.currency == "INR") "₹ INR" else "$ USD",
                                color = RenCloudGold,
                                fontWeight = FontWeight.Bold,
                                fontSize = 11.sp,
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp)
                            )
                        }

                        if (authState.user?.isAdmin == true) {
                            IconButton(onClick = {
                                SoundEffects.playClickSound(view)
                                onNavigateAdmin()
                            }) {
                                Icon(
                                    imageVector = Icons.Default.ManageAccounts,
                                    contentDescription = "Admin",
                                    tint = RenCloudGold
                                )
                            }
                        }

                        IconButton(onClick = {
                            SoundEffects.playClickSound(view)
                            onNavigateAuth()
                        }) {
                            Icon(
                                imageVector = Icons.Default.AccountCircle,
                                contentDescription = "Account",
                                tint = ElectricCyan
                            )
                        }
                    },
                    colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                        containerColor = Color.Transparent
                    )
                )
            },
            bottomBar = {
                NavigationBar(
                    containerColor = MetallicCardDark.copy(alpha = 0.85f),
                    contentColor = ElectricCyan,
                    tonalElevation = 0.dp
                ) {
                    NavigationBarItem(
                        selected = activeBottomTab == 0,
                        onClick = {
                            activeBottomTab = 0
                            SoundEffects.playClickSound(view)
                        },
                        icon = { Icon(Icons.Default.Cloud, contentDescription = "Plans") },
                        label = { Text("Plans", fontSize = 10.sp) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = ElectricCyan,
                            selectedTextColor = ElectricCyan,
                            unselectedIconColor = TextSecondaryDark
                        )
                    )
                    NavigationBarItem(
                        selected = activeBottomTab == 1,
                        onClick = {
                            activeBottomTab = 1
                            SoundEffects.playClickSound(view)
                            onNavigateCalculator()
                        },
                        icon = { Icon(Icons.Default.Calculate, contentDescription = "Calculator") },
                        label = { Text("Calculator", fontSize = 10.sp) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = ElectricCyan,
                            selectedTextColor = ElectricCyan,
                            unselectedIconColor = TextSecondaryDark
                        )
                    )
                    NavigationBarItem(
                        selected = activeBottomTab == 2,
                        onClick = {
                            activeBottomTab = 2
                            SoundEffects.playClickSound(view)
                            onNavigateAuth()
                        },
                        icon = { Icon(Icons.Default.Person, contentDescription = "Account") },
                        label = { Text("Account", fontSize = 10.sp) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = ElectricCyan,
                            selectedTextColor = ElectricCyan,
                            unselectedIconColor = TextSecondaryDark
                        )
                    )
                }
            },
            containerColor = Color.Transparent
        ) { innerPadding ->

            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
            ) {
                HomeContent(
                    catalogViewModel = catalogViewModel,
                    categories = categories,
                    currency = catalogState.currency,
                    selectedCategory = catalogState.selectedCategory,
                    searchQuery = catalogState.searchQuery,
                    onPlanDeploy = handlePlanAction,
                    modifier = Modifier.fillMaxSize()
                )

                BoomMenu(
                    items = boomMenuItems,
                    onItemClick = { item ->
                        SoundEffects.playClickSound(view)
                        when (item.id) {
                            "compare" -> showCompareDialog = true
                            "simulator" -> showSimulatorDialog = true
                            "ping" -> showPingDialog = true
                        }
                    },
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .padding(16.dp)
                )
            }
        }
    }

    if (showCompareDialog) {
        PlanComparisonDialog(allPlans = catalogState.plans, onDismiss = { showCompareDialog = false })
    }
    if (showSimulatorDialog) {
        CapacitySimulatorDialog(
            allPlans = catalogState.plans,
            onDismiss = { showSimulatorDialog = false },
            onDeployPlan = { handlePlanAction(it) }
        )
    }
    if (showPingDialog) {
        DatacenterPingDialog(onDismiss = { showPingDialog = false })
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
    val view = LocalView.current
    val allPlans = catalogViewModel.getFilteredPlans()
    val featuredPlans = remember(allPlans) { catalogViewModel.uiState.value.plans.filter { it.isFeatured } }

    LazyColumn(
        modifier = modifier,
        contentPadding = PaddingValues(bottom = 90.dp)
    ) {
        item { AnimatedHeroBanner() }

        if (featuredPlans.isNotEmpty() && searchQuery.isEmpty()) {
            item {
                Column {
                    SectionHeader(
                        title = "Featured 3D Carousel",
                        icon = Icons.Default.Star
                    )
                    Animated3DVerticalCarousel(
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
                        onClick = {
                            SoundEffects.playClickSound(view)
                            catalogViewModel.selectCategory(category)
                        }
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
                SquarePlanCard(
                    plan = allPlans[index],
                    currency = currency,
                    onDeployClick = { onPlanDeploy(allPlans[index]) },
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
private fun Animated3DVerticalCarousel(
    plans: List<RenCloudPlan>,
    currency: String,
    onDeploy: (RenCloudPlan) -> Unit
) {
    val view = LocalView.current
    val listState = rememberLazyListState()

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(240.dp)
            .padding(horizontal = 16.dp)
    ) {
        LazyColumn(
            state = listState,
            contentPadding = PaddingValues(vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
            modifier = Modifier.fillMaxSize()
        ) {
            items(plans.size) { index ->
                val plan = plans[index]
                val itemInfo = remember { derivedStateOf { listState.layoutInfo.visibleItemsInfo.firstOrNull { it.index == index } } }

                val animationFraction = remember {
                    derivedStateOf {
                        val info = itemInfo.value ?: return@derivedStateOf 0f
                        val centerOffset = listState.layoutInfo.viewportEndOffset / 2f
                        val itemCenter = info.offset + info.size / 2f
                        ((itemCenter - centerOffset) / centerOffset).coerceIn(-1f, 1f)
                    }
                }

                val scale = 1f - (animationFraction.value.absoluteValue * 0.15f)
                val alpha = 1f - (animationFraction.value.absoluteValue * 0.35f)
                val rotationX = animationFraction.value * 15f

                GlassCard(
                    onClick = {
                        SoundEffects.playClickSound(view)
                        onDeploy(plan)
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(130.dp)
                        .graphicsLayer {
                            scaleX = scale
                            scaleY = scale
                            this.alpha = alpha
                            this.rotationX = rotationX
                            cameraDistance = 16 * density
                        },
                    accentGlow = MetallicPurple,
                    alpha = 0.85f
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(16.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Surface(
                                color = MetallicPurple.copy(alpha = 0.2f),
                                shape = RoundedCornerShape(6.dp)
                            ) {
                                Text(
                                    plan.categoryName.uppercase(),
                                    fontSize = 8.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = MetallicPurple,
                                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 2.dp)
                                )
                            }
                            Spacer(Modifier.height(4.dp))
                            Text(plan.name, fontSize = 16.sp, fontWeight = FontWeight.Black, color = Color.White)
                            Text("${plan.ram} • ${plan.cpu}", fontSize = 11.sp, color = TextSecondaryDark)
                        }

                        Column(horizontalAlignment = Alignment.End) {
                            Text(
                                if (currency == "INR") "₹${plan.monthlyPriceInr}/mo" else "$${plan.monthlyPriceUsd}/mo",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Black,
                                color = ElectricCyan
                            )
                            Spacer(Modifier.height(6.dp))
                            GlassButton(
                                onClick = {
                                    SoundEffects.playClickSound(view)
                                    onDeploy(plan)
                                },
                                containerColor = ElectricCyan,
                                modifier = Modifier.wrapContentSize()
                            ) {
                                Text("VIEW SPECS", color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 10.sp)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun SquarePlanCard(
    plan: RenCloudPlan,
    currency: String,
    onDeployClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val categoryColor = when {
        plan.categoryName.contains("Minecraft", ignoreCase = true) -> MinecraftColor
        plan.categoryName.contains("VPS", ignoreCase = true) -> VpsColor
        plan.categoryName.contains("Hytale", ignoreCase = true) -> GameColor
        plan.categoryName.contains("ARK", ignoreCase = true) -> GameColor
        plan.categoryName.contains("Web", ignoreCase = true) -> ElectricCyan
        plan.categoryName.contains("Bot", ignoreCase = true) -> MetallicPurple
        else -> RenCloudGold
    }

    GlassCard(
        onClick = onDeployClick,
        modifier = modifier.fillMaxWidth(),
        accentGlow = categoryColor,
        alpha = 0.8f
    ) {
        Column(modifier = Modifier.padding(14.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Surface(
                        color = categoryColor.copy(alpha = 0.15f),
                        shape = RoundedCornerShape(4.dp)
                    ) {
                        Text(
                            plan.categoryName.uppercase(),
                            fontSize = 8.sp,
                            fontWeight = FontWeight.Bold,
                            color = categoryColor,
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                    Surface(
                        color = ElectricCyan.copy(alpha = 0.15f),
                        shape = RoundedCornerShape(4.dp)
                    ) {
                        Text(
                            "ENTERPRISE PLAN",
                            fontSize = 8.sp,
                            fontWeight = FontWeight.Black,
                            color = ElectricCyan,
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                }

                Text(
                    text = if (currency == "INR") "₹${plan.monthlyPriceInr}/mo" else "$${plan.monthlyPriceUsd}/mo",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Black,
                    color = ElectricCyan
                )
            }

            Spacer(Modifier.height(6.dp))

            Text(
                text = plan.name,
                fontSize = 15.sp,
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

            Spacer(Modifier.height(10.dp))

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
                    modifier = Modifier.size(28.dp)
                ) {
                    Icon(Icons.Default.Share, contentDescription = "Share Quote", tint = TextSecondaryDark, modifier = Modifier.size(15.dp))
                }
            }
        }
    }
}

@Composable
private fun SpecPill(text: String, color: Color) {
    Surface(
        color = color.copy(alpha = 0.08f),
        shape = RoundedCornerShape(6.dp),
        border = BorderStroke(0.5.dp, color.copy(alpha = 0.25f))
    ) {
        Text(
            text = text,
            fontSize = 9.sp,
            color = Color.White,
            modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp)
        )
    }
}

@Composable
private fun AnimatedHeroBanner() {
    GlassCard(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        accentGlow = MetallicPurple,
        alpha = 0.85f
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
            modifier = Modifier
                .fillMaxWidth()
                .padding(18.dp)
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Surface(
                    color = ElectricCyan.copy(alpha = 0.15f),
                    shape = RoundedCornerShape(6.dp)
                ) {
                    Text(
                        "55 HIGH PERFORMANCE PLANS",
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold,
                        color = ElectricCyan,
                        letterSpacing = 1.5.sp,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                    )
                }
                Spacer(Modifier.height(8.dp))
                Text(
                    "Enterprise Catalog",
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
                modifier = Modifier.size(58.dp)
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
        Icon(icon, contentDescription = null, tint = ElectricCyan, modifier = Modifier.size(18.dp))
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
        leadingIcon = { Icon(Icons.Default.Search, contentDescription = null, tint = ElectricCyan) },
        trailingIcon = {
            if (query.isNotEmpty()) {
                IconButton(onClick = { onQueryChange("") }) {
                    Icon(Icons.Default.Clear, contentDescription = "Clear", tint = TextSecondaryDark)
                }
            }
        },
        singleLine = true,
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = ElectricCyan,
            unfocusedBorderColor = MetallicBorderDark,
            focusedContainerColor = MetallicCardDark.copy(alpha = 0.6f),
            unfocusedContainerColor = MetallicCardDark.copy(alpha = 0.6f),
            focusedTextColor = Color.White,
            unfocusedTextColor = Color.White
        ),
        shape = RoundedCornerShape(12.dp),
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
        color = if (isSelected) ElectricCyan else MetallicCardDark.copy(alpha = 0.6f),
        shape = RoundedCornerShape(10.dp),
        border = BorderStroke(1.dp, if (isSelected) ElectricCyan else MetallicBorderDark)
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
private fun EmptyState(query: String) {
    Column(
        modifier = Modifier.fillMaxWidth().padding(40.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Icon(Icons.Default.SearchOff, contentDescription = null, tint = TextMutedDark, modifier = Modifier.size(48.dp))
        Text("No plans match '$query'", color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
        Text("Try searching for 'Minecraft', 'VPS', 'DDR5', or 'Ryzen'", color = TextSecondaryDark, fontSize = 12.sp)
    }
}
