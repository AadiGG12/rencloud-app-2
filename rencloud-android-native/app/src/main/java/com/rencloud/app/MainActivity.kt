package com.rencloud.app

import android.os.Bundle
import android.widget.Toast
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.fragment.app.FragmentActivity
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.rencloud.app.ui.admin.AdminControlCenter
import com.rencloud.app.ui.admin.AdminViewModel
import com.rencloud.app.ui.auth.AuthScreen
import com.rencloud.app.ui.auth.AuthViewModel
import com.rencloud.app.ui.calculator.ResourceCalculatorScreen
import com.rencloud.app.ui.home.CatalogViewModel
import com.rencloud.app.ui.home.HomeScreen
import com.rencloud.app.ui.splash.SplashScreen
import com.rencloud.app.ui.theme.RenCloudNavy
import com.rencloud.app.ui.theme.RenCloudTheme
import com.rencloud.app.util.BiometricPromptManager
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : FragmentActivity() {

    private val authViewModel: AuthViewModel by viewModels()
    private val catalogViewModel: CatalogViewModel by viewModels()
    private val adminViewModel: AdminViewModel by viewModels()

    private lateinit var biometricManager: BiometricPromptManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        biometricManager = BiometricPromptManager(this)

        setContent {
            RenCloudTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = RenCloudNavy
                ) {
                    val navController = rememberNavController()
                    val authState by authViewModel.uiState.collectAsState()

                    NavHost(
                        navController = navController,
                        startDestination = "splash"
                    ) {
                        // ── Splash ────────────────────────────────────────────
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

                        // ── Auth ──────────────────────────────────────────────
                        composable("auth") {
                            AuthScreen(
                                viewModel = authViewModel,
                                onBiometricClick = {
                                    if (biometricManager.canAuthenticate()) {
                                        biometricManager.showBiometricPrompt(
                                            onSuccess = {
                                                authViewModel.setBiometricAuthenticated(true)
                                                Toast.makeText(
                                                    this@MainActivity,
                                                    "Biometric verified — enter your password",
                                                    Toast.LENGTH_SHORT
                                                ).show()
                                            },
                                            onError = { err ->
                                                Toast.makeText(this@MainActivity, err, Toast.LENGTH_SHORT).show()
                                            }
                                        )
                                    } else {
                                        // Fallback: skip biometric if not available
                                        authViewModel.setBiometricAuthenticated(true)
                                        Toast.makeText(
                                            this@MainActivity,
                                            "Biometrics unavailable — enter credentials",
                                            Toast.LENGTH_SHORT
                                        ).show()
                                    }
                                },
                                onNavigateHome = {
                                    navController.navigate("home") {
                                        popUpTo("auth") { inclusive = true }
                                    }
                                }
                            )
                        }

                        // ── Home ──────────────────────────────────────────────
                        composable("home") {
                            HomeScreen(
                                catalogViewModel = catalogViewModel,
                                authViewModel = authViewModel,
                                onNavigateAdmin = {
                                    navController.navigate("admin")
                                },
                                onNavigateCalculator = {
                                    navController.navigate("calculator")
                                },
                                onNavigateAuth = {
                                    navController.navigate("auth") {
                                        popUpTo("home") { inclusive = true }
                                    }
                                }
                            )
                        }

                        // ── Admin ─────────────────────────────────────────────
                        composable("admin") {
                            AdminControlCenter(
                                adminViewModel = adminViewModel,
                                onNavigateBack = {
                                    navController.popBackStack()
                                }
                            )
                        }

                        // ── Calculator ────────────────────────────────────────
                        composable("calculator") {
                            ResourceCalculatorScreen(
                                onNavigateBack = {
                                    navController.popBackStack()
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}
