import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rencloud_plan.dart';
import '../core/constants/rencloud_catalog_data.dart';

// Currency Enum & Rates
enum AppCurrency { inr, usd, eur, aed }

class CurrencyHelper {
  static String getSymbol(AppCurrency currency) {
    switch (currency) {
      case AppCurrency.inr: return '₹';
      case AppCurrency.usd: return '\$';
      case AppCurrency.eur: return '€';
      case AppCurrency.aed: return 'Dh ';
    }
  }

  static String format(int priceInr, AppCurrency currency) {
    final symbol = getSymbol(currency);
    switch (currency) {
      case AppCurrency.inr:
        return '$symbol$priceInr';
      case AppCurrency.usd:
        return '$symbol${(priceInr * 0.012).toStringAsFixed(2)}';
      case AppCurrency.eur:
        return '$symbol${(priceInr * 0.011).toStringAsFixed(2)}';
      case AppCurrency.aed:
        return '$symbol${(priceInr * 0.044).toStringAsFixed(1)}';
    }
  }
}

// 23. Dark/Light Theme Provider (Default Theme Mode: DARK)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// 25. Multi-Currency Provider
final currencyProvider = StateProvider<AppCurrency>((ref) => AppCurrency.inr);

// 24. Biometric Lock State Provider
class BiometricState {
  final bool isEnabled;
  final bool isUnlocked;

  BiometricState({this.isEnabled = false, this.isUnlocked = true});

  BiometricState copyWith({bool? isEnabled, bool? isUnlocked}) {
    return BiometricState(
      isEnabled: isEnabled ?? this.isEnabled,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class BiometricNotifier extends StateNotifier<BiometricState> {
  BiometricNotifier() : super(BiometricState());

  void toggleBiometrics(bool enabled) {
    state = state.copyWith(isEnabled: enabled, isUnlocked: !enabled);
  }

  void unlock() {
    state = state.copyWith(isUnlocked: true);
  }

  void lock() {
    if (state.isEnabled) {
      state = state.copyWith(isUnlocked: false);
    }
  }
}

final biometricProvider = StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
  return BiometricNotifier();
});

// 26. Server Performance Monitor Widget Provider
class ServerPerformanceMetrics {
  final String serverName;
  final double tps;
  final int onlinePlayers;
  final int maxPlayers;
  final int pingMs;
  final double cpuUsagePct;
  final double ramUsageGb;
  final double maxRamGb;

  ServerPerformanceMetrics({
    this.serverName = 'RenCloud Node Cluster',
    this.tps = 20.0,
    this.onlinePlayers = 142,
    this.maxPlayers = 200,
    this.pingMs = 18,
    this.cpuUsagePct = 34.2,
    this.ramUsageGb = 11.4,
    this.maxRamGb = 16.0,
  });
}

final serverMetricsProvider = Provider<ServerPerformanceMetrics>((ref) => ServerPerformanceMetrics());

// 27. Offline Catalog Cache Provider
final isOfflineModeProvider = StateProvider<bool>((ref) => false);

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
    final matchesCategory = (category == 'all') || (plan.categoryId == category);
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
