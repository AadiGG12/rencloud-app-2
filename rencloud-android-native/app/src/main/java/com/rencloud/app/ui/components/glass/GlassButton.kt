package com.rencloud.app.ui.components.glass

import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.ui.theme.*

@Composable
fun GlassButton(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    containerColor: Color = ElectricCyan,
    contentColor: Color = Color.Black,
    enabled: Boolean = true,
    content: @Composable RowScope.() -> Unit
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()

    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.95f else 1f,
        animationSpec = spring(stiffness = Spring.StiffnessMediumLow),
        label = "btn_press"
    )

    Surface(
        modifier = modifier
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
                this.alpha = if (enabled) 1f else 0.5f
            }
            .clip(RoundedCornerShape(12.dp))
            .clickable(
                enabled = enabled,
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            ),
        color = containerColor,
        shape = RoundedCornerShape(12.dp),
        border = BorderStroke(1.dp, Brush.linearGradient(listOf(Color.White.copy(alpha = 0.4f), containerColor)))
    ) {
        Row(
            modifier = Modifier
                .padding(horizontal = 16.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically,
            content = content
        )
    }
}
