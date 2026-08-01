package com.rencloud.app.ui.components.glass

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.rencloud.app.ui.theme.*

@Composable
fun ShimmerGlassBox(
    modifier: Modifier = Modifier,
    shape: RoundedCornerShape = RoundedCornerShape(12.dp)
) {
    val transition = rememberInfiniteTransition(label = "shimmer")
    val translateAnim by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1000f,
        animationSpec = infiniteRepeatable(
            animation = tween(1200, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "shimmer_x"
    )

    val shimmerColors = listOf(
        MetallicCardDark.copy(alpha = 0.6f),
        ElectricCyan.copy(alpha = 0.2f),
        MetallicCardDark.copy(alpha = 0.6f)
    )

    val brush = Brush.linearGradient(
        colors = shimmerColors,
        start = Offset(translateAnim - 200f, translateAnim - 200f),
        end = Offset(translateAnim, translateAnim)
    )

    Box(
        modifier = modifier
            .clip(shape)
            .background(brush)
    )
}

@Composable
fun GlassCircularProgress(
    modifier: Modifier = Modifier,
    size: Dp = 48.dp
) {
    val infiniteTransition = rememberInfiniteTransition(label = "pulse_loader")
    val haloPulse by infiniteTransition.animateFloat(
        initialValue = 0.8f,
        targetValue = 1.2f,
        animationSpec = infiniteRepeatable(
            animation = tween(800, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "halo"
    )

    Box(
        modifier = modifier.size(size),
        contentAlignment = Alignment.Center
    ) {
        Surface(
            modifier = Modifier.size(size * haloPulse),
            shape = CircleShape,
            color = ElectricCyan.copy(alpha = 0.15f)
        ) {}

        CircularProgressIndicator(
            color = ElectricCyan,
            strokeWidth = 3.dp,
            modifier = Modifier.size(size * 0.8f)
        )
    }
}
