package com.rencloud.app.ui.auth

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
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
import androidx.compose.ui.graphics.*
import androidx.compose.ui.layout.ContentScale
import androidx.compose.foundation.Image
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.R
import com.rencloud.app.ui.components.glass.*
import com.rencloud.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AuthScreen(
    viewModel: AuthViewModel,
    onBiometricClick: () -> Unit = {},
    onNavigateHome: () -> Unit
) {
    val state by viewModel.uiState.collectAsState()
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var fullName by remember { mutableStateOf("") }
    var passwordVisible by remember { mutableStateOf(false) }

    LaunchedEffect(state.isAuthenticated) {
        if (state.isAuthenticated) onNavigateHome()
    }

    val infiniteTransition = rememberInfiniteTransition(label = "auth_bg")
    val logoGlow by infiniteTransition.animateFloat(
        initialValue = 0.6f, targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(2000, easing = FastOutSlowInEasing), RepeatMode.Reverse),
        label = "logoGlow"
    )
    val logoRotate by infiniteTransition.animateFloat(
        initialValue = 0f, targetValue = 360f,
        animationSpec = infiniteRepeatable(tween(20000, easing = LinearEasing)),
        label = "logoRotate"
    )

    LiquidGlassBackground {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(Modifier.height(40.dp))

            // Logo Section with Glass Halo
            Box(contentAlignment = Alignment.Center) {
                Box(
                    modifier = Modifier
                        .size(120.dp)
                        .rotate(logoRotate)
                        .border(
                            1.dp,
                            Brush.sweepGradient(
                                listOf(
                                    ElectricCyan.copy(alpha = logoGlow),
                                    MetallicPurple,
                                    ElectricCyan.copy(alpha = 0.1f)
                                )
                            ),
                            CircleShape
                        )
                )
                Box(
                    modifier = Modifier
                        .size(100.dp)
                        .blur(20.dp)
                        .background(
                            Brush.radialGradient(
                                listOf(
                                    MetallicPurple.copy(alpha = 0.4f * logoGlow),
                                    Color.Transparent
                                )
                            ),
                            CircleShape
                        )
                )
                Box(
                    modifier = Modifier
                        .size(90.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.linearGradient(
                                listOf(
                                    MetallicPurple.copy(alpha = 0.8f),
                                    MetallicNavy.copy(alpha = 0.6f)
                                )
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Image(
                        painter = painterResource(id = R.drawable.rencloud_logo),
                        contentDescription = "RenCloud",
                        modifier = Modifier.size(66.dp)
                    )
                }
            }

            Spacer(Modifier.height(20.dp))

            Text(
                text = "RenCloud",
                fontSize = 32.sp,
                fontWeight = FontWeight.Black,
                color = Color.White,
                letterSpacing = 1.sp
            )
            Text(
                text = "ENTERPRISE SHOWCASE PLATFORM",
                fontSize = 10.sp,
                fontWeight = FontWeight.Medium,
                color = ElectricCyan,
                letterSpacing = 3.sp
            )

            Spacer(Modifier.height(30.dp))

            // STEP 1: Biometric Verification Glass Moment
            AnimatedVisibility(
                visible = !state.isBiometricAuthenticated,
                enter = fadeIn() + expandVertically(),
                exit = fadeOut() + shrinkVertically()
            ) {
                BiometricGlassSection(
                    onBiometricClick = { onBiometricClick() },
                    isLoading = state.isLoading
                )
            }

            if (state.user?.isAdmin == true) {
                Spacer(Modifier.height(12.dp))
                Surface(
                    color = RenCloudGold.copy(alpha = 0.12f),
                    shape = RoundedCornerShape(20.dp),
                    border = BorderStroke(1.dp, RenCloudGold.copy(alpha = 0.4f))
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Security,
                            contentDescription = null,
                            tint = RenCloudGold,
                            modifier = Modifier.size(16.dp)
                        )
                        Text(
                            "Super Admin Account",
                            color = RenCloudGold,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            if (state.isBiometricAuthenticated) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    HorizontalDivider(modifier = Modifier.weight(1f), color = MetallicBorderDark)
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.CheckCircle,
                            contentDescription = null,
                            tint = RenCloudGreen,
                            modifier = Modifier.size(14.dp)
                        )
                        Text(
                            "Identity Verified",
                            fontSize = 10.sp,
                            color = RenCloudGreen,
                            fontWeight = FontWeight.SemiBold,
                            letterSpacing = 1.sp
                        )
                    }
                    HorizontalDivider(modifier = Modifier.weight(1f), color = MetallicBorderDark)
                }
                Spacer(Modifier.height(20.dp))
            }

            // STEP 2: Glass Card Login / Register Form
            AnimatedVisibility(
                visible = state.isBiometricAuthenticated,
                enter = fadeIn(tween(400)) + slideInVertically(tween(400)) { it / 4 },
                exit = fadeOut()
            ) {
                GlassCard(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(24.dp),
                    accentGlow = ElectricCyan,
                    alpha = 0.85f
                ) {
                    Column(
                        modifier = Modifier.padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(14.dp)
                    ) {
                        Text(
                            text = if (state.isRegisterMode) "Create Real Panel Account" else "Sign in to RenCloud",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Black,
                            color = Color.White
                        )
                        Text(
                            text = if (state.isRegisterMode) "Directly synced to panel.rencloud.online" else "Sign in with your Pterodactyl Panel credentials",
                            fontSize = 11.sp,
                            color = TextSecondaryDark,
                            textAlign = TextAlign.Center
                        )

                        if (state.isRegisterMode) {
                            OutlinedTextField(
                                value = fullName,
                                onValueChange = { fullName = it },
                                label = { Text("Full Name") },
                                leadingIcon = { Icon(Icons.Default.Person, contentDescription = null, tint = ElectricCyan) },
                                singleLine = true,
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedBorderColor = ElectricCyan,
                                    unfocusedBorderColor = MetallicBorderDark,
                                    focusedTextColor = Color.White,
                                    unfocusedTextColor = Color.White
                                ),
                                shape = RoundedCornerShape(12.dp),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }

                        OutlinedTextField(
                            value = email,
                            onValueChange = { email = it },
                            label = { Text("Email Address or Username") },
                            leadingIcon = { Icon(Icons.Default.Email, contentDescription = null, tint = ElectricCyan) },
                            singleLine = true,
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = ElectricCyan,
                                unfocusedBorderColor = MetallicBorderDark,
                                focusedTextColor = Color.White,
                                unfocusedTextColor = Color.White
                            ),
                            shape = RoundedCornerShape(12.dp),
                            modifier = Modifier.fillMaxWidth()
                        )

                        OutlinedTextField(
                            value = password,
                            onValueChange = { password = it },
                            label = { Text("Password") },
                            leadingIcon = { Icon(Icons.Default.Lock, contentDescription = null, tint = ElectricCyan) },
                            trailingIcon = {
                                IconButton(onClick = { passwordVisible = !passwordVisible }) {
                                    Icon(
                                        imageVector = if (passwordVisible) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                                        contentDescription = null,
                                        tint = TextSecondaryDark
                                    )
                                }
                            },
                            visualTransformation = if (passwordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                            singleLine = true,
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = ElectricCyan,
                                unfocusedBorderColor = MetallicBorderDark,
                                focusedTextColor = Color.White,
                                unfocusedTextColor = Color.White
                            ),
                            shape = RoundedCornerShape(12.dp),
                            modifier = Modifier.fillMaxWidth()
                        )

                        state.errorMessage?.let { err ->
                            Text(err, color = RenCloudRed, fontSize = 12.sp, fontWeight = FontWeight.SemiBold)
                        }

                        GlassButton(
                            onClick = {
                                if (state.isRegisterMode) {
                                    viewModel.register(fullName, email, password)
                                } else {
                                    viewModel.login(email, password)
                                }
                            },
                            enabled = !state.isLoading,
                            containerColor = ElectricCyan,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            if (state.isLoading) {
                                GlassCircularProgress(size = 24.dp)
                            } else {
                                Text(
                                    if (state.isRegisterMode) "CREATE ACCOUNT" else "SIGN IN",
                                    color = Color.Black,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 13.sp
                                )
                            }
                        }

                        TextButton(onClick = { viewModel.toggleMode() }) {
                            Text(
                                if (state.isRegisterMode) "Already have an account? Sign In" else "Don't have an account? Register on Panel",
                                color = RenCloudGold,
                                fontSize = 12.sp
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun BiometricGlassSection(
    onBiometricClick: () -> Unit,
    isLoading: Boolean
) {
    val infiniteTransition = rememberInfiniteTransition(label = "fingerprint")
    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 0.95f, targetValue = 1.08f,
        animationSpec = infiniteRepeatable(tween(1200, easing = FastOutSlowInEasing), RepeatMode.Reverse),
        label = "fpPulse"
    )

    GlassCard(
        onClick = onBiometricClick,
        modifier = Modifier.fillMaxWidth(),
        accentGlow = MetallicPurple,
        alpha = 0.8f
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .size(70.dp)
                    .scale(pulseScale)
                    .clip(CircleShape)
                    .background(MetallicPurple.copy(alpha = 0.2f))
                    .border(1.dp, MetallicPurple, CircleShape)
            ) {
                Icon(
                    imageVector = Icons.Default.Fingerprint,
                    contentDescription = "Biometric Scan",
                    tint = ElectricCyan,
                    modifier = Modifier.size(38.dp)
                )
            }
            Text("Step 1: Biometric Verification", color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
            Text("Tap to scan fingerprint or face ID to unlock panel session", color = TextSecondaryDark, fontSize = 11.sp, textAlign = TextAlign.Center)
        }
    }
}
