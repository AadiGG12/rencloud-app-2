package com.rencloud.app.data

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

    val plans = listOf(
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
        RenCloudPlan("mc_e_1", "Enterprise Dirt", "mc_enterprise", "Minecraft Enterprise", "2 GB", "10 GB NVMe", "1 vCore (100%)", 99, tierType = "Enterprise", databases = 1, backups = 1),
        RenCloudPlan("mc_e_2", "Enterprise Stone", "mc_enterprise", "Minecraft Enterprise", "4 GB", "25 GB NVMe", "2 vCores (200%)", 199, tierType = "Enterprise", databases = 1, backups = 2),
        RenCloudPlan("mc_e_3", "Enterprise Iron", "mc_enterprise", "Minecraft Enterprise", "8 GB", "40 GB NVMe", "4 vCores (400%)", 399, isPopular = true, tierType = "Enterprise", databases = 2, backups = 3),
        RenCloudPlan("mc_e_4", "Enterprise Coal", "mc_enterprise", "Minecraft Enterprise", "12 GB", "60 GB NVMe", "5 vCores (500%)", 599, tierType = "Enterprise", databases = 3, backups = 4),
        RenCloudPlan("mc_e_5", "Enterprise Redstone", "mc_enterprise", "Minecraft Enterprise", "16 GB", "120 GB NVMe", "7 vCores (700%)", 799, tierType = "Enterprise", databases = 4, backups = 5),
        RenCloudPlan("mc_e_6", "Enterprise Diamond", "mc_enterprise", "Minecraft Enterprise", "24 GB", "150 GB NVMe", "9 vCores (900%)", 1199, tierType = "Enterprise", databases = 5, backups = 6),
        RenCloudPlan("mc_e_7", "Enterprise Gold", "mc_enterprise", "Minecraft Enterprise", "32 GB", "240 GB NVMe", "12 vCores (1200%)", 1599, tierType = "Enterprise", databases = 6, backups = 7),

        // 4. CLOUD VPS — INTEL PLATINUM
        RenCloudPlan("vps_i_1", "Platinum 8", "vps_intel", "VPS — Intel Platinum", "8 GB DDR4", "50 GB NVMe", "2 vCores", 350),
        RenCloudPlan("vps_i_2", "Platinum 16", "vps_intel", "VPS — Intel Platinum", "16 GB DDR4", "80 GB NVMe", "4 vCores", 850, isPopular = true),
        RenCloudPlan("vps_i_3", "Platinum 32", "vps_intel", "VPS — Intel Platinum", "32 GB DDR4", "120 GB NVMe", "8 vCores", 1450),
        RenCloudPlan("vps_i_4", "Platinum 48", "vps_intel", "VPS — Intel Platinum", "48 GB DDR4", "150 GB NVMe", "10 vCores", 1950),
        RenCloudPlan("vps_i_5", "Platinum 64", "vps_intel", "VPS — Intel Platinum", "64 GB DDR4", "200 GB NVMe", "12 vCores", 2450),

        // 5. CLOUD VPS — AMD EPYC MILAN
        RenCloudPlan("vps_e_1", "Milan 16", "vps_epyc", "VPS — AMD EPYC Milan", "16 GB DDR4", "80 GB NVMe", "4 vCores", 1100),
        RenCloudPlan("vps_e_2", "Milan 32", "vps_epyc", "VPS — AMD EPYC Milan", "32 GB DDR4", "120 GB NVMe", "8 vCores", 1800, isPopular = true),
        RenCloudPlan("vps_e_3", "Milan 48", "vps_epyc", "VPS — AMD EPYC Milan", "48 GB DDR4", "150 GB NVMe", "10 vCores", 2300),
        RenCloudPlan("vps_e_4", "Milan 64", "vps_epyc", "VPS — AMD EPYC Milan", "64 GB DDR4", "200 GB NVMe", "12 vCores", 2600),
        RenCloudPlan("vps_e_5", "Milan 64 Pro", "vps_epyc", "VPS — AMD EPYC Milan", "64 GB DDR4", "200 GB NVMe", "16 vCores", 3100),

        // 6. CLOUD VPS — AMD RYZEN 7950X
        RenCloudPlan("vps_r_1", "Ryzen 4", "vps_ryzen", "VPS — AMD Ryzen 7950X", "4 GB DDR5", "50 GB NVMe", "1 vCore", 649),
        RenCloudPlan("vps_r_2", "Ryzen 8", "vps_ryzen", "VPS — AMD Ryzen 7950X", "8 GB DDR4", "80 GB NVMe", "2 vCores", 1149),
        RenCloudPlan("vps_r_3", "Ryzen 16", "vps_ryzen", "VPS — AMD Ryzen 7950X", "16 GB DDR4", "150 GB NVMe", "4 vCores", 1849, isPopular = true),
        RenCloudPlan("vps_r_4", "Ryzen 24", "vps_ryzen", "VPS — AMD Ryzen 7950X", "24 GB DDR4", "180 GB NVMe", "5 vCores", 2549),
        RenCloudPlan("vps_r_5", "Ryzen 32", "vps_ryzen", "VPS — AMD Ryzen 7950X", "32 GB DDR4", "200 GB NVMe", "6 vCores", 3449),
        RenCloudPlan("vps_r_6", "Ryzen 48", "vps_ryzen", "VPS — AMD Ryzen 7950X", "48 GB DDR4", "250 GB NVMe", "8 vCores", 4749),
        RenCloudPlan("vps_r_7", "Ryzen 64", "vps_ryzen", "VPS — AMD Ryzen 7950X", "64 GB DDR4", "300 GB NVMe", "10 vCores", 6149),

        // 7. HYTALE HOSTING
        RenCloudPlan("hytale_1", "Hytale Starter", "hytale", "Hytale Hosting", "4 GB DDR4", "20 GB NVMe", "200% (2 Cores)", 60, tierType = "Budget"),
        RenCloudPlan("hytale_2", "Hytale Regular", "hytale", "Hytale Hosting", "8 GB DDR4", "40 GB NVMe", "400% (4 Cores)", 120, tierType = "Budget"),
        RenCloudPlan("hytale_3", "Hytale Pro", "hytale", "Hytale Hosting", "8 GB DDR5", "40 GB NVMe", "400% (4 Cores)", 200, isPopular = true, tierType = "Premium"),
        RenCloudPlan("hytale_4", "Hytale Extreme", "hytale", "Hytale Hosting", "16 GB DDR5", "80 GB NVMe", "800% (8 Cores)", 400, tierType = "Premium"),
        RenCloudPlan("hytale_5", "Hytale Dedicated", "hytale", "Hytale Hosting", "32 GB DDR5", "120 GB NVMe", "1200% (12 Cores)", 800, tierType = "Enterprise"),

        // 8. ARK: SURVIVAL ASCENDED
        RenCloudPlan("ark_1", "ARK Explorer", "ark", "ARK: Survival Ascended", "8 GB DDR4", "50 GB NVMe", "300% (3 Cores)", 100, tierType = "Budget"),
        RenCloudPlan("ark_2", "ARK Survival", "ark", "ARK: Survival Ascended", "16 GB DDR4", "100 GB NVMe", "600% (6 Cores)", 300, isPopular = true, tierType = "Premium"),
        RenCloudPlan("ark_3", "ARK Ascended", "ark", "ARK: Survival Ascended", "32 GB DDR5", "200 GB NVMe", "1000% (10 Cores)", 600, tierType = "Enterprise"),

        // 9. WEB HOSTING
        RenCloudPlan("web_1", "Starter Web", "web", "Web Hosting", "1 GB", "10 GB NVMe SSD", "1 Core", 49),
        RenCloudPlan("web_2", "Basic Web", "web", "Web Hosting", "2 GB", "25 GB NVMe SSD", "2 Cores", 99),
        RenCloudPlan("web_3", "Premium Web", "web", "Web Hosting", "4 GB", "50 GB NVMe SSD", "4 Cores", 199, isPopular = true),
        RenCloudPlan("web_4", "Business Web", "web", "Web Hosting", "8 GB", "100 GB NVMe SSD", "6 Cores", 399),
        RenCloudPlan("web_5", "Enterprise Web", "web", "Web Hosting", "16 GB", "200 GB NVMe SSD", "8 Cores", 799),

        // 10. DISCORD BOT HOSTING
        RenCloudPlan("bot_1", "Starter Bot", "bot", "Discord Bot Hosting", "256 MB", "5 GB", "25% CPU", 20),
        RenCloudPlan("bot_2", "Basic Bot", "bot", "Discord Bot Hosting", "512 MB", "10 GB", "50% CPU", 40),
        RenCloudPlan("bot_3", "Advanced Bot", "bot", "Discord Bot Hosting", "1 GB", "20 GB", "100% CPU", 80, isPopular = true),
        RenCloudPlan("bot_4", "Pro Bot", "bot", "Discord Bot Hosting", "2 GB", "30 GB", "200% CPU", 160),
        RenCloudPlan("bot_5", "Enterprise Bot", "bot", "Discord Bot Hosting", "4 GB", "50 GB", "400% CPU", 320),

        // 11. VIP MEMBERSHIPS
        RenCloudPlan("vip_1", "Cloud Membership", "vip", "VIP Memberships", "8 GB Premium", "VIP Discord Role", "Priority CPU", 149, extraInfo = "8 GB Premium Allocation + VIP Discord Role"),
        RenCloudPlan("vip_2", "Storm Membership", "vip", "VIP Memberships", "16 GB Premium", "Free Setup Included", "Dedicated Node", 299, isPopular = true, extraInfo = "16 GB Premium Allocation + Free Setup Services"),

        // 12. SETUP SERVICES
        RenCloudPlan("setup_1", "Custom Plugins Setup", "setup", "Setup Services", "N/A", "Config Service", "Expert Staff", 1220, isOneTime = true, extraInfo = "Tailored plugin setup & custom config"),
        RenCloudPlan("setup_2", "Server Setups", "setup", "Setup Services", "N/A", "Full Tuning", "Full Node Setup", 1200, isOneTime = true, extraInfo = "Complete end-to-end server setup & optimization")
    )
}
