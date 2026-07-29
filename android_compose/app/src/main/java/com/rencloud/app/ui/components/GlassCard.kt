package com.rencloud.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    cornerRadius: Dp = 20.dp,
    borderGlow: Brush? = null,
    content: @Composable ColumnScope.() -> Unit
) {
    val isDark = MaterialTheme.colorScheme.background.red < 0.5f

    // Frosted Glass Colors
    val glassBg = if (isDark) {
        Color(0x331E293B) // Frosted Deep Onyx Glass
    } else {
        Color(0x88FFFFFF) // Crisp Liquid White Glass
    }

    val glassBorder = borderGlow ?: if (isDark) {
        Brush.linearGradient(
            listOf(
                Color.White.copy(alpha = 0.25f),
                Color(0xFF7C3AED).copy(alpha = 0.4f),
                Color(0xFF06B6D4).copy(alpha = 0.4f),
                Color.White.copy(alpha = 0.1f)
            )
        )
    } else {
        Brush.linearGradient(
            listOf(
                Color.White.copy(alpha = 0.8f),
                Color(0xFF7C3AED).copy(alpha = 0.3f),
                Color(0xFF06B6D4).copy(alpha = 0.3f),
                Color.White.copy(alpha = 0.4f)
            )
        )
    }

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(cornerRadius))
            .background(glassBorder)
            .padding(1.5.dp)
    ) {
        Surface(
            shape = RoundedCornerShape(cornerRadius - 1.dp),
            color = glassBg,
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(
                modifier = Modifier.padding(18.dp),
                content = content
            )
        }
    }
}
