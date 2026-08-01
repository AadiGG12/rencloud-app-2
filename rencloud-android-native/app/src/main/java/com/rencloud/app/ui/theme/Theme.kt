package com.rencloud.app.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView

private val DarkColorScheme = darkColorScheme(
    primary = RenCloudPurple,
    secondary = RenCloudCyan,
    tertiary = RenCloudGold,
    background = RenCloudNavy,
    surface = RenCloudSurfaceDark,
    onPrimary = TextPrimaryDark,
    onSecondary = RenCloudNavy,
    onBackground = TextPrimaryDark,
    onSurface = TextPrimaryDark
)

private val LightColorScheme = lightColorScheme(
    primary = RenCloudPurple,
    secondary = RenCloudCyan,
    tertiary = RenCloudGold,
    background = RenCloudLightBg,
    surface = RenCloudLightSurface,
    onPrimary = TextPrimaryDark,
    onSecondary = RenCloudNavy,
    onBackground = TextPrimaryLight,
    onSurface = TextPrimaryLight
)

@Composable
fun RenCloudTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme
    val view = LocalView.current

    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.background.toArgb()
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        content = content
    )
}
