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
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.layout.ContentScale
import androidx.compose.foundation.Image
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.R
import com.rencloud.app.ui.theme.*
import kotlinx.coroutines.delay

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

    // ── Background animations ─────────────────────────────────────────────────
    val infiniteTransition = rememberInfiniteTransition(label = "auth_bg")
    val bgOrb1X by infiniteTransition.animateFloat(
        initialValue = 0.1f, targetValue = 0.3f,
        animationSpec = infiniteRepeatable(tween(7000, easing = FastOutSlowInEasing), RepeatMode.Reverse),
        label = "orb1x"
    )
    val bgOrb2Y by infiniteTransition.animateFloat(
        initialValue = 0.2f, targetValue = 0.5f,
        animationSpec = infiniteRepeatable(tween(9000, easing = FastOutSlowInEasing), RepeatMode.Reverse),
        label = "orb2y"
    )
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

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(RenCloudNavy)
    ) {
        // ── Animated Orbs ───────────────────────────────────────────────────
        Canvas(modifier = Modifier.fillMaxSize()) {
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(RenCloudPurple.copy(alpha = 0.25f), Color.Transparent),
                    radius = 260f
                ),
                radius = 260f,
                center = Offset(size.width * bgOrb1X, size.height * 0.15f)
            )
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(RenCloudCyan.copy(alpha = 0.15f), Color.Transparent),
                    radius = 200f
                ),
                radius = 200f,
                center = Offset(size.width * 0.8f, size.height * bgOrb2Y)
            )
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(RenCloudGold.copy(alpha = 0.08f), Color.Transparent),
                    radius = 150f
                ),
                radius = 150f,
                center = Offset(size.width * 0.5f, size.height * 0.9f)
            )
        }

        // Grid overlay
        Canvas(modifier = Modifier.fillMaxSize()) {
            val gridSpacing = 60f
            val gridColor = Color.White.copy(alpha = 0.025f)
            var x = 0f
            while (x < size.width) {
                drawLine(gridColor, Offset(x, 0f), Offset(x, size.height), 1f)
                x += gridSpacing
            }
            var y = 0f
            while (y < size.height) {
                drawLine(gridColor, Offset(0f, y), Offset(size.width, y), 1f)
                y += gridSpacing
            }
        }

        // ── Content ─────────────────────────────────────────────────────────
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(Modifier.height(48.dp))

            // ── Logo Section ─────────────────────────────────────────────
            Box(contentAlignment = Alignment.Center) {
                // Outer rotating ring
                Box(
                    modifier = Modifier
                        .size(120.dp)
                        .rotate(logoRotate)
                        .border(
                            1.dp,
                            Brush.sweepGradient(
                                listOf(
                                    RenCloudCyan.copy(alpha = logoGlow),
                                    RenCloudPurple,
                                    RenCloudCyan.copy(alpha = 0.1f)
                                )
                            ),
                            CircleShape
                        )
                )
                // Glow background
                Box(
                    modifier = Modifier
                        .size(100.dp)
                        .blur(20.dp)
                        .background(
                            Brush.radialGradient(
                                listOf(
                                    RenCloudPurple.copy(alpha = 0.4f * logoGlow),
                                    Color.Transparent
                                )
                            ),
                            CircleShape
                        )
                )
                // Logo
                Box(
                    modifier = Modifier
                        .size(90.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.linearGradient(
                                listOf(
                                    RenCloudPurple.copy(alpha = 0.8f),
                                    RenCloudNavy.copy(alpha = 0.6f)
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

            Spacer(Modifier.height(24.dp))

            Text(
                text = "RenCloud",
                fontSize = 32.sp,
                fontWeight = FontWeight.Black,
                color = Color.White,
                letterSpacing = 1.sp
            )
            Text(
                text = "ENTERPRISE CLOUD PLATFORM",
                fontSize = 10.sp,
                fontWeight = FontWeight.Medium,
                color = RenCloudCyan,
                letterSpacing = 3.sp
            )

            Spacer(Modifier.height(40.dp))

            // ── STEP 1: Biometric ──────────────────────────────────────────
            AnimatedVisibility(
                visible = !state.isBiometricAuthenticated,
                enter = fadeIn() + expandVertically(),
                exit = fadeOut() + shrinkVertically()
            ) {
                BiometricSection(
                    onBiometricClick = { onBiometricClick() },
                    isLoading = state.isLoading
                )
            }

            // ── Admin badge ────────────────────────────────────────────────
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

            // Biometric done divider
            if (state.isBiometricAuthenticated) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    HorizontalDivider(modifier = Modifier.weight(1f), color = RenCloudCardBorder)
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
                    HorizontalDivider(modifier = Modifier.weight(1f), color = RenCloudCardBorder)
                }
                Spacer(Modifier.height(20.dp))
            }

            // ── STEP 2: Login/Register Form ────────────────────────────────
            AnimatedVisibility(
                visible = state.isBiometricAuthenticated,
                enter = fadeIn(tween(400)) + slideInVertically(tween(400)) { it / 4 },
                exit = fadeOut()
            ) {
                Surface(
                    modifier = Modifier.fillMaxWidth(),
                    color = RenCloudCardDark.copy(alpha = 0.85f),
                    shape = RoundedCornerShape(24.dp),
                    border = BorderStroke(1.dp, RenCloudCardBorder)
                ) {
                    Column(
                        modifier = Modifier.padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(14.dp)
                    ) {
                        // Form header
                        Text(
                            text = if (state.isRegisterMode) "Create Account" else "Welcome Back",
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                        Text(
                            text = if (state.isRegisterMode)
                                "Register your RenCloud panel account"
                            else
                                "Sign in to your cloud control panel",
                            fontSize = 12.sp,
                            color = TextSecondaryDark,
                            textAlign = TextAlign.Center
                        )

                        HorizontalDivider(color = RenCloudCardBorder)

                        // Full Name (register mode)
                        AnimatedVisibility(
                            visible = state.isRegisterMode,
                            enter = fadeIn() + expandVertically(),
                            exit = fadeOut() + shrinkVertically()
                        ) {
                            AuthTextField(
                                value = fullName,
                                onValueChange = { fullName = it },
                                label = "Full Name",
                                icon = Icons.Default.Person
                            )
                        }

                        // Email
                        AuthTextField(
                            value = email,
                            onValueChange = { email = it },
                            label = "Email Address",
                            icon = Icons.Default.Email,
                            keyboardType = KeyboardType.Email
                        )

                        // Password
                        AuthTextField(
                            value = password,
                            onValueChange = { password = it },
                            label = "Password",
                            icon = Icons.Default.Lock,
                            isPassword = true,
                            passwordVisible = passwordVisible,
                            onTogglePassword = { passwordVisible = !passwordVisible }
                        )

                        // Error message
                        AnimatedVisibility(
                            visible = state.errorMessage != null,
                            enter = fadeIn() + expandVertically(),
                            exit = fadeOut() + shrinkVertically()
                        ) {
                            Surface(
                                color = RenCloudRed.copy(alpha = 0.1f),
                                shape = RoundedCornerShape(10.dp),
                                border = BorderStroke(0.5.dp, RenCloudRed.copy(alpha = 0.3f))
                            ) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(12.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    Icon(
                                        Icons.Default.Warning,
                                        contentDescription = null,
                                        tint = RenCloudRed,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Text(
                                        text = state.errorMessage ?: "",
                                        color = RenCloudRed,
                                        fontSize = 12.sp
                                    )
                                }
                            }
                        }

                        // Success message
                        AnimatedVisibility(
                            visible = state.successMessage != null,
                            enter = fadeIn() + expandVertically(),
                            exit = fadeOut() + shrinkVertically()
                        ) {
                            Surface(
                                color = RenCloudGreen.copy(alpha = 0.1f),
                                shape = RoundedCornerShape(10.dp),
                                border = BorderStroke(0.5.dp, RenCloudGreen.copy(alpha = 0.3f))
                            ) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(12.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    Icon(
                                        Icons.Default.CheckCircle,
                                        contentDescription = null,
                                        tint = RenCloudGreen,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Text(
                                        text = state.successMessage ?: "",
                                        color = RenCloudGreen,
                                        fontSize = 12.sp
                                    )
                                }
                            }
                        }

                        // Primary action button
                        Button(
                            onClick = {
                                if (state.isRegisterMode) viewModel.register(fullName, email, password)
                                else viewModel.login(email, password)
                            },
                            enabled = !state.isLoading && email.isNotBlank() && password.isNotBlank(),
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(52.dp),
                            shape = RoundedCornerShape(14.dp),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = RenCloudPurple,
                                disabledContainerColor = RenCloudPurple.copy(alpha = 0.4f)
                            )
                        ) {
                            AnimatedContent(
                                targetState = state.isLoading,
                                transitionSpec = { fadeIn() togetherWith fadeOut() },
                                label = "loginBtn"
                            ) { loading ->
                                if (loading) {
                                    Row(
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                                    ) {
                                        CircularProgressIndicator(
                                            color = Color.White,
                                            modifier = Modifier.size(18.dp),
                                            strokeWidth = 2.dp
                                        )
                                        Text("Authenticating...", fontWeight = FontWeight.Bold)
                                    }
                                } else {
                                    Row(
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                                    ) {
                                        Icon(
                                            if (state.isRegisterMode) Icons.Default.PersonAdd else Icons.Default.Login,
                                            contentDescription = null,
                                            modifier = Modifier.size(18.dp)
                                        )
                                        Text(
                                            text = if (state.isRegisterMode) "CREATE ACCOUNT" else "SIGN IN",
                                            fontWeight = FontWeight.Black,
                                            letterSpacing = 1.sp
                                        )
                                    }
                                }
                            }
                        }

                        // Toggle mode
                        TextButton(onClick = { viewModel.toggleMode() }) {
                            Text(
                                text = if (state.isRegisterMode)
                                    "Already have an account? Sign In"
                                else
                                    "Need an account? Create one",
                                fontSize = 12.sp,
                                color = RenCloudCyan
                            )
                        }
                    }
                }
            }

            Spacer(Modifier.height(32.dp))
        }
    }
}

@Composable
private fun BiometricSection(
    onBiometricClick: () -> Unit,
    isLoading: Boolean
) {
    val infiniteTransition = rememberInfiniteTransition(label = "bio")
    val ring1Alpha by infiniteTransition.animateFloat(
        initialValue = 0.6f, targetValue = 0f,
        animationSpec = infiniteRepeatable(tween(1800, easing = FastOutSlowInEasing)),
        label = "ring1"
    )
    val ring1Scale by infiniteTransition.animateFloat(
        initialValue = 1f, targetValue = 1.8f,
        animationSpec = infiniteRepeatable(tween(1800, easing = FastOutSlowInEasing)),
        label = "ring1scale"
    )
    val ring2Alpha by infiniteTransition.animateFloat(
        initialValue = 0.6f, targetValue = 0f,
        animationSpec = infiniteRepeatable(tween(1800, 600, easing = FastOutSlowInEasing)),
        label = "ring2"
    )
    val ring2Scale by infiniteTransition.animateFloat(
        initialValue = 1f, targetValue = 1.8f,
        animationSpec = infiniteRepeatable(tween(1800, 600, easing = FastOutSlowInEasing)),
        label = "ring2scale"
    )

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Surface(
            color = RenCloudCardDark.copy(alpha = 0.85f),
            shape = RoundedCornerShape(24.dp),
            border = BorderStroke(1.dp, RenCloudCardBorder),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.padding(28.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    text = "Biometric Authentication",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White,
                    textAlign = TextAlign.Center
                )
                Text(
                    text = "Step 1: Verify your identity using\nfingerprint or face recognition",
                    fontSize = 12.sp,
                    color = TextSecondaryDark,
                    textAlign = TextAlign.Center,
                    lineHeight = 18.sp
                )

                // Animated fingerprint button
                Box(
                    modifier = Modifier.size(100.dp),
                    contentAlignment = Alignment.Center
                ) {
                    // Pulse rings
                    Box(
                        modifier = Modifier
                            .size(100.dp)
                            .scale(ring1Scale)
                            .border(
                                2.dp,
                                RenCloudCyan.copy(alpha = ring1Alpha),
                                CircleShape
                            )
                    )
                    Box(
                        modifier = Modifier
                            .size(100.dp)
                            .scale(ring2Scale)
                            .border(
                                2.dp,
                                RenCloudCyan.copy(alpha = ring2Alpha),
                                CircleShape
                            )
                    )

                    // Button
                    Button(
                        onClick = onBiometricClick,
                        enabled = !isLoading,
                        modifier = Modifier.size(80.dp),
                        shape = CircleShape,
                        colors = ButtonDefaults.buttonColors(
                            containerColor = RenCloudCyan.copy(alpha = 0.15f),
                            disabledContainerColor = RenCloudCardBorder
                        ),
                        border = BorderStroke(2.dp, RenCloudCyan),
                        contentPadding = PaddingValues(0.dp)
                    ) {
                        if (isLoading) {
                            CircularProgressIndicator(
                                color = RenCloudCyan,
                                modifier = Modifier.size(28.dp),
                                strokeWidth = 2.dp
                            )
                        } else {
                            Icon(
                                imageVector = Icons.Default.Fingerprint,
                                contentDescription = "Biometric Login",
                                tint = RenCloudCyan,
                                modifier = Modifier.size(36.dp)
                            )
                        }
                    }
                }

                Text(
                    text = "Tap to authenticate",
                    fontSize = 12.sp,
                    color = RenCloudCyan,
                    fontWeight = FontWeight.Medium
                )
            }
        }
    }
}

@Composable
private fun AuthTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    icon: ImageVector,
    keyboardType: KeyboardType = KeyboardType.Text,
    isPassword: Boolean = false,
    passwordVisible: Boolean = false,
    onTogglePassword: () -> Unit = {}
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = {
            Text(label, color = TextSecondaryDark, fontSize = 13.sp)
        },
        leadingIcon = {
            Icon(icon, contentDescription = null, tint = RenCloudCyan.copy(alpha = 0.7f))
        },
        trailingIcon = if (isPassword) {
            {
                IconButton(onClick = onTogglePassword) {
                    Icon(
                        imageVector = if (passwordVisible) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                        contentDescription = null,
                        tint = TextSecondaryDark
                    )
                }
            }
        } else null,
        visualTransformation = if (isPassword && !passwordVisible)
            PasswordVisualTransformation() else VisualTransformation.None,
        keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
        singleLine = true,
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = RenCloudCyan,
            unfocusedBorderColor = RenCloudCardBorder,
            focusedLabelColor = RenCloudCyan,
            unfocusedLabelColor = TextSecondaryDark,
            focusedContainerColor = RenCloudCardDark,
            unfocusedContainerColor = RenCloudNavy.copy(alpha = 0.6f),
            focusedTextColor = Color.White,
            unfocusedTextColor = Color.White,
            cursorColor = RenCloudCyan
        ),
        shape = RoundedCornerShape(12.dp),
        modifier = Modifier.fillMaxWidth()
    )
}
