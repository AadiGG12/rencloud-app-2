package com.rencloud.app.ui.admin

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.painterResource
import androidx.compose.foundation.Image
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.R
import com.rencloud.app.data.model.PanelUserAttributes
import com.rencloud.app.ui.components.glass.*
import com.rencloud.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdminControlCenter(
    adminViewModel: AdminViewModel,
    onNavigateBack: () -> Unit = {}
) {
    val state by adminViewModel.uiState.collectAsState()
    val infiniteTransition = rememberInfiniteTransition(label = "admin")

    LiquidGlassBackground {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.AdminPanelSettings,
                                contentDescription = null,
                                tint = RenCloudGold
                            )
                            Text(
                                "Admin Control Center",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color.White
                            )
                        }
                    },
                    navigationIcon = {
                        IconButton(onClick = onNavigateBack) {
                            Icon(
                                imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                                contentDescription = "Back",
                                tint = Color.White
                            )
                        }
                    },
                    actions = {
                        IconButton(onClick = { adminViewModel.loadUsers(refresh = true) }) {
                            Icon(
                                imageVector = Icons.Default.Refresh,
                                contentDescription = "Refresh",
                                tint = ElectricCyan
                            )
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.Transparent)
                )
            },
            containerColor = Color.Transparent
        ) { innerPadding ->

            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding),
                contentPadding = PaddingValues(bottom = 24.dp)
            ) {
                item {
                    AdminHeroBanner(infiniteTransition)
                    Spacer(Modifier.height(8.dp))
                }

                item {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp),
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        AdminMetricCard(
                            title = "Total Users",
                            value = if (state.totalUsersCount > 0) state.totalUsersCount.toString()
                                   else state.users.size.toString(),
                            icon = Icons.Default.Group,
                            color = ElectricCyan,
                            modifier = Modifier.weight(1f)
                        )
                        AdminMetricCard(
                            title = "Admins",
                            value = state.users.count { it.rootAdmin }.toString(),
                            icon = Icons.Default.Security,
                            color = RenCloudGold,
                            modifier = Modifier.weight(1f)
                        )
                        AdminMetricCard(
                            title = "Panel",
                            value = if (state.isLoading) "..." else "Online",
                            icon = Icons.Default.CheckCircle,
                            color = RenCloudGreen,
                            modifier = Modifier.weight(1f)
                        )
                    }
                    Spacer(Modifier.height(16.dp))
                }

                item {
                    OutlinedTextField(
                        value = state.searchQuery,
                        onValueChange = { adminViewModel.setSearchQuery(it) },
                        placeholder = {
                            Text(
                                "Search users by name, email...",
                                color = TextSecondaryDark,
                                fontSize = 13.sp
                            )
                        },
                        leadingIcon = {
                            Icon(Icons.Default.Search, contentDescription = null, tint = ElectricCyan)
                        },
                        trailingIcon = {
                            if (state.searchQuery.isNotEmpty()) {
                                IconButton(onClick = { adminViewModel.setSearchQuery("") }) {
                                    Icon(Icons.Default.Clear, contentDescription = "Clear", tint = TextSecondaryDark)
                                }
                            }
                        },
                        singleLine = true,
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = ElectricCyan,
                            unfocusedBorderColor = MetallicBorderDark,
                            focusedContainerColor = MetallicCardDark.copy(alpha = 0.6f),
                            unfocusedContainerColor = MetallicCardDark.copy(alpha = 0.6f),
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        ),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp)
                    )
                    Spacer(Modifier.height(16.dp))
                }

                val filteredUsers = state.filteredUsers

                if (state.isLoading && filteredUsers.isEmpty()) {
                    item {
                        Column(
                            modifier = Modifier.fillMaxWidth().padding(40.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            GlassCircularProgress(size = 48.dp)
                            Spacer(Modifier.height(12.dp))
                            Text("Loading users from panel.rencloud.online...", color = TextSecondaryDark, fontSize = 12.sp)
                        }
                    }
                } else if (filteredUsers.isEmpty()) {
                    item {
                        Column(
                            modifier = Modifier.fillMaxWidth().padding(40.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Icon(Icons.Default.GroupOff, contentDescription = null, tint = TextMutedDark, modifier = Modifier.size(48.dp))
                            Spacer(Modifier.height(8.dp))
                            Text("No users found", color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                } else {
                    items(filteredUsers) { user ->
                        AdminUserCard(
                            user = user,
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 5.dp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun AdminHeroBanner(infiniteTransition: InfiniteTransition) {
    GlassCard(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        accentGlow = RenCloudGold,
        alpha = 0.85f
    ) {
        Row(
            modifier = Modifier.padding(18.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Surface(
                    color = RenCloudGold.copy(alpha = 0.15f),
                    shape = RoundedCornerShape(6.dp)
                ) {
                    Text(
                        "SUPER ADMIN DIRECTORY",
                        fontSize = 8.sp,
                        fontWeight = FontWeight.Bold,
                        color = RenCloudGold,
                        letterSpacing = 1.5.sp,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                    )
                }
                Spacer(Modifier.height(6.dp))
                Text(
                    "Pterodactyl Panel Users",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Black,
                    color = Color.White
                )
                Text(
                    "Synced live with panel.rencloud.online",
                    fontSize = 11.sp,
                    color = TextSecondaryDark
                )
            }

            Image(
                painter = painterResource(id = R.drawable.rencloud_logo),
                contentDescription = "RenCloud",
                modifier = Modifier.size(50.dp)
            )
        }
    }
}

@Composable
private fun AdminMetricCard(
    title: String,
    value: String,
    icon: ImageVector,
    color: Color,
    modifier: Modifier = Modifier
) {
    GlassCard(
        modifier = modifier,
        accentGlow = color,
        alpha = 0.8f
    ) {
        Column(
            modifier = Modifier.padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Icon(icon, contentDescription = null, tint = color, modifier = Modifier.size(20.dp))
            Text(value, fontSize = 18.sp, fontWeight = FontWeight.Black, color = Color.White)
            Text(title, fontSize = 9.sp, color = TextSecondaryDark, fontWeight = FontWeight.Medium)
        }
    }
}

@Composable
private fun AdminUserCard(
    user: PanelUserAttributes,
    modifier: Modifier = Modifier
) {
    GlassCard(
        modifier = modifier.fillMaxWidth(),
        accentGlow = if (user.rootAdmin) RenCloudGold else null,
        alpha = 0.8f
    ) {
        Row(
            modifier = Modifier.padding(14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(
                        Brush.linearGradient(
                            listOf(
                                if (user.rootAdmin) RenCloudGold.copy(0.3f) else MetallicPurple.copy(0.3f),
                                MetallicCardDark
                            )
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                val initial = (user.firstName?.firstOrNull() ?: user.username.firstOrNull() ?: '?').toString().uppercase()
                Text(
                    text = initial,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Black,
                    color = if (user.rootAdmin) RenCloudGold else ElectricCyan
                )
            }

            Column(modifier = Modifier.weight(1f)) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    val displayName = "${user.firstName ?: ""} ${user.lastName ?: ""}".trim()
                        .ifEmpty { user.username }
                    Text(
                        text = displayName,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    if (user.rootAdmin) {
                        Surface(
                            color = RenCloudGold.copy(alpha = 0.12f),
                            shape = RoundedCornerShape(4.dp)
                        ) {
                            Text(
                                "ADMIN",
                                fontSize = 7.sp,
                                color = RenCloudGold,
                                fontWeight = FontWeight.Black,
                                modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp),
                                letterSpacing = 0.5.sp
                            )
                        }
                    }
                }
                Text(
                    text = user.email,
                    fontSize = 11.sp,
                    color = TextSecondaryDark,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = "@${user.username}",
                    fontSize = 10.sp,
                    color = TextMutedDark
                )
            }

            Box(
                modifier = Modifier
                    .size(8.dp)
                    .clip(CircleShape)
                    .background(RenCloudGreen)
            )
        }
    }
}
