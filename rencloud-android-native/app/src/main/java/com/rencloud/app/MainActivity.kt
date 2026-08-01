package com.rencloud.app

import android.os.Bundle
import android.widget.Toast
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.fragment.app.FragmentActivity
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.rencloud.app.data.remote.GitHubReleaseResponse
import com.rencloud.app.data.remote.UpdateService
import com.rencloud.app.ui.admin.AdminControlCenter
import com.rencloud.app.ui.admin.AdminViewModel
import com.rencloud.app.ui.auth.AuthScreen
import com.rencloud.app.ui.auth.AuthViewModel
import com.rencloud.app.ui.calculator.ResourceCalculatorScreen
import com.rencloud.app.ui.home.CatalogViewModel
import com.rencloud.app.ui.home.HomeScreen
import com.rencloud.app.ui.panel.PanelScreen
import com.rencloud.app.ui.splash.SplashScreen
import com.rencloud.app.ui.theme.RenCloudTheme
import com.rencloud.app.ui.update.UpdateDialog
import com.rencloud.app.util.BiometricPromptManager
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.launch
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : FragmentActivity() {

    private val authViewModel: AuthViewModel by viewModels()
    private val catalogViewModel: CatalogViewModel by viewModels()
    private val adminViewModel: AdminViewModel by viewModels()

    @Inject
    lateinit var updateService: UpdateService

    private lateinit var biometricManager: BiometricPromptManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        biometricManager = BiometricPromptManager(this)

        setContent {
            RenCloudTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    val navController = rememberNavController()
                    val authState by authViewModel.uiState.collectAsState()

                    var updateRelease by remember { mutableStateOf<GitHubReleaseResponse?>(null) }

                    // Automatic GitHub Release Update check on launch
                    LaunchedEffect(Unit) {
                        launch {
                            val release = updateService.checkForUpdates("v3.4")
                            if (release != null) {
                                updateRelease = release
                            }
                        }
                    }

                    Box(modifier = Modifier.fillMaxSize()) {
                        NavHost(
                            navController = navController,
                            startDestination = "splash"
                        ) {
                            composable("splash") {
                                SplashScreen(
                                    onSplashComplete = {
                                        val dest = if (authState.isAuthenticated) "home" else "auth"
                                        navController.navigate(dest) {
                                            popUpTo("splash") { inclusive = true }
                                        }
                                    }
                                )
                            }

                            composable("auth") {
                                AuthScreen(
                                    viewModel = authViewModel,
                                    onBiometricClick = {
                                        if (biometricManager.canAuthenticate()) {
                                            biometricManager.showBiometricPrompt(
                                                onSuccess = {
                                                    authViewModel.setBiometricAuthenticated(true)
                                                    Toast.makeText(this@MainActivity, "Biometric verified!", Toast.LENGTH_SHORT).show()
                                                },
                                                onError = { err ->
                                                    Toast.makeText(this@MainActivity, err, Toast.LENGTH_SHORT).show()
                                                }
                                            )
                                        } else {
                                            authViewModel.setBiometricAuthenticated(true)
                                        }
                                    },
                                    onNavigateHome = {
                                        navController.navigate("home") {
                                            popUpTo("auth") { inclusive = true }
                                        }
                                    }
                                )
                            }

                            composable("home") {
                                HomeScreen(
                                    catalogViewModel = catalogViewModel,
                                    authViewModel = authViewModel,
                                    onNavigateAdmin = { navController.navigate("admin") },
                                    onNavigateCalculator = { navController.navigate("calculator") },
                                    onNavigatePanel = { navController.navigate("panel") },
                                    onNavigateAuth = { navController.navigate("auth") }
                                )
                            }

                            composable("panel") {
                                PanelScreen(
                                    onNavigateBack = { navController.popBackStack() }
                                )
                            }

                            composable("admin") {
                                AdminControlCenter(
                                    adminViewModel = adminViewModel,
                                    onNavigateBack = { navController.popBackStack() }
                                )
                            }

                            composable("calculator") {
                                ResourceCalculatorScreen(
                                    onNavigateBack = { navController.popBackStack() }
                                )
                            }
                        }

                        // Auto-Update Dialog Prompt
                        updateRelease?.let { release ->
                            UpdateDialog(
                                release = release,
                                updateService = updateService,
                                onDismiss = { updateRelease = null }
                            )
                        }
                    }
                }
            }
        }
    }
}
