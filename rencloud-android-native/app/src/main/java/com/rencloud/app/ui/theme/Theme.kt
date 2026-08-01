package com.rencloud.app.ui.theme

import android.app.Activity
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView

@Composable
fun RenCloudTheme(
    darkTheme: Boolean = LocalThemeIsDark.current.value,
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) {
        darkColorScheme(
            primary = MetallicPurple,
            secondary = ElectricCyan,
            background = MetallicNavy,
            surface = MetallicCardDark,
            onBackground = PureWhite,
            onSurface = PureWhite
        )
    } else {
        lightColorScheme(
            primary = MetallicPurple,
            secondary = MetallicBlue,
            background = MetallicLightBg,
            surface = MetallicLightSurface,
            onBackground = MetallicLightText,
            onSurface = MetallicLightText
        )
    }

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            (view.context as? Activity)?.window?.statusBarColor = colorScheme.background.toArgb()
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        content = content
    )
}
