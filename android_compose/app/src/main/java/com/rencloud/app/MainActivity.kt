package com.rencloud.app

import android.os.Build
import android.os.Bundle
import android.widget.Toast
import androidx.activity.compose.setContent
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.fragment.app.FragmentActivity
import com.rencloud.app.data.AppCurrency
import com.rencloud.app.data.RenCloudPlan
import com.rencloud.app.services.BiometricsManager
import com.rencloud.app.services.UpdateService
import com.rencloud.app.ui.screens.CalculatorScreen
import com.rencloud.app.ui.screens.CatalogScreen
import com.rencloud.app.ui.screens.SettingsScreen
import com.rencloud.app.ui.screens.SplashScreen
import com.rencloud.app.ui.theme.*
import kotlinx.coroutines.launch

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
    var showSplash by remember { mutableStateOf(true) }
    var currentTab by remember { mutableIntStateOf(0) }
    var currency by remember { mutableStateOf(AppCurrency.INR) }
    var biometricsEnabled by remember { mutableStateOf(false) }
    var isUnlocked by remember { mutableStateOf(true) }
    var selectedPlanForDeploy by remember { mutableStateOf<RenCloudPlan?>(null) }

    val coroutineScope = rememberCoroutineScope()

    if (showSplash) {
        SplashScreen(onNavigateToHome = { showSplash = false })
        return
    }

    val colorScheme = MaterialTheme.colorScheme

    // Biometric Security Screen
    if (biometricsEnabled && !isUnlocked) {
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
                    modifier = Modifier.size(100.dp)
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(Icons.Default.Fingerprint, contentDescription = null, tint = colorScheme.secondary, modifier = Modifier.size(56.dp))
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))
                Text("RenCloud Biometric Lock", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
                Spacer(modifier = Modifier.height(8.dp))
                Text("Touch fingerprint sensor or scan Face ID to unlock RenCloud", fontSize = 12.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))

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
                        Text("RenCloud", fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
                    }
                },
                actions = {
                    IconButton(onClick = { onDarkThemeToggle(!darkTheme) }) {
                        Icon(
                            imageVector = if (darkTheme) Icons.Default.LightMode else Icons.Default.DarkMode,
                            contentDescription = null,
                            tint = colorScheme.primary
                        )
                    }
                    IconButton(onClick = {
                        coroutineScope.launch {
                            val release = UpdateService.checkForUpdates()
                            if (release != null) {
                                Toast.makeText(activity, "Update Available: ${release.tagName}", Toast.LENGTH_LONG).show()
                            } else {
                                Toast.makeText(activity, "You are on the latest version of RenCloud (v1.4.0)", Toast.LENGTH_SHORT).show()
                            }
                        }
                    }) {
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
            when (currentTab) {
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
                                    Toast.makeText(activity, "Biometric Lock Enabled!", Toast.LENGTH_SHORT).show()
                                },
                                onError = { err ->
                                    Toast.makeText(activity, "Biometric Auth Failed: $err", Toast.LENGTH_SHORT).show()
                                }
                            )
                        } else {
                            biometricsEnabled = false
                            isUnlocked = true
                        }
                    },
                    onDiscordClick = {
                        Toast.makeText(activity, "Copied https://discord.gg/rencloud to clipboard!", Toast.LENGTH_SHORT).show()
                    },
                    onCheckUpdateClick = {
                        coroutineScope.launch {
                            val release = UpdateService.checkForUpdates()
                            if (release != null) {
                                Toast.makeText(activity, "Update Available: ${release.tagName}", Toast.LENGTH_LONG).show()
                            } else {
                                Toast.makeText(activity, "You are on the latest version of RenCloud (v1.4.0)", Toast.LENGTH_SHORT).show()
                            }
                        }
                    }
                )
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
    }
}
