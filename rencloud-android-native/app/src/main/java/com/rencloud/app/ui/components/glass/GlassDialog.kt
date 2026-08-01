package com.rencloud.app.ui.components.glass

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import com.rencloud.app.ui.theme.ElectricCyan
import com.rencloud.app.ui.theme.MetallicPurple

@Composable
fun GlassDialog(
    onDismissRequest: () -> Unit,
    accentGlow: Color = ElectricCyan,
    content: @Composable () -> Unit
) {
    Dialog(onDismissRequest = onDismissRequest) {
        GlassSurface(
            modifier = Modifier
                .fillMaxWidth()
                .wrapContentHeight(),
            shape = RoundedCornerShape(20.dp),
            borderColor = MetallicPurple,
            accentGlow = accentGlow,
            alpha = 0.88f,
            content = content
        )
    }
}
