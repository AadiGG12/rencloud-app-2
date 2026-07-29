import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rencloud_plan.dart';
import '../core/constants/rencloud_catalog_data.dart';

// Billing Cycle Provider (Monthly / Annual)
final billingCycleProvider = StateProvider<BillingCycle>((ref) => BillingCycle.monthly);

// Selected Category Provider ('all' by default)
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered Plans Provider
final filteredPlansProvider = Provider<List<RenCloudPlan>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase().trim();

  return RenCloudCatalogData.plans.where((plan) {
    // Category Filter
    final matchesCategory = (category == 'all') || (plan.categoryId == category);
    
    // Search Query Filter
    final matchesSearch = searchQuery.isEmpty ||
        plan.name.toLowerCase().contains(searchQuery) ||
        plan.categoryName.toLowerCase().contains(searchQuery) ||
        plan.ram.toLowerCase().contains(searchQuery) ||
        plan.cpu.toLowerCase().contains(searchQuery) ||
        plan.nvmeStorage.toLowerCase().contains(searchQuery);

    return matchesCategory && matchesSearch;
  }).toList();
});

// Custom Estimator State
class EstimatorState {
  final int vcpuCores;
  final int ramGb;
  final int storageGb;

  EstimatorState({
    this.vcpuCores = 4,
    this.ramGb = 16,
    this.storageGb = 80,
  });

  int get estimatedPriceInr {
    // Base calculation formula aligned with VPS pricing
    return (vcpuCores * 150) + (ramGb * 35) + (storageGb * 5);
  }

  EstimatorState copyWith({
    int? vcpuCores,
    int? ramGb,
    int? storageGb,
  }) {
    return EstimatorState(
      vcpuCores: vcpuCores ?? this.vcpuCores,
      ramGb: ramGb ?? this.ramGb,
      storageGb: storageGb ?? this.storageGb,
    );
  }
}

class EstimatorNotifier extends StateNotifier<EstimatorState> {
  EstimatorNotifier() : super(EstimatorState());

  void updateVcpu(int vcpu) => state = state.copyWith(vcpuCores: vcpu);
  void updateRam(int ram) => state = state.copyWith(ramGb: ram);
  void updateStorage(int storage) => state = state.copyWith(storageGb: storage);
}

final estimatorProvider = StateNotifierProvider<EstimatorNotifier, EstimatorState>((ref) {
  return EstimatorNotifier();
});
