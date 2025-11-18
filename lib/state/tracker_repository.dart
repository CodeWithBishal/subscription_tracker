import '../models/customer.dart';
import '../models/drafts.dart';
import '../models/sale.dart';
import '../models/subscription.dart';
import '../models/tracker_snapshot.dart';
import '../services/local_cache_service.dart';
import '../services/sheets_data_source.dart';

class TrackerRepository {
  TrackerRepository(this._remote, this._cache);

  final SheetsDataSource _remote;
  final LocalCacheService _cache;

  Future<TrackerSnapshot> syncRemote() async {
    final results = await Future.wait([
      _remote.fetchSales(),
      _remote.fetchCustomers(),
      _remote.fetchSubscriptions(),
    ]);

    final sales = results[0] as List<Sale>;
    final customers = results[1] as List<Customer>;
    final subscriptions = results[2] as List<Subscription>;

    await Future.wait([
      _cache.persistSales(sales),
      _cache.persistCustomers(customers),
      _cache.persistSubscriptions(subscriptions),
    ]);

    return TrackerSnapshot(
      sales: sales,
      customers: customers,
      subscriptions: subscriptions,
      isFresh: true,
    );
  }

  Future<TrackerSnapshot> readCache() async {
    final cache = await Future.wait([
      _cache.readSales(),
      _cache.readCustomers(),
      _cache.readSubscriptions(),
    ]);
    return TrackerSnapshot(
      sales: cache[0] as List<Sale>,
      customers: cache[1] as List<Customer>,
      subscriptions: cache[2] as List<Subscription>,
      isFresh: false,
    );
  }

  Future<Sale> createSale(SaleDraft draft) async {
    final sale = await _remote.createSale(draft);
    final cachedSales = await _cache.readSales();
    await _cache.persistSales([...cachedSales, sale]);
    return sale;
  }

  Future<Customer> upsertCustomer(CustomerDraft draft) async {
    final customer = await _remote.upsertCustomer(draft);
    final cachedCustomers = await _cache.readCustomers();
    final updated = [
      for (final existing in cachedCustomers)
        if (existing.id == customer.id) customer else existing,
    ];
    final exists = updated.any((element) => element.id == customer.id);
    await _cache.persistCustomers(exists ? updated : [...updated, customer]);
    return customer;
  }

  Future<Subscription> addSubscription(SubscriptionDraft draft) async {
    final subscription = await _remote.addSubscription(draft);
    final cached = await _cache.readSubscriptions();
    await _cache.persistSubscriptions([...cached, subscription]);
    return subscription;
  }

  Future<Subscription> markSubscriptionPaid({
    required String subscriptionId,
    required DateTime paidOn,
  }) async {
    final subscription = await _remote.markSubscriptionPaid(
      subscriptionId: subscriptionId,
      paidOn: paidOn,
    );
    final cached = await _cache.readSubscriptions();
    final updated = [
      for (final item in cached)
        if (item.id == subscription.id) subscription else item,
    ];
    await _cache.persistSubscriptions(updated);
    return subscription;
  }
}
