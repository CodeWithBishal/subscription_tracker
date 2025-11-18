import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer.dart';
import '../models/drafts.dart';
import '../models/sale.dart';
import '../models/subscription.dart';
import '../models/tracker_snapshot.dart';
import 'tracker_repository.dart';
import 'tracker_state.dart';

class TrackerNotifier extends StateNotifier<TrackerState> {
  TrackerNotifier(this._repository) : super(TrackerState.initial()) {
    _bootstrap();
  }

  final TrackerRepository _repository;

  Future<void> _bootstrap() async {
    final cache = await _repository.readCache();
    if (cache.sales.isNotEmpty || cache.customers.isNotEmpty) {
      state = state.copyWith(
        sales: cache.sales,
        customers: cache.customers,
        subscriptions: cache.subscriptions,
        isLoading: false,
        isOffline: true,
      );
    }
    await refresh();
  }

  Future<void> refresh() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final snapshot = await _repository.syncRemote();
      _applySnapshot(snapshot, isOffline: false);
    } catch (error) {
      final snapshot = await _repository.readCache();
      _applySnapshot(snapshot, isOffline: true, error: error.toString());
    }
  }

  Future<Customer> upsertCustomer(CustomerDraft draft) async {
    final customer = await _repository.upsertCustomer(draft);
    await refresh();
    return customer;
  }

  Future<Sale> createSale(SaleDraft draft) async {
    final sale = await _repository.createSale(draft);
    await refresh();
    return sale;
  }

  Future<Subscription> addSubscription(SubscriptionDraft draft) async {
    final subscription = await _repository.addSubscription(draft);
    await refresh();
    return subscription;
  }

  Future<Subscription> markSubscriptionPaid(
    String subscriptionId,
    DateTime paidOn,
  ) async {
    final subscription = await _repository.markSubscriptionPaid(
      subscriptionId: subscriptionId,
      paidOn: paidOn,
    );
    await refresh();
    return subscription;
  }

  void _applySnapshot(
    TrackerSnapshot snapshot, {
    required bool isOffline,
    String? error,
  }) {
    state = state.copyWith(
      sales: snapshot.sales,
      customers: snapshot.customers,
      subscriptions: snapshot.subscriptions,
      isLoading: false,
      isOffline: isOffline,
      errorMessage: error,
      lastSyncedAt: DateTime.now(),
    );
  }
}
