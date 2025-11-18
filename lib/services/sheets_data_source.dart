import '../models/customer.dart';
import '../models/drafts.dart';
import '../models/sale.dart';
import '../models/subscription.dart';

abstract class SheetsDataSource {
  Future<List<Sale>> fetchSales();
  Future<List<Customer>> fetchCustomers();
  Future<List<Subscription>> fetchSubscriptions();

  Future<Sale> createSale(SaleDraft draft);
  Future<Customer> upsertCustomer(CustomerDraft draft);
  Future<Subscription> addSubscription(SubscriptionDraft draft);
  Future<Subscription> markSubscriptionPaid({
    required String subscriptionId,
    required DateTime paidOn,
  });
}
