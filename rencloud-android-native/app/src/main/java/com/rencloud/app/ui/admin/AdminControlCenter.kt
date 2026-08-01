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
import androidx.compose.material.icons.automirrored.rounded.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.layout.ContentScale
import androidx.compose.foundation.Image
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rencloud.app.R
import com.rencloud.app.data.model.PanelUserAttributes
import com.rencloud.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdminControlCenter(
    adminViewModel: AdminViewModel,
    onNavigateBack: () -> Unit
) {
    val state by adminViewModel.uiState.collectAsState()
    val infiniteTransition = rememberInfiniteTransition(label = "admin")
    val logoScale by infiniteTransition.animateFloat(
        initialValue = 0.95f,
        targetValue = 1.05f,
        animationSpec = infiniteRepeatable(tween(2000), RepeatMode.Reverse),
        label = "logoPulse"
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(32.dp)
                                .scale(logoScale)
                                .clip(CircleShape)
                                .background(
                                    Brush.radialGradient(
                                        listOf(RenCloudGold.copy(alpha = 0.3f), RenCloudNavy)
                                    )
                                ),
                            contentAlignment = Alignment.Center
                        ) {
                            Image(
                                painter = painterResource(id = R.drawable.rencloud_logo),
                                contentDescription = null,
                                modifier = Modifier.size(24.dp)
                            )
                        }
                        Column {
                            Text(
                                "Admin Control",
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Black,
                                color = Color.White
                            )
                            Text(
                                "RenCloud Panel",
                                fontSize = 9.sp,
                                color = RenCloudGold,
                                letterSpacing = 1.sp
                            )
                        }
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Rounded.ArrowBack,
                            contentDescription = "Back",
                            tint = Color.White
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = RenCloudNavy)
            )
        },
        containerColor = RenCloudNavy
    ) { innerPadding ->

        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentPadding = PaddingValues(bottom = 24.dp)
        ) {
            // ─── Hero banner ──────────────────────────────────────────────────
            item {
                AdminHeroBanner(infiniteTransition)
                Spacer(Modifier.height(8.dp))
            }

            // ─── Metric Cards ─────────────────────────────────────────────────
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
                        color = RenCloudCyan,
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

            // ─── Search Bar ───────────────────────────────────────────────────
            item {
                OutlinedTextField(
                    value = state.searchQuery,
                    onValueChange = { adminViewModel.setSearchQuery(it) },
                    placeholder = {
                        Text(
                            "Search users by name or email...",
                            color = TextSecondaryDark,
                            fontSize = 13.sp
                        )
                    },
                    leadingIcon = {
                        Icon(Icons.Default.Search, contentDescription = null, tint = RenCloudCyan.copy(0.7f))
                    },
                    trailingIcon = {
                        if (state.searchQuery.isNotEmpty()) {
                            IconButton(onClick = { adminViewModel.setSearchQuery("") }) {
                                Icon(Icons.Default.Clear, contentDescription = null, tint = TextSecondaryDark)
                            }
                        }
                    },
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = RenCloudGold,
                        unfocusedBorderColor = RenCloudCardBorder,
                        focusedContainerColor = RenCloudCardDark,
                        unfocusedContainerColor = RenCloudCardDark,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        cursorColor = RenCloudGold
                    ),
                    shape = RoundedCornerShape(16.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp)
                )
                Spacer(Modifier.height(16.dp))
            }

            // ─── Section header ────────────────────────────────────────────────
            item {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp)
                ) {
                    Icon(
                        Icons.Default.Group,
                        contentDescription = null,
                        tint = RenCloudGold,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(Modifier.width(8.dp))
                    Text(
                        "Panel Users",
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Spacer(Modifier.weight(1f))
                    Surface(
                        color = RenCloudGold.copy(alpha = 0.12f),
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Text(
                            text = "${state.filteredUsers.size} found",
                            fontSize = 10.sp,
                            color = RenCloudGold,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                        )
                    }
                }
                Spacer(Modifier.height(8.dp))
            }

            // ─── Loading state ────────────────────────────────────────────────
            if (state.isLoading) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(40.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(
                            color = RenCloudGold,
                            modifier = Modifier.size(40.dp)
                        )
                    }
                }
            }

            // ─── Error state ──────────────────────────────────────────────────
            if (state.errorMessage != null) {
                item {
                    Surface(
                        color = RenCloudRed.copy(alpha = 0.1f),
                        shape = RoundedCornerShape(12.dp),
                        border = BorderStroke(1.dp, RenCloudRed.copy(alpha = 0.3f)),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp)
                    ) {
                        Row(
                            modifier = Modifier.padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            Icon(Icons.Default.Warning, null, tint = RenCloudRed)
                            Text(
                                text = state.errorMessage ?: "Unknown error occurred",
                                color = RenCloudRed,
                                fontSize = 13.sp
                            )
                        }
                    }
                }
            }

            // ─── User list ────────────────────────────────────────────────────
            items(state.filteredUsers) { user ->
                AdminUserCard(
                    user = user,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp)
                )
            }

            if (!state.isLoading && state.filteredUsers.isEmpty() && state.users.isNotEmpty()) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(40.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Icon(
                                Icons.Default.PersonSearch,
                                null,
                                tint = TextMutedDark,
                                modifier = Modifier.size(48.dp)
                            )
                            Text("No users match your search", color = TextSecondaryDark, fontSize = 14.sp)
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun AdminHeroBanner(infiniteTransition: InfiniteTransition) {
    val shimmer by infiniteTransition.animateFloat(
        initialValue = 0f, targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(4000, easing = LinearEasing)),
        label = "adminShimmer"
    )

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(120.dp)
            .padding(16.dp)
            .clip(RoundedCornerShape(20.dp))
            .background(
                Brush.linearGradient(
                    colors = listOf(
                        Color(0xFF1A1500),
                        Color(0xFF2C1F00),
                        Color(0xFF1A1500)
                    )
                )
            )
            .border(
                BorderStroke(
                    1.dp,
                    Brush.sweepGradient(
                        listOf(
                            RenCloudGold.copy(alpha = shimmer * 0.8f + 0.2f),
                            RenCloudGold.copy(alpha = 0.3f),
                            RenCloudGold.copy(alpha = (1f - shimmer) * 0.8f + 0.2f)
                        )
                    )
                ),
                RoundedCornerShape(20.dp)
            )
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            drawCircle(
                Brush.radialGradient(
                    listOf(RenCloudGold.copy(alpha = 0.2f), Color.Transparent),
                    radius = 100f
                ),
                radius = 100f,
                center = Offset(size.width * 0.85f, size.height * 0.3f)
            )
        }

        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Icon(
                        Icons.Default.Security,
                        null,
                        tint = RenCloudGold,
                        modifier = Modifier.size(14.dp)
                    )
                    Text("SUPER ADMIN", fontSize = 9.sp, color = RenCloudGold, letterSpacing = 2.sp, fontWeight = FontWeight.Bold)
                }
                Text(
                    "Control Center",
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Black,
                    color = Color.White
                )
                Text(
                    "panel.rencloud.online",
                    fontSize = 10.sp,
                    color = RenCloudGold.copy(alpha = 0.7f)
                )
            }

            Image(
                painter = painterResource(id = R.drawable.rencloud_logo),
                contentDescription = null,
                modifier = Modifier.size(56.dp)
            )
        }
    }
}

@Composable
private fun AdminMetricCard(
    title: String,
    value: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    color: Color,
    modifier: Modifier = Modifier
) {
    Surface(
        color = color.copy(alpha = 0.07f),
        shape = RoundedCornerShape(16.dp),
        border = BorderStroke(1.dp, color.copy(alpha = 0.2f)),
        modifier = modifier
    ) {
        Column(
            modifier = Modifier.padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Icon(icon, null, tint = color, modifier = Modifier.size(20.dp))
            Text(
                text = value,
                fontSize = 20.sp,
                fontWeight = FontWeight.Black,
                color = color
            )
            Text(
                text = title,
                fontSize = 9.sp,
                color = TextSecondaryDark,
                textAlign = TextAlign.Center,
                fontWeight = FontWeight.Medium
            )
        }
    }
}

@Composable
private fun AdminUserCard(
    user: PanelUserAttributes,
    modifier: Modifier = Modifier
) {
    Surface(
        color = RenCloudCardDark,
        shape = RoundedCornerShape(14.dp),
        border = BorderStroke(
            1.dp,
            if (user.rootAdmin) RenCloudGold.copy(alpha = 0.3f) else RenCloudCardBorder
        ),
        modifier = modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Avatar
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(
                        Brush.linearGradient(
                            listOf(
                                if (user.rootAdmin) RenCloudGold.copy(0.3f) else RenCloudPurple.copy(0.3f),
                                RenCloudCardDark
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
                    color = if (user.rootAdmin) RenCloudGold else RenCloudCyan
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

            // Status indicator
            Box(
                modifier = Modifier
                    .size(8.dp)
                    .clip(CircleShape)
                    .background(RenCloudGreen)
            )
        }
    }
}
