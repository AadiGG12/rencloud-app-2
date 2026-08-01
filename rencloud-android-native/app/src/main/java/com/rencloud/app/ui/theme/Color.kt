package com.rencloud.app.ui.theme

import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.graphics.Color

// Metallic Palette
val MetallicBlack = Color(0xFF080A10)
val MetallicNavy = Color(0xFF0E1320)
val MetallicCardDark = Color(0xFF141B2D)
val MetallicBorderDark = Color(0xFF222C42)

val MetallicPurple = Color(0xFF7C3AED)
val MetallicPurpleGlow = Color(0xFFA855F7)
val MetallicBlue = Color(0xFF2563EB)
val ElectricCyan = Color(0xFF00D4FF)
val PureWhite = Color(0xFFFFFFFF)

// Light Theme Palette
val MetallicLightBg = Color(0xFFF1F5F9)
val MetallicLightSurface = Color(0xFFFFFFFF)
val MetallicLightBorder = Color(0xFFCBD5E1)
val MetallicLightText = Color(0xFF0F172A)
val MetallicLightSecondaryText = Color(0xFF475569)

val MinecraftColor = Color(0xFF10B981)
val VpsColor = Color(0xFF00D4FF)
val DediColor = Color(0xFF7C3AED)
val GameColor = Color(0xFFF59E0B)

val TextPrimaryDark = PureWhite
val TextPrimaryLight = MetallicLightText
val TextSecondaryDark = Color(0xFF94A3B8)
val TextMutedDark = Color(0xFF64748B)

val RenCloudNavy = MetallicNavy
val RenCloudPurple = MetallicPurple
val RenCloudCyan = ElectricCyan
val RenCloudGold = Color(0xFFF59E0B)
val RenCloudCardDark = MetallicCardDark
val RenCloudCardBorder = MetallicBorderDark
val RenCloudSurfaceDark = MetallicBlack
val RenCloudGreen = Color(0xFF10B981)
val RenCloudRed = Color(0xFFEF4444)

// State for Theme switching
val LocalThemeIsDark = compositionLocalOf { mutableStateOf(true) }
