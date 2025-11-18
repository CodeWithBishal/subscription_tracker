import '../config/app_config.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../models/subscription.dart';

class TrackerState {
  const TrackerState({
    required this.sales,
    required this.customers,
    required this.subscriptions,
    required this.isLoading,
    required this.isOffline,
    this.errorMessage,
    this.lastSyncedAt,
  });

  final List<Sale> sales;
  final List<Customer> customers;
  final List<Subscription> subscriptions;
  final bool isLoading;
  final bool isOffline;
  final String? errorMessage;
  final DateTime? lastSyncedAt;

  factory TrackerState.initial() => const TrackerState(
    sales: [],
    customers: [],
    subscriptions: [],
    isLoading: true,
    isOffline: false,
    errorMessage: null,
    lastSyncedAt: null,
  );

  TrackerState copyWith({
    List<Sale>? sales,
    List<Customer>? customers,
    List<Subscription>? subscriptions,
    bool? isLoading,
    bool? isOffline,
    String? errorMessage,
    DateTime? lastSyncedAt,
  }) {
    return TrackerState(
      sales: sales ?? this.sales,
      customers: customers ?? this.customers,
      subscriptions: subscriptions ?? this.subscriptions,
      isLoading: isLoading ?? this.isLoading,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: errorMessage,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Customer? customerById(String id) {
    try {
      return customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Sale? saleById(String id) {
    try {
      return sales.firstWhere((sale) => sale.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Subscription> subscriptionsForSale(String saleId) =>
      subscriptions.where((sub) => sub.saleId == saleId).toList();

  List<Subscription> get upcomingRenewals {
    final now = DateTime.now();
    final threshold = now.add(Duration(days: AppConfig.dueSoonWindowInDays));
    return subscriptions
        .where((sub) => sub.nextDueDate.isBefore(threshold))
        .toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
  }

  List<Sale> get recentSales =>
      [...sales]..sort((a, b) => b.saleDate.compareTo(a.saleDate));
}
