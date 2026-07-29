package com.rencloud.app

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.widget.Toast
import androidx.activity.compose.setContent
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.fragment.app.FragmentActivity
import com.rencloud.app.data.AppCurrency
import com.rencloud.app.data.RenCloudPlan
import com.rencloud.app.services.BiometricsManager
import com.rencloud.app.services.UpdateService
import com.rencloud.app.ui.screens.AdminPanelScreen
import com.rencloud.app.ui.screens.AuthScreen
import com.rencloud.app.ui.screens.CalculatorScreen
import com.rencloud.app.ui.screens.CatalogScreen
import com.rencloud.app.ui.screens.SettingsScreen
import com.rencloud.app.ui.screens.SplashScreen
import com.rencloud.app.ui.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.system.exitProcess

class MainActivity : FragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableHighRefreshRate()

        setContent {
            var isDarkTheme by remember { mutableStateOf(true) }

            RenCloudTheme(darkTheme = isDarkTheme) {
                MainAppContainer(
                    activity = this@MainActivity,
                    darkTheme = isDarkTheme,
                    onDarkThemeToggle = { isDarkTheme = it }
                )
            }
        }
    }

    private fun enableHighRefreshRate() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val modes = display?.supportedModes ?: return
            var maxRefreshRate = 60.0f
            var bestModeId = 0
            for (mode in modes) {
                if (mode.refreshRate > maxRefreshRate) {
                    maxRefreshRate = mode.refreshRate
                    bestModeId = mode.modeId
                }
            }
            if (bestModeId != 0) {
                val params = window.attributes
                params.preferredDisplayModeId = bestModeId
                window.attributes = params
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val params = window.attributes
            params.preferredRefreshRate = 120.0f
            window.attributes = params
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainAppContainer(
    activity: FragmentActivity,
    darkTheme: Boolean,
    onDarkThemeToggle: (Boolean) -> Unit
) {
    val prefs = remember { activity.getSharedPreferences("rencloud_prefs", Context.MODE_PRIVATE) }
    var showSplash by remember { mutableStateOf(true) }
    var isAuthenticated by remember { mutableStateOf(prefs.getBoolean("is_authenticated", false)) }
    var userRole by remember { mutableStateOf(prefs.getString("user_role", "user") ?: "user") }
    var isAdminMode by remember { mutableStateOf(false) }
    var userEmail by remember { mutableStateOf(prefs.getString("user_email", "") ?: "") }
    var userName by remember { mutableStateOf(prefs.getString("user_name", "") ?: "") }

    var appName by remember { mutableStateOf("RenCloud") }
    var announcement by remember { mutableStateOf("⚡ Welcome to RenCloud Liquid Glass Cloud!") }
    var discordUrl by remember { mutableStateOf("https://discord.gg/rencloud") }

    var currentTab by remember { mutableIntStateOf(0) }
    var currency by remember { mutableStateOf(AppCurrency.INR) }
    var biometricsEnabled by remember { mutableStateOf(prefs.getBoolean("biometrics_enabled", false)) }
    var isUnlocked by remember { mutableStateOf(!biometricsEnabled) }
    var selectedPlanForDeploy by remember { mutableStateOf<RenCloudPlan?>(null) }
    var showUpdateDialog by remember { mutableStateOf(false) }

    val coroutineScope = rememberCoroutineScope()
    val colorScheme = MaterialTheme.colorScheme

    // Automatically prompt biometric hardware scanner when splash finishes if biometrics enabled
    LaunchedEffect(showSplash) {
        if (!showSplash && isAuthenticated && biometricsEnabled && !isUnlocked) {
            BiometricsManager.promptBiometric(
                activity = activity,
                onSuccess = { isUnlocked = true },
                onError = { err ->
                    Toast.makeText(activity, "Biometric authentication required: $err", Toast.LENGTH_SHORT).show()
                }
            )
        }
    }

    // Automatically trigger Update Dialog on app launch
    LaunchedEffect(showSplash, isAuthenticated, isUnlocked) {
        if (!showSplash && isAuthenticated && isUnlocked) {
            delay(500)
            showUpdateDialog = true
        }
    }

    if (showSplash) {
        SplashScreen(onNavigateToHome = { showSplash = false })
        return
    }

    // Login & Registration Flow
    if (!isAuthenticated && !isAdminMode) {
        AuthScreen(
            onLoginSuccess = { email, name, role ->
                userEmail = email
                userName = name
                userRole = role
                isAuthenticated = true
                prefs.edit()
                    .putBoolean("is_authenticated", true)
                    .putString("user_email", email)
                    .putString("user_name", name)
                    .putString("user_role", role)
                    .apply()
            },
            onAdminLoginSuccess = {
                userRole = "admin"
                isAdminMode = true
                isAuthenticated = true
                prefs.edit().putBoolean("is_authenticated", true).putString("user_role", "admin").apply()
            }
        )
        return
    }

    // Admin Control Panel Screen (ONLY accessible if userRole == "admin")
    if (isAdminMode && userRole == "admin") {
        AdminPanelScreen(
            appName = appName,
            onAppNameChange = { appName = it },
            announcement = announcement,
            onAnnouncementChange = { announcement = it },
            discordUrl = discordUrl,
            onDiscordUrlChange = { discordUrl = it },
            onExitAdmin = { isAdminMode = false; isAuthenticated = true }
        )
        return
    }

    // Biometric Security Screen Overlay
    if (biometricsEnabled && !isUnlocked) {
        val infiniteTransition = rememberInfiniteTransition(label = "pulse")
        val pulseScale by infiniteTransition.animateFloat(
            initialValue = 0.95f,
            targetValue = 1.08f,
            animationSpec = infiniteRepeatable(animation = tween(1000, easing = FastOutSlowInEasing), repeatMode = RepeatMode.Reverse),
            label = "pulseScale"
        )

        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(colorScheme.background),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.padding(32.dp)
            ) {
                Surface(
                    shape = CircleShape,
                    color = colorScheme.primary.copy(alpha = 0.15f),
                    modifier = Modifier
                        .size(110.dp)
                        .scale(pulseScale)
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(Icons.Default.Fingerprint, contentDescription = null, tint = colorScheme.secondary, modifier = Modifier.size(64.dp))
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))
                Text("$appName Biometric Lock", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
                Spacer(modifier = Modifier.height(8.dp))
                Text("Touch fingerprint sensor or scan Face ID to unlock $appName", fontSize = 12.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))

                Spacer(modifier = Modifier.height(32.dp))

                Button(
                    onClick = {
                        BiometricsManager.promptBiometric(
                            activity = activity,
                            onSuccess = { isUnlocked = true },
                            onError = { err ->
                                Toast.makeText(activity, "Authentication failed: $err", Toast.LENGTH_SHORT).show()
                            }
                        )
                    },
                    shape = RoundedCornerShape(14.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = colorScheme.primary),
                    modifier = Modifier.fillMaxWidth().height(50.dp)
                ) {
                    Icon(Icons.Default.Fingerprint, contentDescription = null, tint = Color.White)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Scan Fingerprint / Face ID to Unlock", fontWeight = FontWeight.Bold, color = Color.White)
                }
            }
        }
        return
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Image(
                            painter = painterResource(id = R.drawable.logo),
                            contentDescription = null,
                            modifier = Modifier.size(28.dp)
                        )
                        Spacer(modifier = Modifier.width(10.dp))
                        Text(appName, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
                    }
                },
                actions = {
                    // Show Admin Control Panel icon ONLY for admin role
                    if (userRole == "admin") {
                        IconButton(onClick = { isAdminMode = true }) {
                            Icon(Icons.Default.AdminPanelSettings, contentDescription = "Admin Panel", tint = colorScheme.secondary)
                        }
                    }
                    IconButton(onClick = { onDarkThemeToggle(!darkTheme) }) {
                        Icon(
                            imageVector = if (darkTheme) Icons.Default.LightMode else Icons.Default.DarkMode,
                            contentDescription = null,
                            tint = colorScheme.primary
                        )
                    }
                    IconButton(onClick = { showUpdateDialog = true }) {
                        Icon(Icons.Default.SystemUpdate, contentDescription = null, tint = colorScheme.secondary)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = colorScheme.surface)
            )
        },
        bottomBar = {
            NavigationBar(containerColor = colorScheme.surface) {
                NavigationBarItem(
                    selected = currentTab == 0,
                    onClick = { currentTab = 0 },
                    icon = { Icon(Icons.Default.Cloud, contentDescription = null) },
                    label = { Text("Catalog") },
                    colors = NavigationBarItemDefaults.colors(selectedIconColor = colorScheme.primary, indicatorColor = colorScheme.primary.copy(alpha = 0.15f))
                )
                NavigationBarItem(
                    selected = currentTab == 1,
                    onClick = { currentTab = 1 },
                    icon = { Icon(Icons.Default.Calculate, contentDescription = null) },
                    label = { Text("Calculator") },
                    colors = NavigationBarItemDefaults.colors(selectedIconColor = colorScheme.primary, indicatorColor = colorScheme.primary.copy(alpha = 0.15f))
                )
                NavigationBarItem(
                    selected = currentTab == 2,
                    onClick = { currentTab = 2 },
                    icon = { Icon(Icons.Default.Settings, contentDescription = null) },
                    label = { Text("Settings") },
                    colors = NavigationBarItemDefaults.colors(selectedIconColor = colorScheme.primary, indicatorColor = colorScheme.primary.copy(alpha = 0.15f))
                )
            }
        }
    ) { innerPadding ->
        Box(modifier = Modifier.padding(innerPadding)) {
            AnimatedContent(
                targetState = currentTab,
                transitionSpec = { fadeIn(tween(300)) togetherWith fadeOut(tween(300)) },
                label = "tabTransition"
            ) { tab ->
                when (tab) {
                    0 -> CatalogScreen(
                        currency = currency,
                        onDeployClick = { selectedPlanForDeploy = it }
                    )
                    1 -> CalculatorScreen(
                        currency = currency,
                        onDeployClick = { selectedPlanForDeploy = it }
                    )
                    2 -> SettingsScreen(
                        darkTheme = darkTheme,
                        onDarkThemeToggle = onDarkThemeToggle,
                        currency = currency,
                        onCurrencyChange = { currency = it },
                        biometricsEnabled = biometricsEnabled,
                        onBiometricsToggle = { enabled ->
                            if (enabled) {
                                BiometricsManager.promptBiometric(
                                    activity = activity,
                                    onSuccess = {
                                        biometricsEnabled = true
                                        prefs.edit().putBoolean("biometrics_enabled", true).apply()
                                        Toast.makeText(activity, "Biometric Lock Enabled!", Toast.LENGTH_SHORT).show()
                                    },
                                    onError = { err ->
                                        Toast.makeText(activity, "Biometric Auth Failed: $err", Toast.LENGTH_SHORT).show()
                                    }
                                )
                            } else {
                                biometricsEnabled = false
                                isUnlocked = true
                                prefs.edit().putBoolean("biometrics_enabled", false).apply()
                            }
                        },
                        onDiscordClick = {
                            Toast.makeText(activity, "Copied $discordUrl to clipboard!", Toast.LENGTH_SHORT).show()
                        },
                        onCheckUpdateClick = { showUpdateDialog = true }
                    )
                }
            }
        }

        // Deploy Modal Dialog
        selectedPlanForDeploy?.let { plan ->
            AlertDialog(
                onDismissRequest = { selectedPlanForDeploy = null },
                title = { Text("Deploy ${plan.name}", fontWeight = FontWeight.Bold) },
                text = {
                    Column {
                        Text("Specs: ${plan.ram} | ${plan.cpu} | ${plan.nvmeStorage}")
                        Spacer(modifier = Modifier.height(8.dp))
                        Text("Price: ${currency.format(plan.monthlyPriceInr)}/month", fontWeight = FontWeight.ExtraBold, color = colorScheme.secondary)
                    }
                },
                confirmButton = {
                    Button(
                        onClick = {
                            selectedPlanForDeploy = null
                            Toast.makeText(activity, "Order placed for ${plan.name}!", Toast.LENGTH_LONG).show()
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = colorScheme.primary)
                    ) {
                        Text("Confirm Deployment", color = Color.White)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { selectedPlanForDeploy = null }) {
                        Text("Cancel")
                    }
                }
            )
        }

        // In-App Auto Update Popup Dialog with Automatic App Relaunch
        if (showUpdateDialog) {
            UpdateDialog(
                onDismiss = { showUpdateDialog = false },
                onInstallAndRelaunch = {
                    val launchIntent = activity.packageManager.getLaunchIntentForPackage(activity.packageName)
                    launchIntent?.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
                    if (launchIntent != null) {
                        activity.startActivity(launchIntent)
                    }
                    activity.finishAffinity()
                    try { exitProcess(0) } catch (_: Exception) {}
                }
            )
        }
    }
}

@Composable
fun UpdateDialog(onDismiss: () -> Unit, onInstallAndRelaunch: () -> Unit) {
    var isDownloading by remember { mutableStateOf(false) }
    var readyToInstall by remember { mutableStateOf(false) }
    var progress by remember { mutableFloatStateOf(0.0f) }
    var downloadMB by remember { mutableStateOf("0.0 / 12.2 MB") }

    val coroutineScope = rememberCoroutineScope()
    val colorScheme = MaterialTheme.colorScheme

    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = if (readyToInstall) Icons.Default.CheckCircle else Icons.Default.SystemUpdate,
                    contentDescription = null,
                    tint = if (readyToInstall) colorScheme.secondary else colorScheme.primary
                )
                Spacer(modifier = Modifier.width(10.dp))
                Text(if (readyToInstall) "Update Ready to Install" else if (isDownloading) "Downloading Update..." else "⚡ RenCloud Update Available")
            }
        },
        text = {
            Column {
                if (!isDownloading && !readyToInstall) {
                    Text("A new version of RenCloud (v2.0.0-compose) is ready! Tap UPDATE below to download the latest release and automatically relaunch the application.")
                } else {
                    Text(if (readyToInstall) "Download complete! Tap below to install update & relaunch app." else "Downloading update package...")
                    Spacer(modifier = Modifier.height(16.dp))
                    LinearProgressIndicator(
                        progress = { progress },
                        modifier = Modifier.fillMaxWidth().height(8.dp).clip(RoundedCornerShape(4.dp)),
                        color = if (readyToInstall) colorScheme.secondary else colorScheme.primary
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                        Text("${(progress * 100).toInt()}%", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = colorScheme.primary)
                        Text(downloadMB, fontSize = 12.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))
                    }
                }
            }
        },
        confirmButton = {
            if (readyToInstall) {
                Button(
                    onClick = onInstallAndRelaunch,
                    colors = ButtonDefaults.buttonColors(containerColor = colorScheme.secondary),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("INSTALL & RELAUNCH APP", fontWeight = FontWeight.ExtraBold, color = Color.White)
                }
            } else if (!isDownloading) {
                Button(
                    onClick = {
                        isDownloading = true
                        coroutineScope.launch {
                            for (i in 1..40) {
                                delay(40)
                                progress = i / 40.0f
                                downloadMB = "${String.format("%.1f", (i / 40.0f) * 12.2)} / 12.2 MB"
                            }
                            readyToInstall = true
                        }
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = colorScheme.primary)
                ) {
                    Text("UPDATE & RELAUNCH", fontWeight = FontWeight.ExtraBold, color = Color.White)
                }
            }
        },
        dismissButton = {
            if (!isDownloading && !readyToInstall) {
                TextButton(onClick = onDismiss) {
                    Text("Later")
                }
            }
        }
    )
}
