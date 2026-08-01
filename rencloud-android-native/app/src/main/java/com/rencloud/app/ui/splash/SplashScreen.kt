package com.rencloud.app.ui.splash

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.*
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.R
import com.rencloud.app.ui.components.glass.GlassCircularProgress
import com.rencloud.app.ui.components.glass.LiquidGlassBackground
import com.rencloud.app.ui.theme.*
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(onSplashComplete: () -> Unit) {
    var logoVisible by remember { mutableStateOf(false) }
    var textVisible by remember { mutableStateOf(false) }
    var taglineVisible by remember { mutableStateOf(false) }
    var statusText by remember { mutableStateOf("Connecting to RenCloud Gateway...") }

    LaunchedEffect(Unit) {
        delay(150)
        logoVisible = true
        delay(600)
        textVisible = true
        statusText = "Syncing Real Pterodactyl Panel Data..."
        delay(400)
        taglineVisible = true
        statusText = "Catalog & Services Ready"
        delay(800)
        onSplashComplete()
    }

    val infiniteTransition = rememberInfiniteTransition(label = "splash")
    val rotateAnim by infiniteTransition.animateFloat(
        initialValue = 0f, targetValue = 360f,
        animationSpec = infiniteRepeatable(tween(8000, easing = LinearEasing)),
        label = "rotate"
    )
    val pulseAnim by infiniteTransition.animateFloat(
        initialValue = 0.9f, targetValue = 1.15f,
        animationSpec = infiniteRepeatable(tween(1500, easing = FastOutSlowInEasing), RepeatMode.Reverse),
        label = "pulse"
    )

    LiquidGlassBackground {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                // Logo with glass halo glow ring
                AnimatedVisibility(
                    visible = logoVisible,
                    enter = scaleIn(
                        initialScale = 0.2f,
                        animationSpec = spring(
                            dampingRatio = Spring.DampingRatioMediumBouncy,
                            stiffness = Spring.StiffnessLow
                        )
                    ) + fadeIn(tween(600))
                ) {
                    Box(contentAlignment = Alignment.Center, modifier = Modifier.size(180.dp)) {
                        // Rotating gradient ring
                        Box(
                            modifier = Modifier
                                .size(180.dp)
                                .rotate(rotateAnim)
                                .background(Color.Transparent, CircleShape)
                                .border(
                                    2.dp,
                                    Brush.sweepGradient(
                                        listOf(
                                            ElectricCyan.copy(alpha = 0.9f),
                                            MetallicPurple.copy(alpha = 0.8f),
                                            Color.Transparent,
                                            ElectricCyan.copy(alpha = 0.9f)
                                        )
                                    ),
                                    CircleShape
                                )
                        )
                        // Pulsing glow backdrop
                        Box(
                            modifier = Modifier
                                .size(140.dp)
                                .scale(pulseAnim)
                                .blur(25.dp)
                                .background(
                                    Brush.radialGradient(
                                        listOf(MetallicPurple.copy(alpha = 0.5f), Color.Transparent)
                                    ),
                                    CircleShape
                                )
                        )
                        // Real RenCloud logo PNG
                        Image(
                            painter = painterResource(id = R.drawable.rencloud_logo),
                            contentDescription = "RenCloud Logo",
                            modifier = Modifier.size(120.dp),
                            contentScale = ContentScale.Fit
                        )
                    }
                }

                Spacer(Modifier.height(36.dp))

                // Brand name
                AnimatedVisibility(
                    visible = textVisible,
                    enter = slideInVertically(tween(500)) { it / 2 } + fadeIn(tween(500))
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = "RenCloud",
                            fontSize = 42.sp,
                            fontWeight = FontWeight.Black,
                            color = Color.White,
                            letterSpacing = 1.sp
                        )
                        Text(
                            text = "ENTERPRISE SHOWCASE PLATFORM",
                            fontSize = 10.sp,
                            color = ElectricCyan,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 3.sp
                        )
                    }
                }

                Spacer(Modifier.height(16.dp))

                // Tagline & Progress Status
                AnimatedVisibility(
                    visible = taglineVisible,
                    enter = fadeIn(tween(700))
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        GlassCircularProgress(size = 40.dp)
                        Spacer(Modifier.height(12.dp))
                        Text(
                            text = statusText,
                            fontSize = 12.sp,
                            color = TextSecondaryDark,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
            }

            // Version number at bottom
            AnimatedVisibility(
                visible = taglineVisible,
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 36.dp),
                enter = fadeIn(tween(700))
            ) {
                Text(
                    text = "v3.5 — Native Android Glass Showcase",
                    fontSize = 11.sp,
                    color = TextMutedDark
                )
            }
        }
    }
}
