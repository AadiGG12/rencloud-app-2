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
import com.rencloud.app.ui.theme.*
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(onSplashComplete: () -> Unit) {
    var logoVisible by remember { mutableStateOf(false) }
    var textVisible by remember { mutableStateOf(false) }
    var taglineVisible by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        delay(150)
        logoVisible = true
        delay(700)
        textVisible = true
        delay(400)
        taglineVisible = true
        delay(1200)
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
    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.3f, targetValue = 0.7f,
        animationSpec = infiniteRepeatable(tween(1500, easing = FastOutSlowInEasing), RepeatMode.Reverse),
        label = "glow"
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.radialGradient(
                    colors = listOf(Color(0xFF0F1527), Color(0xFF090D16))
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        // Purple orb top-left
        Box(
            modifier = Modifier
                .size(350.dp)
                .offset(x = (-100).dp, y = (-120).dp)
                .blur(80.dp)
                .background(
                    Brush.radialGradient(
                        listOf(RenCloudPurple.copy(alpha = 0.35f * glowAlpha), Color.Transparent)
                    ),
                    CircleShape
                )
                .align(Alignment.TopStart)
        )
        // Cyan orb bottom-right
        Box(
            modifier = Modifier
                .size(280.dp)
                .offset(x = 80.dp, y = 80.dp)
                .blur(60.dp)
                .background(
                    Brush.radialGradient(
                        listOf(RenCloudCyan.copy(alpha = 0.2f * glowAlpha), Color.Transparent)
                    ),
                    CircleShape
                )
                .align(Alignment.BottomEnd)
        )

        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Logo with elastic scale-in animation
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
                                        RenCloudCyan.copy(alpha = 0.9f),
                                        RenCloudPurple.copy(alpha = 0.8f),
                                        Color.Transparent,
                                        RenCloudCyan.copy(alpha = 0.9f)
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
                                    listOf(RenCloudPurple.copy(alpha = 0.5f), Color.Transparent)
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

            Spacer(Modifier.height(40.dp))

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
                        text = "ENTERPRISE CLOUD PLATFORM",
                        fontSize = 11.sp,
                        color = RenCloudCyan,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 4.sp
                    )
                }
            }

            Spacer(Modifier.height(16.dp))

            // Tagline
            AnimatedVisibility(
                visible = taglineVisible,
                enter = fadeIn(tween(700))
            ) {
                Text(
                    text = "Deploy. Scale. Dominate.",
                    fontSize = 15.sp,
                    color = TextSecondaryDark,
                    fontWeight = FontWeight.Medium
                )
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
                text = "v3.3.0 — Native Android",
                fontSize = 11.sp,
                color = TextMutedDark
            )
        }
    }
}
