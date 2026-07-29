package com.rencloud.app.data

object CatalogData {
    val plans = listOf(
        // Minecraft Dirt
        RenCloudPlan("mc-dirt-1", "Dirt Seed", "mc-dirt", "Minecraft Dirt", "2 GB DDR4", "10 GB NVMe", "1 vCPU Core", 120, tierType = "Budget Tier"),
        RenCloudPlan("mc-dirt-2", "Dirt Sprout", "mc-dirt", "Minecraft Dirt", "4 GB DDR4", "20 GB NVMe", "2 vCPU Cores", 220, isPopular = true, tierType = "Budget Tier"),
        RenCloudPlan("mc-dirt-3", "Dirt Root", "mc-dirt", "Minecraft Dirt", "6 GB DDR4", "30 GB NVMe", "2 vCPU Cores", 330, tierType = "Budget Tier"),
        RenCloudPlan("mc-dirt-4", "Dirt Bloom", "mc-dirt", "Minecraft Dirt", "8 GB DDR4", "40 GB NVMe", "3 vCPU Cores", 420, tierType = "Budget Tier"),
        RenCloudPlan("mc-dirt-5", "Dirt Grove", "mc-dirt", "Minecraft Dirt", "12 GB DDR4", "60 GB NVMe", "4 vCPU Cores", 620, tierType = "Budget Tier"),

        // Minecraft Iron
        RenCloudPlan("mc-iron-1", "Iron Spark", "mc-iron", "Minecraft Iron", "4 GB DDR5", "25 GB NVMe", "2 vCPU Cores (3.8 GHz)", 350, tierType = "Standard Tier"),
        RenCloudPlan("mc-iron-2", "Iron Forge", "mc-iron", "Minecraft Iron", "8 GB DDR5", "50 GB NVMe", "3 vCPU Cores (4.0 GHz)", 680, isPopular = true, tierType = "Standard Tier"),
        RenCloudPlan("mc-iron-3", "Iron Armor", "mc-iron", "Minecraft Iron", "12 GB DDR5", "75 GB NVMe", "4 vCPU Cores (4.2 GHz)", 990, tierType = "Standard Tier"),
        RenCloudPlan("mc-iron-4", "Iron Fortress", "mc-iron", "Minecraft Iron", "16 GB DDR5", "100 GB NVMe", "4 vCPU Cores (4.4 GHz)", 1290, tierType = "Standard Tier"),
        RenCloudPlan("mc-iron-5", "Iron Titan", "mc-iron", "Minecraft Iron", "24 GB DDR5", "150 GB NVMe", "6 vCPU Cores (4.5 GHz)", 1890, tierType = "Standard Tier"),

        // Minecraft Platinum
        RenCloudPlan("mc-plat-1", "Platinum Core", "mc-platinum", "Minecraft Platinum", "8 GB DDR5 ECC", "60 GB NVMe Gen4", "Ryzen 9 7950X (5.7 GHz)", 1150, tierType = "Extreme Performance"),
        RenCloudPlan("mc-plat-2", "Platinum Pulse", "mc-platinum", "Minecraft Platinum", "16 GB DDR5 ECC", "120 GB NVMe Gen4", "Ryzen 9 7950X (5.7 GHz)", 2190, isPopular = true, tierType = "Extreme Performance"),
        RenCloudPlan("mc-plat-3", "Platinum Blaze", "mc-platinum", "Minecraft Platinum", "32 GB DDR5 ECC", "200 GB NVMe Gen4", "Ryzen 9 7950X (5.7 GHz)", 3990, tierType = "Extreme Performance"),
        RenCloudPlan("mc-plat-4", "Platinum Apex", "mc-platinum", "Minecraft Platinum", "64 GB DDR5 ECC", "400 GB NVMe Gen4", "Ryzen 9 7950X (5.7 GHz)", 7490, tierType = "Extreme Performance"),
        RenCloudPlan("mc-plat-5", "Platinum Zenith", "mc-platinum", "Minecraft Platinum", "128 GB DDR5 ECC", "800 GB NVMe Gen4", "Ryzen 9 7950X (5.7 GHz)", 13990, tierType = "Extreme Performance"),

        // Budget VPS
        RenCloudPlan("vps-bud-1", "VPS Nano", "vps-budget", "Budget VPS", "2 GB DDR4", "30 GB NVMe", "1 vCPU Core", 180, tierType = "KVM Virtualization"),
        RenCloudPlan("vps-bud-2", "VPS Micro", "vps-budget", "Budget VPS", "4 GB DDR4", "50 GB NVMe", "2 vCPU Cores", 340, isPopular = true, tierType = "KVM Virtualization"),
        RenCloudPlan("vps-bud-3", "VPS Starter", "vps-budget", "Budget VPS", "8 GB DDR4", "80 GB NVMe", "4 vCPU Cores", 650, tierType = "KVM Virtualization"),
        RenCloudPlan("vps-bud-4", "VPS Growth", "vps-budget", "Budget VPS", "16 GB DDR4", "150 GB NVMe", "6 vCPU Cores", 1190, tierType = "KVM Virtualization"),
        RenCloudPlan("vps-bud-5", "VPS Scale", "vps-budget", "Budget VPS", "32 GB DDR4", "300 GB NVMe", "8 vCPU Cores", 2290, tierType = "KVM Virtualization"),

        // Ryzen VPS
        RenCloudPlan("vps-ryz-1", "Ryzen Cloud 4G", "vps-ryzen", "Ryzen VPS", "4 GB DDR5", "60 GB NVMe Gen4", "2 vCPU Ryzen 9", 590, tierType = "5.7GHz Beast"),
        RenCloudPlan("vps-ryz-2", "Ryzen Cloud 8G", "vps-ryzen", "Ryzen VPS", "8 GB DDR5", "100 GB NVMe Gen4", "4 vCPU Ryzen 9", 1090, isPopular = true, tierType = "5.7GHz Beast"),
        RenCloudPlan("vps-ryz-3", "Ryzen Cloud 16G", "vps-ryzen", "Ryzen VPS", "16 GB DDR5", "180 GB NVMe Gen4", "6 vCPU Ryzen 9", 1990, tierType = "5.7GHz Beast"),
        RenCloudPlan("vps-ryz-4", "Ryzen Cloud 32G", "vps-ryzen", "Ryzen VPS", "32 GB DDR5", "320 GB NVMe Gen4", "8 vCPU Ryzen 9", 3790, tierType = "5.7GHz Beast"),
        RenCloudPlan("vps-ryz-5", "Ryzen Cloud 64G", "vps-ryzen", "Ryzen VPS", "64 GB DDR5", "600 GB NVMe Gen4", "12 vCPU Ryzen 9", 6990, tierType = "5.7GHz Beast"),

        // Dedicated Servers
        RenCloudPlan("dedi-1", "Bare Metal E-2288G", "vps-dedicated", "Dedicated Servers", "32 GB DDR4 ECC", "512 GB NVMe", "8 Cores / 16 Threads", 4990, tierType = "100% Dedicated"),
        RenCloudPlan("dedi-2", "Bare Metal Ryzen 5950X", "vps-dedicated", "Dedicated Servers", "64 GB DDR4 ECC", "1 TB NVMe Gen4", "16 Cores / 32 Threads", 8990, isPopular = true, tierType = "100% Dedicated"),
        RenCloudPlan("dedi-3", "Bare Metal Ryzen 7950X", "vps-dedicated", "Dedicated Servers", "128 GB DDR5 ECC", "2 TB NVMe Gen4", "16 Cores / 32 Threads", 14990, tierType = "100% Dedicated"),
        RenCloudPlan("dedi-4", "Bare Metal EPYC 7763", "vps-dedicated", "Dedicated Servers", "256 GB DDR4 ECC", "4 TB NVMe Gen4", "64 Cores / 128 Threads", 27990, tierType = "100% Dedicated"),
        RenCloudPlan("dedi-5", "Bare Metal Dual EPYC", "vps-dedicated", "Dedicated Servers", "512 GB DDR4 ECC", "8 TB NVMe RAID", "128 Cores / 256 Threads", 49990, tierType = "100% Dedicated"),

        // Web Hosting
        RenCloudPlan("web-1", "Web Launch", "web-hosting", "Web Hosting", "1 GB RAM", "10 GB NVMe", "Shared vCPU", 99, databases = 2, backups = 3),
        RenCloudPlan("web-2", "Web Growth", "web-hosting", "Web Hosting", "2 GB RAM", "25 GB NVMe", "1 vCPU Core", 199, isPopular = true, databases = 10, backups = 7),
        RenCloudPlan("web-3", "Web Business", "web-hosting", "Web Hosting", "4 GB RAM", "50 GB NVMe", "2 vCPU Cores", 399, databases = 25, backups = 14),
        RenCloudPlan("web-4", "Web Pro", "web-hosting", "Web Hosting", "8 GB RAM", "100 GB NVMe", "4 vCPU Cores", 799, databases = 50, backups = 30),
        RenCloudPlan("web-5", "Web Enterprise", "web-hosting", "Web Hosting", "16 GB RAM", "200 GB NVMe", "6 vCPU Cores", 1499, databases = 100, backups = 60),

        // Bot Hosting
        RenCloudPlan("bot-1", "Bot Spark", "bot-hosting", "Discord & Telegram Bot", "512 MB DDR4", "5 GB NVMe", "Shared CPU", 49, tierType = "NodeJS / Python / Java"),
        RenCloudPlan("bot-2", "Bot Runner", "bot-hosting", "Discord & Telegram Bot", "1 GB DDR4", "10 GB NVMe", "0.5 vCPU Core", 89, isPopular = true, tierType = "NodeJS / Python / Java"),
        RenCloudPlan("bot-3", "Bot Pro", "bot-hosting", "Discord & Telegram Bot", "2 GB DDR4", "20 GB NVMe", "1 vCPU Core", 169, tierType = "NodeJS / Python / Java"),
        RenCloudPlan("bot-4", "Bot Cluster", "bot-hosting", "Discord & Telegram Bot", "4 GB DDR4", "40 GB NVMe", "2 vCPU Cores", 319, tierType = "NodeJS / Python / Java"),
        RenCloudPlan("bot-5", "Bot Master", "bot-hosting", "Discord & Telegram Bot", "8 GB DDR4", "80 GB NVMe", "4 vCPU Cores", 599, tierType = "NodeJS / Python / Java"),

        // Hytale Hosting
        RenCloudPlan("hy-1", "Hytale Pioneer", "hytale", "Hytale Server", "6 GB DDR5", "40 GB NVMe", "2 vCPU Cores", 490, tierType = "Early Access Ready"),
        RenCloudPlan("hy-2", "Hytale Adventurer", "hytale", "Hytale Server", "12 GB DDR5", "80 GB NVMe", "4 vCPU Cores", 890, isPopular = true, tierType = "Early Access Ready"),
        RenCloudPlan("hy-3", "Hytale Sovereign", "hytale", "Hytale Server", "24 GB DDR5", "160 GB NVMe", "6 vCPU Cores", 1690, tierType = "Early Access Ready"),
        RenCloudPlan("hy-4", "Hytale Empire", "hytale", "Hytale Server", "48 GB DDR5", "320 GB NVMe", "8 vCPU Cores", 3190, tierType = "Early Access Ready"),
        RenCloudPlan("hy-5", "Hytale Mythic", "hytale", "Hytale Server", "96 GB DDR5", "640 GB NVMe", "12 vCPU Cores", 5990, tierType = "Early Access Ready"),

        // Setup & Managed Services
        RenCloudPlan("setup-1", "Pterodactyl Panel Setup", "setup-services", "Setup & Managed Services", "N/A", "N/A", "N/A", 499, isOneTime = true, extraInfo = "Complete panel installation + SSL"),
        RenCloudPlan("setup-2", "Minecraft Modpack Setup", "setup-services", "Setup & Managed Services", "N/A", "N/A", "N/A", 299, isOneTime = true, extraInfo = "CurseForge / Modrinth modpack config"),
        RenCloudPlan("setup-3", "VPS Security Hardening", "setup-services", "Setup & Managed Services", "N/A", "N/A", "N/A", 799, isOneTime = true, extraInfo = "UFW Firewall, Fail2ban & SSH Hardening"),
        RenCloudPlan("setup-4", "Discord Bot Deployment", "setup-services", "Setup & Managed Services", "N/A", "N/A", "N/A", 399, isOneTime = true, extraInfo = "24/7 PM2 / Docker Bot Setup"),
        RenCloudPlan("setup-5", "Full Network BungeeCord Setup", "setup-services", "Setup & Managed Services", "N/A", "N/A", "N/A", 1299, isOneTime = true, extraInfo = "Proxy + Hub + Sub-servers Linking")
    )

    val categories = listOf(
        "all" to "All 55 Plans",
        "mc-dirt" to "Minecraft Dirt",
        "mc-iron" to "Minecraft Iron",
        "mc-platinum" to "Minecraft Platinum",
        "vps-budget" to "Budget VPS",
        "vps-ryzen" to "Ryzen VPS",
        "vps-dedicated" to "Dedicated",
        "web-hosting" to "Web Hosting",
        "bot-hosting" to "Bot Hosting",
        "hytale" to "Hytale Hosting",
        "setup-services" to "Setup Services"
    )
}
