import 'customer.dart';
import 'sale.dart';
import 'subscription.dart';

class TrackerSnapshot {
  const TrackerSnapshot({
    required this.sales,
    required this.customers,
    required this.subscriptions,
    required this.isFresh,
  });

  final List<Sale> sales;
  final List<Customer> customers;
  final List<Subscription> subscriptions;
  final bool isFresh;

  static const empty = TrackerSnapshot(
    sales: [],
    customers: [],
    subscriptions: [],
    isFresh: false,
  );
}
