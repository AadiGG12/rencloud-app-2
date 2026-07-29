package com.rencloud.app.data

import androidx.compose.runtime.mutableStateListOf

object CatalogData {
    val categories = listOf(
        "all" to "All Services (55)",
        "mc_budget" to "Minecraft Budget (DDR4)",
        "mc_premium" to "Minecraft Premium (DDR5)",
        "mc_enterprise" to "Minecraft Enterprise",
        "vps_intel" to "VPS — Intel Platinum",
        "vps_epyc" to "VPS — AMD EPYC Milan",
        "vps_ryzen" to "VPS — AMD Ryzen 7950X",
        "hytale" to "Hytale Hosting",
        "ark" to "ARK: Ascended",
        "web" to "Web Hosting",
        "bot" to "Discord Bot Hosting",
        "vip" to "VIP Memberships",
        "setup" to "Setup Services"
    )

    val plans = mutableStateListOf(
        // 1. MINECRAFT BUDGET (DDR4)
        RenCloudPlan("mc_b_1", "Dirt", "mc_budget", "Minecraft Budget (DDR4)", "2 GB", "10 GB NVMe", "100% (1 Core)", 20, tierType = "Budget"),
        RenCloudPlan("mc_b_2", "Stone", "mc_budget", "Minecraft Budget (DDR4)", "4 GB", "20 GB NVMe", "200% (2 Cores)", 40, tierType = "Budget"),
        RenCloudPlan("mc_b_3", "Iron", "mc_budget", "Minecraft Budget (DDR4)", "8 GB", "30 GB NVMe", "300% (3 Cores)", 80, isPopular = true, tierType = "Budget"),
        RenCloudPlan("mc_b_4", "Redstone", "mc_budget", "Minecraft Budget (DDR4)", "16 GB", "40 GB NVMe", "400% (4 Cores)", 160, tierType = "Budget"),
        RenCloudPlan("mc_b_5", "Gold", "mc_budget", "Minecraft Budget (DDR4)", "32 GB", "40 GB NVMe", "450% (4.5 Cores)", 320, tierType = "Budget"),
        RenCloudPlan("mc_b_6", "Emerald", "mc_budget", "Minecraft Budget (DDR4)", "48 GB", "50 GB NVMe", "500% (5 Cores)", 480, tierType = "Budget"),
        RenCloudPlan("mc_b_7", "Netherite", "mc_budget", "Minecraft Budget (DDR4)", "64 GB", "60 GB NVMe", "700% (7 Cores)", 640, tierType = "Budget"),

        // 2. MINECRAFT PREMIUM (DDR5)
        RenCloudPlan("mc_p_1", "Premium Dirt", "mc_premium", "Minecraft Premium (DDR5)", "2 GB", "10 GB NVMe", "100% (1 Core)", 40, tierType = "Premium"),
        RenCloudPlan("mc_p_2", "Premium Stone", "mc_premium", "Minecraft Premium (DDR5)", "4 GB", "20 GB NVMe", "200% (2 Cores)", 80, tierType = "Premium"),
        RenCloudPlan("mc_p_3", "Premium Iron", "mc_premium", "Minecraft Premium (DDR5)", "8 GB", "30 GB NVMe", "300% (3 Cores)", 160, isPopular = true, tierType = "Premium"),
        RenCloudPlan("mc_p_4", "Premium Redstone", "mc_premium", "Minecraft Premium (DDR5)", "16 GB", "40 GB NVMe", "400% (4 Cores)", 320, tierType = "Premium"),
        RenCloudPlan("mc_p_5", "Premium Gold", "mc_premium", "Minecraft Premium (DDR5)", "32 GB", "40 GB NVMe", "450% (4.5 Cores)", 640, tierType = "Premium"),
        RenCloudPlan("mc_p_6", "Premium Emerald", "mc_premium", "Minecraft Premium (DDR5)", "48 GB", "50 GB NVMe", "500% (5 Cores)", 960, tierType = "Premium"),
        RenCloudPlan("mc_p_7", "Premium Netherite", "mc_premium", "Minecraft Premium (DDR5)", "64 GB", "60 GB NVMe", "700% (7 Cores)", 1280, tierType = "Premium"),

        // 3. MINECRAFT ENTERPRISE
        RenCloudPlan("mc_e_1", "Enterprise Ryzen 9", "mc_enterprise", "Minecraft Enterprise", "32 GB DDR5", "100 GB NVMe", "Ryzen 9 7950X", 1499, tierType = "Enterprise"),
        RenCloudPlan("mc_e_2", "Enterprise i9-14900K", "mc_enterprise", "Minecraft Enterprise", "64 GB DDR5", "250 GB NVMe", "i9-14900K Dedicated", 2899, isPopular = true, tierType = "Enterprise"),

        // 4. VPS - INTEL PLATINUM
        RenCloudPlan("vps_i_1", "Intel Micro", "vps_intel", "VPS — Intel Platinum", "2 GB", "30 GB NVMe", "1 Core", 199, tierType = "VPS"),
        RenCloudPlan("vps_i_2", "Intel Starter", "vps_intel", "VPS — Intel Platinum", "4 GB", "60 GB NVMe", "2 Cores", 399, isPopular = true, tierType = "VPS"),
        RenCloudPlan("vps_i_3", "Intel Pro", "vps_intel", "VPS — Intel Platinum", "8 GB", "120 GB NVMe", "4 Cores", 799, tierType = "VPS"),
        RenCloudPlan("vps_i_4", "Intel Ultra", "vps_intel", "VPS — Intel Platinum", "16 GB", "240 GB NVMe", "8 Cores", 1499, tierType = "VPS"),

        // 5. VPS - AMD EPYC MILAN
        RenCloudPlan("vps_e_1", "EPYC Micro", "vps_epyc", "VPS — AMD EPYC Milan", "4 GB", "50 GB NVMe", "2 Cores", 299, tierType = "EPYC"),
        RenCloudPlan("vps_e_2", "EPYC Standard", "vps_epyc", "VPS — AMD EPYC Milan", "8 GB", "100 GB NVMe", "4 Cores", 599, isPopular = true, tierType = "EPYC"),
        RenCloudPlan("vps_e_3", "EPYC Enterprise", "vps_epyc", "VPS — AMD EPYC Milan", "16 GB", "200 GB NVMe", "8 Cores", 1199, tierType = "EPYC"),
        RenCloudPlan("vps_e_4", "EPYC Beast", "vps_epyc", "VPS — AMD EPYC Milan", "32 GB", "400 GB NVMe", "16 Cores", 2299, tierType = "EPYC"),

        // 6. VPS - AMD RYZEN 7950X
        RenCloudPlan("vps_r_1", "Ryzen Speedster", "vps_ryzen", "VPS — AMD Ryzen 7950X", "8 GB DDR5", "120 GB NVMe", "2 Dedicated Cores", 899, tierType = "Ryzen"),
        RenCloudPlan("vps_r_2", "Ryzen Extreme", "vps_ryzen", "VPS — AMD Ryzen 7950X", "16 GB DDR5", "250 GB NVMe", "4 Dedicated Cores", 1699, isPopular = true, tierType = "Ryzen"),
        RenCloudPlan("vps_r_3", "Ryzen Titan", "vps_ryzen", "VPS — AMD Ryzen 7950X", "32 GB DDR5", "500 GB NVMe", "8 Dedicated Cores", 3199, tierType = "Ryzen"),

        // 7. HYTALE HOSTING
        RenCloudPlan("hytale_1", "Orbis Starter", "hytale", "Hytale Hosting", "4 GB DDR5", "25 GB NVMe", "2 Cores", 120, tierType = "Hytale"),
        RenCloudPlan("hytale_2", "Kweebec Pro", "hytale", "Hytale Hosting", "8 GB DDR5", "50 GB NVMe", "4 Cores", 240, isPopular = true, tierType = "Hytale"),
        RenCloudPlan("hytale_3", "Trork Commander", "hytale", "Hytale Hosting", "16 GB DDR5", "80 GB NVMe", "6 Cores", 480, tierType = "Hytale"),

        // 8. ARK: ASCENDED
        RenCloudPlan("ark_1", "Island Survivor", "ark", "ARK: Ascended", "16 GB DDR5", "80 GB NVMe", "4 Cores", 499, tierType = "ARK"),
        RenCloudPlan("ark_2", "Scorched Earth Pro", "ark", "ARK: Ascended", "32 GB DDR5", "150 GB NVMe", "8 Cores", 999, isPopular = true, tierType = "ARK"),

        // 9. WEB HOSTING
        RenCloudPlan("web_1", "Starter Web", "web", "Web Hosting", "1 GB", "10 GB NVMe SSD", "1 Core", 49, databases = 2, backups = 3),
        RenCloudPlan("web_2", "Basic Web", "web", "Web Hosting", "2 GB", "25 GB NVMe SSD", "2 Cores", 99, databases = 5, backups = 7),
        RenCloudPlan("web_3", "Premium Web", "web", "Web Hosting", "4 GB", "50 GB NVMe SSD", "4 Cores", 199, isPopular = true, databases = 10, backups = 14),
        RenCloudPlan("web_4", "Enterprise Web", "web", "Web Hosting", "8 GB", "100 GB NVMe SSD", "8 Cores", 399, databases = 25, backups = 30),

        // 10. DISCORD BOT HOSTING
        RenCloudPlan("bot_1", "Starter Bot", "bot", "Discord Bot Hosting", "256 MB", "5 GB", "25% CPU", 20),
        RenCloudPlan("bot_2", "Basic Bot", "bot", "Discord Bot Hosting", "512 MB", "10 GB", "50% CPU", 40),
        RenCloudPlan("bot_3", "Advanced Bot", "bot", "Discord Bot Hosting", "1 GB", "20 GB", "100% CPU", 80, isPopular = true),
        RenCloudPlan("bot_4", "Pro Bot Cluster", "bot", "Discord Bot Hosting", "2 GB", "40 GB", "200% CPU", 160),

        // 11. VIP MEMBERSHIPS
        RenCloudPlan("vip_1", "Bronze VIP", "vip", "VIP Memberships", "N/A", "N/A", "Priority Queue", 99, isOneTime = true, extraInfo = "Special Discord Role & Priority Support"),
        RenCloudPlan("vip_2", "Silver VIP", "vip", "VIP Memberships", "N/A", "N/A", "High Priority", 199, isPopular = true, isOneTime = true, extraInfo = "Custom Discord Badge & 5% Discount Coupon"),
        RenCloudPlan("vip_3", "Gold VIP", "vip", "VIP Memberships", "N/A", "N/A", "VIP Dedicated Server Access", 499, isOneTime = true, extraInfo = "Personal Account Manager & 10% Discount Coupon"),

        // 12. SETUP SERVICES
        RenCloudPlan("setup_1", "Minecraft Plugin Setup", "setup", "Setup Services", "N/A", "N/A", "One-Time Service", 149, isOneTime = true, extraInfo = "Full configuration of up to 15 plugins"),
        RenCloudPlan("setup_2", "BungeeCord / Velocity Network Setup", "setup", "Setup Services", "N/A", "N/A", "One-Time Service", 299, isPopular = true, isOneTime = true, extraInfo = "Proxy network setup with auto reconnect & lobby routing"),
        RenCloudPlan("setup_3", "Custom Discord Bot Development", "setup", "Setup Services", "N/A", "N/A", "One-Time Service", 499, isOneTime = true, extraInfo = "Custom bot written in Node.js/Python for your server")
    )
}
