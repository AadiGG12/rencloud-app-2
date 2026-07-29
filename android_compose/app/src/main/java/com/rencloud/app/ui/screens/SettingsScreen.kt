package com.rencloud.app.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CurrencyExchange
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.Fingerprint
import androidx.compose.material.icons.filled.LightMode
import androidx.compose.material.icons.filled.SystemUpdate
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
        Image(
            painter = painterResource(id = R.drawable.logo),
            contentDescription = "RenCloud Logo",
            modifier = Modifier.size(60.dp)
        )
        Spacer(modifier = Modifier.height(10.dp))
        Text("App Preferences & Security", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
        Text("Configure currency, biometrics, theme & app updates", fontSize = 12.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))

        Spacer(modifier = Modifier.height(24.dp))

        // Dark Theme Tile
        Surface(
            shape = RoundedCornerShape(14.dp),
            color = colorScheme.surface,
            border = androidx.compose.foundation.BorderStroke(1.dp, colorScheme.outlineVariant),
            modifier = Modifier.fillMaxWidth()
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 10.dp)
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
                        Text("Switch between Light and OLED Pure Black theme", fontSize = 11.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))
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

        // Currency Selector Tile
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
                    Text("Currency Display", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
                }

                var expanded by remember { mutableStateOf(false) }
                Box {
                    TextButton(onClick = { expanded = true }) {
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

        // Biometrics Tile
        Surface(
            shape = RoundedCornerShape(14.dp),
            color = colorScheme.surface,
            border = androidx.compose.foundation.BorderStroke(1.dp, colorScheme.outlineVariant),
            modifier = Modifier.fillMaxWidth()
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 10.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.Fingerprint, contentDescription = null, tint = colorScheme.secondary)
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text("Fingerprint / Face ID Lock", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = colorScheme.onSurface)
                        Text("Require native biometric authentication to open app", fontSize = 11.sp, color = colorScheme.onSurface.copy(alpha = 0.6f))
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

        // Check for Updates Button
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

        // Discord Button
        Button(
            onClick = onDiscordClick,
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(containerColor = colorScheme.primary),
            modifier = Modifier.fillMaxWidth().height(48.dp)
        ) {
            Text("Join Official RenCloud Discord", fontWeight = FontWeight.Bold, color = Color.White)
        }
    }
}
