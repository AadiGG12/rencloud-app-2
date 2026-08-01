package com.rencloud.app.ui.theme

import android.app.Activity
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView

@Composable
fun RenCloudTheme(
    darkTheme: Boolean = LocalThemeIsDark.current.value,
    content: @Composable () -> Unit
) {
    val animatedBg by animateColorAsState(
        targetValue = if (darkTheme) MetallicNavy else MetallicLightBg,
        animationSpec = tween(400),
        label = "theme_bg"
    )
    val animatedSurface by animateColorAsState(
        targetValue = if (darkTheme) MetallicCardDark else MetallicLightSurface,
        animationSpec = tween(400),
        label = "theme_surface"
    )

    val colorScheme = if (darkTheme) {
        darkColorScheme(
            primary = MetallicPurple,
            secondary = ElectricCyan,
            background = animatedBg,
            surface = animatedSurface,
            onBackground = PureWhite,
            onSurface = PureWhite
        )
    } else {
        lightColorScheme(
            primary = MetallicPurple,
            secondary = MetallicBlue,
            background = animatedBg,
            surface = animatedSurface,
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
