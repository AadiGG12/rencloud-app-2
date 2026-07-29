enum BillingCycle { monthly, annual }

class RenCloudPlan {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final String ram;
  final String nvmeStorage;
  final String cpu;
  final int monthlyPriceInr;
  final bool isPopular;
  final String? tierType; // Budget, Premium, Enterprise
  final int? databases;
  final int? backups;
  final String? extraInfo;
  final bool isOneTime; // For setup services

  const RenCloudPlan({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.ram,
    required this.nvmeStorage,
    required this.cpu,
    required this.monthlyPriceInr,
    this.isPopular = false,
    this.tierType,
    this.databases,
    this.backups,
    this.extraInfo,
    this.isOneTime = false,
  });

  int getPriceForCycle(BillingCycle cycle) {
    if (isOneTime) return monthlyPriceInr;
    if (cycle == BillingCycle.annual) {
      // 15% discount for annual billing
      return (monthlyPriceInr * 0.85).round();
    }
    return monthlyPriceInr;
  }
}
