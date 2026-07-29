package com.rencloud.app.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.R
import com.rencloud.app.ui.components.GlassCard

@Composable
fun AuthScreen(
    onLoginSuccess: (String, String, String) -> Unit, // email, name, role
    onAdminLoginSuccess: () -> Unit
) {
    var isSignupTab by remember { mutableStateOf(false) }
    var name by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var isLoading by remember { mutableStateOf(false) }

    val colorScheme = MaterialTheme.colorScheme

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(colorScheme.background)
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Image(
            painter = painterResource(id = R.drawable.logo),
            contentDescription = "RenCloud Logo",
            modifier = Modifier.size(72.dp)
        )

        Spacer(modifier = Modifier.height(12.dp))
        Text(
            text = if (isSignupTab) "Create RenCloud Account" else "Welcome to RenCloud",
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = colorScheme.onSurface
        )
        Text(
            text = "Liquid Glass Authentication Console",
            fontSize = 12.sp,
            color = colorScheme.onSurface.copy(alpha = 0.6f)
        )

        Spacer(modifier = Modifier.height(24.dp))

        GlassCard(modifier = Modifier.fillMaxWidth()) {
            // Tab Selector
            Row(modifier = Modifier.fillMaxWidth()) {
                FilterChip(
                    selected = !isSignupTab,
                    onClick = { isSignupTab = false; errorMessage = null },
                    label = { Text("Sign In", fontWeight = FontWeight.Bold) },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = colorScheme.primary,
                        selectedLabelColor = Color.White,
                        containerColor = colorScheme.surface,
                        labelColor = colorScheme.onSurface
                    ),
                    modifier = Modifier.weight(1f)
                )
                Spacer(modifier = Modifier.width(8.dp))
                FilterChip(
                    selected = isSignupTab,
                    onClick = { isSignupTab = true; errorMessage = null },
                    label = { Text("Register", fontWeight = FontWeight.Bold) },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = colorScheme.secondary,
                        selectedLabelColor = Color.White,
                        containerColor = colorScheme.surface,
                        labelColor = colorScheme.onSurface
                    ),
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            if (isSignupTab) {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Full Name") },
                    leadingIcon = { Icon(Icons.Default.Person, contentDescription = null, tint = colorScheme.primary) },
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(modifier = Modifier.height(10.dp))
            }

            OutlinedTextField(
                value = email,
                onValueChange = { email = it },
                label = { Text("Email Address") },
                leadingIcon = { Icon(Icons.Default.Email, contentDescription = null, tint = colorScheme.primary) },
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(10.dp))

            OutlinedTextField(
                value = password,
                onValueChange = { password = it },
                label = { Text("Password") },
                visualTransformation = PasswordVisualTransformation(),
                leadingIcon = { Icon(Icons.Default.Lock, contentDescription = null, tint = colorScheme.primary) },
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.fillMaxWidth()
            )

            errorMessage?.let { err ->
                Spacer(modifier = Modifier.height(10.dp))
                Text(err, color = Color.Red, fontSize = 12.sp, fontWeight = FontWeight.Bold)
            }

            Spacer(modifier = Modifier.height(20.dp))

            Button(
                onClick = {
                    if (email.trim() == "admin@rencloud.com" && password.trim() == "admin123") {
                        onAdminLoginSuccess()
                    } else if (email.isNotBlank() && password.isNotBlank()) {
                        onLoginSuccess(email, if (isSignupTab) name else "RenCloud User", "user")
                    } else {
                        errorMessage = "Please enter email and password"
                    }
                },
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = if (isSignupTab) colorScheme.secondary else colorScheme.primary
                ),
                modifier = Modifier.fillMaxWidth().height(48.dp)
            ) {
                Text(
                    text = if (isSignupTab) "CREATE ACCOUNT" else "SIGN IN",
                    fontWeight = FontWeight.ExtraBold,
                    fontSize = 14.sp,
                    color = Color.White
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Demo Admin Login Hint
            TextButton(
                onClick = {
                    email = "admin@rencloud.com"
                    password = "admin123"
                    onAdminLoginSuccess()
                },
                modifier = Modifier.align(Alignment.CenterHorizontally)
            ) {
                Text("⚡ Demo Admin Login (admin@rencloud.com / admin123)", fontSize = 11.sp, color = colorScheme.secondary)
            }
        }
    }
}
