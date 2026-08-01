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
            Spacer(Modifier.height(30.dp))

            // Header Top Bar with Back Button when authenticated
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onNavigateHome) {
                    Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = Color.White)
                }
                Text(
                    text = if (state.isAuthenticated) "Account Profile" else "RenCloud Auth",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Spacer(Modifier.width(48.dp))
            }

            Spacer(Modifier.height(16.dp))

            // Logo Section
            Box(contentAlignment = Alignment.Center) {
                Box(
                    modifier = Modifier
                        .size(110.dp)
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
                        .size(90.dp)
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
                        .size(80.dp)
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
                        modifier = Modifier.size(56.dp)
                    )
                }
            }

            Spacer(Modifier.height(16.dp))

            Text(
                text = "RenCloud",
                fontSize = 28.sp,
                fontWeight = FontWeight.Black,
                color = Color.White,
                letterSpacing = 1.sp
            )
            Text(
                text = "ENTERPRISE SHOWCASE PLATFORM",
                fontSize = 9.sp,
                fontWeight = FontWeight.Medium,
                color = ElectricCyan,
                letterSpacing = 2.5.sp
            )

            Spacer(Modifier.height(24.dp))

            if (state.isAuthenticated && state.user != null) {
                // ── LOGGED IN ACCOUNT PROFILE VIEW ─────────────────────────
                val user = state.user!!
                GlassCard(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(24.dp),
                    accentGlow = if (user.isAdmin) RenCloudGold else ElectricCyan,
                    alpha = 0.88f
                ) {
                    Column(
                        modifier = Modifier.padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(14.dp)
                    ) {
                        Surface(
                            color = if (user.isAdmin) RenCloudGold.copy(alpha = 0.15f) else ElectricCyan.copy(alpha = 0.15f),
                            shape = CircleShape,
                            border = BorderStroke(1.dp, if (user.isAdmin) RenCloudGold else ElectricCyan)
                        ) {
                            Icon(
                                imageVector = if (user.isAdmin) Icons.Default.Security else Icons.Default.Person,
                                contentDescription = null,
                                tint = if (user.isAdmin) RenCloudGold else ElectricCyan,
                                modifier = Modifier
                                    .padding(16.dp)
                                    .size(36.dp)
                            )
                        }

                        Text(
                            text = user.fullName,
                            fontSize = 22.sp,
                            fontWeight = FontWeight.Black,
                            color = Color.White
                        )
                        Text(
                            text = user.email,
                            fontSize = 13.sp,
                            color = TextSecondaryDark
                        )

                        Row(
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Surface(
                                color = if (user.isAdmin) RenCloudGold.copy(alpha = 0.15f) else MetallicPurple.copy(alpha = 0.2f),
                                shape = RoundedCornerShape(6.dp)
                            ) {
                                Text(
                                    text = if (user.isAdmin) "SUPER ADMIN" else "CLIENT ACCOUNT",
                                    fontSize = 9.sp,
                                    fontWeight = FontWeight.Black,
                                    color = if (user.isAdmin) RenCloudGold else MetallicPurple,
                                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                                )
                            }
                            Surface(
                                color = ElectricCyan.copy(alpha = 0.12f),
                                shape = RoundedCornerShape(6.dp)
                            ) {
                                Text(
                                    text = "ID: #${user.id}",
                                    fontSize = 9.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = ElectricCyan,
                                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                                )
                            }
                        }

                        HorizontalDivider(color = MetallicBorderDark, modifier = Modifier.padding(vertical = 4.dp))

                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.CheckCircle,
                                contentDescription = null,
                                tint = RenCloudGreen,
                                modifier = Modifier.size(16.dp)
                            )
                            Text(
                                text = "Synced Live with panel.rencloud.online",
                                fontSize = 11.sp,
                                color = RenCloudGreen,
                                fontWeight = FontWeight.SemiBold
                            )
                        }

                        Spacer(Modifier.height(8.dp))

                        GlassButton(
                            onClick = onNavigateHome,
                            containerColor = ElectricCyan,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text("RETURN TO CATALOG", color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                        }

                        OutlinedButton(
                            onClick = { viewModel.logout() },
                            colors = ButtonDefaults.outlinedButtonColors(contentColor = RenCloudRed),
                            border = BorderStroke(1.dp, RenCloudRed.copy(alpha = 0.5f)),
                            shape = RoundedCornerShape(12.dp),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Icon(Icons.Default.Logout, contentDescription = null, modifier = Modifier.size(16.dp))
                            Spacer(Modifier.width(8.dp))
                            Text("SIGN OUT / LOG OUT", fontWeight = FontWeight.Bold, fontSize = 12.sp)
                        }
                    }
                }
            } else {
                // ── LOGGED OUT AUTH FORM ───────────────────────────────────
                AnimatedVisibility(
                    visible = !state.isBiometricAuthenticated,
                    enter = fadeIn() + expandVertically(),
                    exit = fadeOut() + shrinkVertically()
                ) {
                    BiometricGlassSection(
                        onBiometricClick = { onBiometricClick() },
                        onBypassBiometrics = { viewModel.setBiometricAuthenticated(true) },
                        isLoading = state.isLoading
                    )
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
}

@Composable
private fun BiometricGlassSection(
    onBiometricClick: () -> Unit,
    onBypassBiometrics: () -> Unit,
    isLoading: Boolean
) {
    val infiniteTransition = rememberInfiniteTransition(label = "fingerprint")
    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 0.95f, targetValue = 1.08f,
        animationSpec = infiniteRepeatable(tween(1200, easing = FastOutSlowInEasing), RepeatMode.Reverse),
        label = "fpPulse"
    )

    GlassCard(
        modifier = Modifier.fillMaxWidth(),
        accentGlow = MetallicPurple,
        alpha = 0.88f
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .size(70.dp)
                    .scale(pulseScale)
                    .clip(CircleShape)
                    .clickable { onBiometricClick() }
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
            Text("Step 1: Biometric Verification", color = Color.White, fontSize = 15.sp, fontWeight = FontWeight.Bold)
            Text("Tap icon to scan fingerprint or face ID to unlock panel session", color = TextSecondaryDark, fontSize = 11.sp, textAlign = TextAlign.Center)
            
            Spacer(Modifier.height(4.dp))

            GlassButton(
                onClick = onBypassBiometrics,
                containerColor = ElectricCyan,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Icon(Icons.Default.Email, contentDescription = null, tint = Color.Black, modifier = Modifier.size(18.dp))
                    Text("CONTINUE WITH EMAIL & PASSWORD", color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                }
            }
        }
    }
}
