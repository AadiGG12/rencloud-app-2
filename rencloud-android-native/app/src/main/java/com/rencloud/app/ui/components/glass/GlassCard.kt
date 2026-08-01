package com.rencloud.app.ui.components.glass

import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.*
import androidx.compose.ui.unit.dp
import com.rencloud.app.ui.theme.*

@Composable
fun GlassSurface(
    modifier: Modifier = Modifier,
    shape: Shape = RoundedCornerShape(16.dp),
    borderColor: Color = MetallicBorderDark,
    accentGlow: Color? = null,
    alpha: Float = 0.75f,
    content: @Composable () -> Unit
) {
    val isDark = LocalThemeIsDark.current.value

    val surfaceColor = if (isDark) {
        MetallicCardDark.copy(alpha = alpha)
    } else {
        MetallicLightSurface.copy(alpha = 0.85f)
    }

    val rimBrush = if (accentGlow != null) {
        Brush.linearGradient(listOf(borderColor, accentGlow.copy(alpha = 0.6f)))
    } else {
        SolidColor(borderColor)
    }

    Surface(
        modifier = modifier
            .clip(shape)
            .blur(16.dp),
        color = surfaceColor,
        shape = shape,
        border = BorderStroke(1.dp, rimBrush),
        shadowElevation = if (accentGlow != null) 8.dp else 2.dp
    ) {
        content()
    }
}

@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    onClick: (() -> Unit)? = null,
    shape: Shape = RoundedCornerShape(16.dp),
    accentGlow: Color? = null,
    alpha: Float = 0.75f,
    content: @Composable () -> Unit
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()

    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.97f else 1f,
        animationSpec = spring(stiffness = Spring.StiffnessMediumLow),
        label = "glass_press"
    )

    GlassSurface(
        modifier = modifier
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            }
            .then(
                if (onClick != null) {
                    Modifier.clickable(
                        interactionSource = interactionSource,
                        indication = null,
                        onClick = onClick
                    )
                } else Modifier
            ),
        shape = shape,
        accentGlow = accentGlow,
        alpha = alpha,
        content = content
    )
}
