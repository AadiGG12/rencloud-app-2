package com.rencloud.app.ui.components.glass

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import com.rencloud.app.ui.theme.*

@Composable
fun LiquidGlassBackground(
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    val isDark = LocalThemeIsDark.current.value

    val infiniteTransition = rememberInfiniteTransition(label = "liquid_bg")

    val blob1OffsetX by infiniteTransition.animateFloat(
        initialValue = -100f,
        targetValue = 300f,
        animationSpec = infiniteRepeatable(
            animation = tween(8000, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "b1x"
    )

    val blob1OffsetY by infiniteTransition.animateFloat(
        initialValue = -50f,
        targetValue = 400f,
        animationSpec = infiniteRepeatable(
            animation = tween(10000, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "b1y"
    )

    val blob2OffsetX by infiniteTransition.animateFloat(
        initialValue = 400f,
        targetValue = -100f,
        animationSpec = infiniteRepeatable(
            animation = tween(12000, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "b2x"
    )

    val blob2OffsetY by infiniteTransition.animateFloat(
        initialValue = 600f,
        targetValue = 100f,
        animationSpec = infiniteRepeatable(
            animation = tween(9000, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "b2y"
    )

    val baseBgColor = if (isDark) MetallicNavy else MetallicLightBg
    val purpleBlob = if (isDark) MetallicPurple.copy(alpha = 0.18f) else MetallicPurple.copy(alpha = 0.08f)
    val cyanBlob = if (isDark) ElectricCyan.copy(alpha = 0.15f) else ElectricCyan.copy(alpha = 0.07f)

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(baseBgColor)
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(purpleBlob, Color.Transparent),
                    center = Offset(size.width * 0.2f + blob1OffsetX, size.height * 0.3f + blob1OffsetY),
                    radius = size.width * 0.65f
                ),
                center = Offset(size.width * 0.2f + blob1OffsetX, size.height * 0.3f + blob1OffsetY),
                radius = size.width * 0.65f
            )

            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(cyanBlob, Color.Transparent),
                    center = Offset(size.width * 0.8f + blob2OffsetX, size.height * 0.7f + blob2OffsetY),
                    radius = size.width * 0.7f
                ),
                center = Offset(size.width * 0.8f + blob2OffsetX, size.height * 0.7f + blob2OffsetY),
                radius = size.width * 0.7f
            )
        }

        content()
    }
}
