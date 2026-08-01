package com.rencloud.app.ui.components.glass

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.rencloud.app.ui.theme.ElectricCyan
import com.rencloud.app.ui.theme.MetallicPurple
import com.rencloud.app.ui.theme.TextSecondaryDark

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

@Composable
fun GlassConfirmDialog(
    title: String,
    message: String,
    onConfirm: () -> Unit,
    onDismiss: () -> Unit,
    confirmText: String = "CONFIRM",
    confirmColor: Color = ElectricCyan
) {
    GlassDialog(onDismissRequest = onDismiss, accentGlow = confirmColor) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(title, fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color.White)
            Text(message, fontSize = 12.sp, color = TextSecondaryDark)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                TextButton(onClick = onDismiss, modifier = Modifier.weight(1f)) {
                    Text("CANCEL", color = TextSecondaryDark)
                }
                GlassButton(onClick = onConfirm, containerColor = confirmColor, modifier = Modifier.weight(1f)) {
                    Text(confirmText, color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                }
            }
        }
    }
}
