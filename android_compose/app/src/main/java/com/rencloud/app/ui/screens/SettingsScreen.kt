package com.rencloud.app.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.R
import com.rencloud.app.data.AppCurrency

@Composable
fun SettingsScreen(
    darkTheme: Boolean,
    onDarkThemeToggle: (Boolean) -> Unit,
    currency: AppCurrency,
    onCurrencyChange: (AppCurrency) -> Unit,
    biometricsEnabled: Boolean,
    onBiometricsToggle: (Boolean) -> Unit,
    onDiscordClick: () -> Unit,
    onCheckUpdateClick: () -> Unit
) {
    val colorScheme = MaterialTheme.colorScheme

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(colorScheme.background)
            .padding(20.dp)
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Logo & Header
        Image(
            painter = painterResource(id = R.drawable.logo),
            contentDescription = "RenCloud Logo",
            modifier = Modifier.size(64.dp)
        )
        Spacer(modifier = Modifier.height(10.dp))
        Text("RenCloud Preferences & Security", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
        Text("Version 2.0.0 (Native Jetpack Compose)", fontSize = 12.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))

        Spacer(modifier = Modifier.height(20.dp))

        // Live Node Status Widget
        Surface(
            shape = RoundedCornerShape(16.dp),
            color = colorScheme.surface,
            border = androidx.compose.foundation.BorderStroke(1.dp, colorScheme.secondary.copy(alpha = 0.4f)),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Row(
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Surface(shape = CircleShape, color = Color(0xFF10B981), modifier = Modifier.size(10.dp)) {}
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("All RenCloud Nodes Operational", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
                    }
                    Text("TPS 20.0", fontSize = 11.sp, fontWeight = FontWeight.Black, color = Color(0xFF10B981))
                }

                Spacer(modifier = Modifier.height(8.dp))
                HorizontalDivider(color = colorScheme.outlineVariant)
                Spacer(modifier = Modifier.height(8.dp))

                Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                    Text("Online Players: 142 / 200", fontSize = 11.sp, color = colorScheme.onSurface.copy(alpha = 0.7f))
                    Text("Network Ping: 18ms", fontSize = 11.sp, color = colorScheme.onSurface.copy(alpha = 0.7f))
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Dark Theme Switch Tile
        Surface(
            shape = RoundedCornerShape(14.dp),
            color = colorScheme.surface,
            border = androidx.compose.foundation.BorderStroke(1.dp, colorScheme.outlineVariant),
            modifier = Modifier.fillMaxWidth()
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = if (darkTheme) Icons.Default.DarkMode else Icons.Default.LightMode,
                        contentDescription = null,
                        tint = colorScheme.primary
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text("Dark Mode (OLED Pure Black)", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
                        Text(if (darkTheme) "Active: OLED Pure Black Theme (#030712)" else "Active: Light Liquid Glass Theme (#F8FAFC)", fontSize = 11.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))
                    }
                }
                Switch(
                    checked = darkTheme,
                    onCheckedChange = onDarkThemeToggle,
                    colors = SwitchDefaults.colors(checkedThumbColor = colorScheme.secondary, checkedTrackColor = colorScheme.primary)
                )
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Multi-Currency Selector Tile
        Surface(
            shape = RoundedCornerShape(14.dp),
            color = colorScheme.surface,
            border = androidx.compose.foundation.BorderStroke(1.dp, colorScheme.outlineVariant),
            modifier = Modifier.fillMaxWidth()
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.CurrencyExchange, contentDescription = null, tint = colorScheme.secondary)
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text("Display Currency", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
                        Text("Converts prices in real-time", fontSize = 11.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))
                    }
                }

                var expanded by remember { mutableStateOf(false) }
                Box {
                    Button(
                        onClick = { expanded = true },
                        colors = ButtonDefaults.buttonColors(containerColor = colorScheme.secondary.copy(alpha = 0.15f)),
                        shape = RoundedCornerShape(10.dp),
                        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
                    ) {
                        Text("${currency.name.uppercase()} (${currency.symbol})", fontWeight = FontWeight.Bold, color = colorScheme.secondary)
                    }

                    DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
                        AppCurrency.values().forEach { curr ->
                            DropdownMenuItem(
                                text = { Text("${curr.name.uppercase()} (${curr.symbol})") },
                                onClick = {
                                    onCurrencyChange(curr)
                                    expanded = false
                                }
                            )
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Biometrics Security Switch Tile
        Surface(
            shape = RoundedCornerShape(14.dp),
            color = colorScheme.surface,
            border = androidx.compose.foundation.BorderStroke(1.dp, colorScheme.outlineVariant),
            modifier = Modifier.fillMaxWidth()
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.Fingerprint, contentDescription = null, tint = colorScheme.secondary)
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text("Fingerprint / Face ID Lock", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
                        Text(if (biometricsEnabled) "Hardware Security Lock Active" else "Tap to test hardware biometric lock", fontSize = 11.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))
                    }
                }
                Switch(
                    checked = biometricsEnabled,
                    onCheckedChange = onBiometricsToggle,
                    colors = SwitchDefaults.colors(checkedThumbColor = colorScheme.secondary, checkedTrackColor = colorScheme.primary)
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Check & Install Updates Button
        Button(
            onClick = onCheckUpdateClick,
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(containerColor = colorScheme.secondary),
            modifier = Modifier.fillMaxWidth().height(50.dp)
        ) {
            Icon(Icons.Default.SystemUpdate, contentDescription = null, tint = Color.White)
            Spacer(modifier = Modifier.width(8.dp))
            Text("⚡ Check & Install App Updates", fontWeight = FontWeight.ExtraBold, fontSize = 15.sp, color = Color.White)
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Official Discord Button
        Button(
            onClick = onDiscordClick,
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(containerColor = colorScheme.primary),
            modifier = Modifier.fillMaxWidth().height(48.dp)
        ) {
            Icon(Icons.Default.Chat, contentDescription = null, tint = Color.White)
            Spacer(modifier = Modifier.width(8.dp))
            Text("Join Official RenCloud Discord", fontWeight = FontWeight.Bold, color = Color.White)
        }

        Spacer(modifier = Modifier.height(24.dp))
        Text("RenCloud Cloud Services © 2026", fontSize = 10.sp, color = colorScheme.onSurface.copy(alpha = 0.4f))
    }
}
