package com.rencloud.app.data.repository

import com.rencloud.app.data.model.RenCloudPlan
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CatalogRepository @Inject constructor() {

    fun getPlans(): List<RenCloudPlan> {
        return listOf(

            // ─── 1. MINECRAFT BUDGET (DDR4) ──────────────────────────────────────────
            RenCloudPlan("mc_b_dirt", "Dirt", "Minecraft Budget", 20, 0.25, "2 GB DDR4", "1 Core (100%)", "10 GB NVMe", "Unmetered", "Unlimited", false, "Budget Minecraft Hosting", "India"),
            RenCloudPlan("mc_b_stone", "Stone", "Minecraft Budget", 40, 0.50, "4 GB DDR4", "2 Cores (200%)", "20 GB NVMe", "Unmetered", "Unlimited", false, "Budget Minecraft Hosting", "India"),
            RenCloudPlan("mc_b_iron", "Iron", "Minecraft Budget", 80, 1.00, "8 GB DDR4", "3 Cores (300%)", "30 GB NVMe", "Unmetered", "Unlimited", true, "Popular Budget Choice", "India"),
            RenCloudPlan("mc_b_redstone", "Redstone", "Minecraft Budget", 160, 2.00, "16 GB DDR4", "4 Cores (400%)", "40 GB NVMe", "Unmetered", "Unlimited", false, "High Performance Budget", "India"),
            RenCloudPlan("mc_b_gold", "Gold", "Minecraft Budget", 320, 4.00, "32 GB DDR4", "4.5 Cores (450%)", "40 GB NVMe", "Unmetered", "Unlimited", false, "Massive Memory Budget", "India"),
            RenCloudPlan("mc_b_emerald", "Emerald", "Minecraft Budget", 480, 6.00, "48 GB DDR4", "5 Cores (500%)", "50 GB NVMe", "Unmetered", "Unlimited", false, "Pro Network Budget", "India"),
            RenCloudPlan("mc_b_netherite", "Netherite", "Minecraft Budget", 640, 8.00, "64 GB DDR4", "7 Cores (700%)", "60 GB NVMe", "Unmetered", "Unlimited", false, "Maximum Power Budget", "India"),

            // ─── 2. MINECRAFT PREMIUM (DDR5) ─────────────────────────────────────────
            RenCloudPlan("mc_p_dirt", "Premium Dirt", "Minecraft Premium", 40, 0.50, "2 GB DDR5", "1 Core (100%)", "10 GB NVMe", "Unmetered", "Unlimited", false, "DDR5 High-Speed Memory", "India / Singapore"),
            RenCloudPlan("mc_p_stone", "Premium Stone", "Minecraft Premium", 80, 1.00, "4 GB DDR5", "2 Cores (200%)", "20 GB NVMe", "Unmetered", "Unlimited", false, "DDR5 High-Speed Memory", "India / Singapore"),
            RenCloudPlan("mc_p_iron", "Premium Iron", "Minecraft Premium", 160, 2.00, "8 GB DDR5", "3 Cores (300%)", "30 GB NVMe", "Unmetered", "Unlimited", true, "Popular Premium Server", "India / Singapore"),
            RenCloudPlan("mc_p_redstone", "Premium Redstone", "Minecraft Premium", 320, 4.00, "16 GB DDR5", "4 Cores (400%)", "40 GB NVMe", "Unmetered", "Unlimited", false, "Fast Processing DDR5", "India / Singapore"),
            RenCloudPlan("mc_p_gold", "Premium Gold", "Minecraft Premium", 640, 8.00, "32 GB DDR5", "4.5 Cores (450%)", "40 GB NVMe", "Unmetered", "Unlimited", false, "High Tick-Rate DDR5", "India / Singapore"),
            RenCloudPlan("mc_p_emerald", "Premium Emerald", "Minecraft Premium", 960, 12.00, "48 GB DDR5", "5 Cores (500%)", "50 GB NVMe", "Unmetered", "Unlimited", false, "Ultra DDR5 Performance", "India / Singapore"),
            RenCloudPlan("mc_p_netherite", "Premium Netherite", "Minecraft Premium", 1280, 16.00, "64 GB DDR5", "7 Cores (700%)", "60 GB NVMe", "Unmetered", "Unlimited", false, "Ultimate DDR5 Server", "India / Singapore"),

            // ─── 3. MINECRAFT ENTERPRISE ─────────────────────────────────────────────
            RenCloudPlan("mc_e_dirt", "Enterprise Dirt", "Minecraft Enterprise", 99, 1.25, "2 GB", "1 vCore (100%)", "10 GB NVMe", "Unmetered", "1 DB | 1 Backup", false, "Dedicated Resources", "India / Singapore"),
            RenCloudPlan("mc_e_stone", "Enterprise Stone", "Minecraft Enterprise", 199, 2.50, "4 GB", "2 vCores (200%)", "25 GB NVMe", "Unmetered", "1 DB | 2 Backups", false, "Dedicated Resources", "India / Singapore"),
            RenCloudPlan("mc_e_iron", "Enterprise Iron", "Minecraft Enterprise", 399, 5.00, "8 GB", "4 vCores (400%)", "40 GB NVMe", "Unmetered", "2 DB | 3 Backups", true, "Popular Enterprise Choice", "India / Singapore"),
            RenCloudPlan("mc_e_coal", "Enterprise Coal", "Minecraft Enterprise", 599, 7.50, "12 GB", "5 vCores (500%)", "60 GB NVMe", "Unmetered", "3 DB | 4 Backups", false, "Large Community Host", "India / Singapore"),
            RenCloudPlan("mc_e_redstone", "Enterprise Redstone", "Minecraft Enterprise", 799, 10.00, "16 GB", "7 vCores (700%)", "120 GB NVMe", "Unmetered", "4 DB | 5 Backups", false, "Advanced Modpacks", "India / Singapore"),
            RenCloudPlan("mc_e_diamond", "Enterprise Diamond", "Minecraft Enterprise", 1199, 15.00, "24 GB", "9 vCores (900%)", "150 GB NVMe", "Unmetered", "5 DB | 6 Backups", false, "Heavy Modpack & Plugins", "India / Singapore"),
            RenCloudPlan("mc_e_gold", "Enterprise Gold", "Minecraft Enterprise", 1599, 20.00, "32 GB", "12 vCores (1200%)", "240 GB NVMe", "Unmetered", "6 DB | 7 Backups", false, "Network Proxy Cluster", "India / Singapore"),

            // ─── 4. CLOUD VPS — INTEL PLATINUM 8269-CY ──────────────────────────────
            RenCloudPlan("vps_intel_8", "Platinum 8", "VPS Intel", 350, 4.35, "8 GB DDR4", "2 vCores Intel", "50 GB NVMe", "Unmetered", "1 IPv4", false, "Intel Xeon Scalable", "India"),
            RenCloudPlan("vps_intel_16", "Platinum 16", "VPS Intel", 850, 10.50, "16 GB DDR4", "4 vCores Intel", "80 GB NVMe", "Unmetered", "1 IPv4", false, "Intel Xeon Scalable", "India"),
            RenCloudPlan("vps_intel_32", "Platinum 32", "VPS Intel", 1450, 18.00, "32 GB DDR4", "8 vCores Intel", "120 GB NVMe", "Unmetered", "1 IPv4", true, "Best Value Intel VPS", "India"),
            RenCloudPlan("vps_intel_48", "Platinum 48", "VPS Intel", 1950, 24.00, "48 GB DDR4", "10 vCores Intel", "150 GB NVMe", "Unmetered", "1 IPv4", false, "Heavy Workload Intel", "India"),
            RenCloudPlan("vps_intel_64", "Platinum 64", "VPS Intel", 2450, 30.00, "64 GB DDR4", "12 vCores Intel", "200 GB NVMe", "Unmetered", "1 IPv4", false, "High Density Compute", "India"),

            // ─── 5. CLOUD VPS — AMD EPYC MILAN ──────────────────────────────────────
            RenCloudPlan("vps_epyc_16", "Milan 16", "VPS AMD EPYC", 1100, 13.50, "16 GB DDR4", "4 vCores EPYC", "80 GB NVMe", "Unmetered", "1 IPv4", false, "AMD EPYC Enterprise", "India / Singapore"),
            RenCloudPlan("vps_epyc_32", "Milan 32", "VPS AMD EPYC", 1800, 22.00, "32 GB DDR4", "8 vCores EPYC", "120 GB NVMe", "Unmetered", "1 IPv4", true, "High Performance EPYC", "India / Singapore"),
            RenCloudPlan("vps_epyc_48", "Milan 48", "VPS AMD EPYC", 2300, 28.00, "48 GB DDR4", "10 vCores EPYC", "150 GB NVMe", "Unmetered", "1 IPv4", false, "Enterprise VPS Host", "India / Singapore"),
            RenCloudPlan("vps_epyc_64", "Milan 64", "VPS AMD EPYC", 2600, 32.00, "64 GB DDR4", "12 vCores EPYC", "200 GB NVMe", "Unmetered", "1 IPv4", false, "Maximum EPYC Cores", "India / Singapore"),
            RenCloudPlan("vps_epyc_64p", "Milan 64 Pro", "VPS AMD EPYC", 3100, 38.00, "64 GB DDR4", "16 vCores EPYC", "200 GB NVMe", "Unmetered", "1 IPv4", false, "Ultra-Core EPYC VPS", "India / Singapore"),

            // ─── 6. CLOUD VPS — AMD RYZEN 9 7950X ───────────────────────────────────
            RenCloudPlan("vps_ryzen_4", "Ryzen 4", "VPS AMD Ryzen", 649, 8.00, "4 GB DDR5", "1 vCore 5.7GHz", "50 GB NVMe", "Unmetered", "1 IPv4", false, "Ryzen 9 7950X DDR5", "India / Singapore"),
            RenCloudPlan("vps_ryzen_8", "Ryzen 8", "VPS AMD Ryzen", 1149, 14.00, "8 GB DDR4", "2 vCores 5.7GHz", "80 GB NVMe", "Unmetered", "1 IPv4", false, "Blazing Single-Core Speed", "India / Singapore"),
            RenCloudPlan("vps_ryzen_16", "Ryzen 16", "VPS AMD Ryzen", 1849, 23.00, "16 GB DDR4", "4 vCores 5.7GHz", "150 GB NVMe", "Unmetered", "1 IPv4", true, "Top Recommended Gaming VPS", "India / Singapore"),
            RenCloudPlan("vps_ryzen_24", "Ryzen 24", "VPS AMD Ryzen", 2549, 31.00, "24 GB DDR4", "5 vCores 5.7GHz", "180 GB NVMe", "Unmetered", "1 IPv4", false, "High Frequency Server", "India / Singapore"),
            RenCloudPlan("vps_ryzen_32", "Ryzen 32", "VPS AMD Ryzen", 3449, 42.00, "32 GB DDR4", "6 vCores 5.7GHz", "200 GB NVMe", "Unmetered", "1 IPv4", false, "Heavy Compute Ryzen", "India / Singapore"),
            RenCloudPlan("vps_ryzen_48", "Ryzen 48", "VPS AMD Ryzen", 4749, 58.00, "48 GB DDR4", "8 vCores 5.7GHz", "250 GB NVMe", "Unmetered", "1 IPv4", false, "Pro Workstation Cloud", "India / Singapore"),
            RenCloudPlan("vps_ryzen_64", "Ryzen 64", "VPS AMD Ryzen", 6149, 75.00, "64 GB DDR4", "10 vCores 5.7GHz", "300 GB NVMe", "Unmetered", "1 IPv4", false, "Ultimate Ryzen 9 Host", "India / Singapore"),

            // ─── 7. HYTALE HOSTING ───────────────────────────────────────────────────
            RenCloudPlan("hytale_start", "Hytale Starter", "Hytale Hosting", 60, 0.75, "4 GB DDR4", "2 Cores (200%)", "20 GB NVMe", "Unmetered", "Budget Tier", false, "Hytale Early Access Host", "India"),
            RenCloudPlan("hytale_reg", "Hytale Regular", "Hytale Hosting", 120, 1.50, "8 GB DDR4", "4 Cores (400%)", "40 GB NVMe", "Unmetered", "Budget Tier", false, "Community Hytale Server", "India"),
            RenCloudPlan("hytale_pro", "Hytale Pro", "Hytale Hosting", 200, 2.50, "8 GB DDR5", "4 Cores (400%)", "40 GB NVMe", "Unmetered", "Premium Tier", true, "Popular Hytale Server", "India / Singapore"),
            RenCloudPlan("hytale_ext", "Hytale Extreme", "Hytale Hosting", 400, 5.00, "16 GB DDR5", "8 Cores (800%)", "80 GB NVMe", "Unmetered", "Premium Tier", false, "Heavy Modded Hytale", "India / Singapore"),
            RenCloudPlan("hytale_dedi", "Hytale Dedicated", "Hytale Hosting", 800, 10.00, "32 GB DDR5", "12 Cores (1200%)", "120 GB NVMe", "Unmetered", "Enterprise Tier", false, "Dedicated Network Hytale", "India / Singapore"),

            // ─── 8. ARK: SURVIVAL ASCENDED ───────────────────────────────────────────
            RenCloudPlan("ark_explorer", "ARK Explorer", "ARK Ascended", 100, 1.25, "8 GB DDR4", "3 Cores (300%)", "50 GB NVMe", "Unmetered", "Budget Tier", false, "Unreal Engine 5 Host", "India"),
            RenCloudPlan("ark_survival", "ARK Survival", "ARK Ascended", 300, 3.75, "16 GB DDR4", "6 Cores (600%)", "100 GB NVMe", "Unmetered", "Premium Tier", true, "Popular Tribe Server", "India / Singapore"),
            RenCloudPlan("ark_ascended", "ARK Ascended", "ARK Ascended", 600, 7.50, "32 GB DDR5", "10 Cores (1000%)", "200 GB NVMe", "Unmetered", "Enterprise Tier", false, "Full Cluster Host", "India / Singapore"),

            // ─── 9. WEB HOSTING ──────────────────────────────────────────────────────
            RenCloudPlan("web_start", "Starter Web", "Web Hosting", 49, 0.60, "1 GB", "1 Core", "10 GB NVMe SSD", "Unmetered", "cPanel / DirectAdmin", false, "Personal Web Hosting", "India"),
            RenCloudPlan("web_basic", "Basic Web", "Web Hosting", 99, 1.25, "2 GB", "2 Cores", "25 GB NVMe SSD", "Unmetered", "cPanel / DirectAdmin", false, "Small Business Website", "India"),
            RenCloudPlan("web_prem", "Premium Web", "Web Hosting", 199, 2.50, "4 GB", "4 Cores", "50 GB NVMe SSD", "Unmetered", "cPanel / DirectAdmin", true, "Fast WordPress Host", "India / Singapore"),
            RenCloudPlan("web_biz", "Business Web", "Web Hosting", 399, 5.00, "8 GB", "6 Cores", "100 GB NVMe SSD", "Unmetered", "cPanel / DirectAdmin", false, "E-Commerce & Portals", "India / Singapore"),
            RenCloudPlan("web_ent", "Enterprise Web", "Web Hosting", 799, 10.00, "16 GB", "8 Cores", "200 GB NVMe SSD", "Unmetered", "cPanel / DirectAdmin", false, "High Traffic Websites", "India / Singapore"),

            // ─── 10. DISCORD BOT HOSTING ─────────────────────────────────────────────
            RenCloudPlan("bot_start", "Starter Bot", "Discord Bot", 20, 0.25, "256 MB", "25% CPU", "5 GB NVMe", "Unmetered", "24/7 Uptime", false, "Light JS / Python Bot", "India"),
            RenCloudPlan("bot_basic", "Basic Bot", "Discord Bot", 40, 0.50, "512 MB", "50% CPU", "10 GB NVMe", "Unmetered", "24/7 Uptime", false, "Standard Music Bot", "India"),
            RenCloudPlan("bot_adv", "Advanced Bot", "Discord Bot", 80, 1.00, "1 GB", "100% CPU", "20 GB NVMe", "Unmetered", "24/7 Uptime", true, "Multi-Server Discord Bot", "India"),
            RenCloudPlan("bot_pro", "Pro Bot", "Discord Bot", 160, 2.00, "2 GB", "200% CPU", "30 GB NVMe", "Unmetered", "24/7 Uptime", false, "Sharded Discord Bot", "India / Singapore"),
            RenCloudPlan("bot_ent", "Enterprise Bot", "Discord Bot", 320, 4.00, "4 GB", "400% CPU", "50 GB NVMe", "Unmetered", "24/7 Uptime", false, "Heavy Automated Bot", "India / Singapore"),

            // ─── 11. VIP MEMBERSHIPS ─────────────────────────────────────────────────
            RenCloudPlan("vip_cloud", "Cloud Membership", "VIP Memberships", 149, 1.85, "8 GB Premium", "Priority CPU", "Included Storage", "VIP Access", "Discord Role", true, "8GB Allocation + VIP Access", "Global"),
            RenCloudPlan("vip_storm", "Storm Membership", "VIP Memberships", 299, 3.75, "16 GB Premium", "Dedicated Priority", "Included Storage", "VIP Access", "Free Setup", false, "16GB Allocation + Free Setups", "Global"),

            // ─── 12. SETUP SERVICES (ONE-TIME) ────────────────────────────────────────
            RenCloudPlan("srv_plugins", "Custom Plugins", "Setup Services", 1220, 15.00, "N/A", "N/A", "N/A", "N/A", "One-Time Service", false, "Tailored plugin setup & config", "Remote"),
            RenCloudPlan("srv_setup", "Server Setups", "Setup Services", 1200, 14.80, "N/A", "N/A", "N/A", "N/A", "One-Time Service", false, "Complete server setup & optimization", "Remote")
        )
    }
}
