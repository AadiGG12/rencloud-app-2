package com.rencloud.app.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.R
import com.rencloud.app.data.AppCurrency
import com.rencloud.app.ui.components.GlassCard

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
        Text("Liquid Glass Console • v2.0.0", fontSize = 12.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))

        Spacer(modifier = Modifier.height(24.dp))

        // Dark Theme Liquid Glass Tile
        GlassCard(modifier = Modifier.fillMaxWidth()) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = if (darkTheme) Icons.Default.DarkMode else Icons.Default.LightMode,
                        contentDescription = null,
                        tint = colorScheme.primary
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text("Dark / Light Mode", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
                        Text(if (darkTheme) "OLED Pure Black (#030712)" else "Light Liquid Glass (#F8FAFC)", fontSize = 11.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))
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

        // Multi-Currency Liquid Glass Tile
        GlassCard(modifier = Modifier.fillMaxWidth()) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.fillMaxWidth()
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
                        colors = ButtonDefaults.buttonColors(containerColor = colorScheme.secondary.copy(alpha = 0.2f)),
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

        // Biometrics Security Liquid Glass Tile
        GlassCard(modifier = Modifier.fillMaxWidth()) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.fillMaxWidth()
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
    }
}
