import '../models/customer.dart';
import '../models/drafts.dart';
import '../models/sale.dart';
import '../models/subscription.dart';
import 'api_client.dart';
import 'sheets_data_source.dart';

class GoogleAppsScriptService implements SheetsDataSource {
  GoogleAppsScriptService(this._client);

  final ApiClient _client;

  @override
  Future<List<Sale>> fetchSales() async {
    final response = await _client.get(
      queryParameters: {'action': 'fetchSales'},
    );
    return _decodeList(response, 'sales').map(Sale.fromJson).toList();
  }

  @override
  Future<List<Customer>> fetchCustomers() async {
    final response = await _client.get(
      queryParameters: {'action': 'fetchCustomers'},
    );
    return _decodeList(response, 'customers').map(Customer.fromJson).toList();
  }

  @override
  Future<List<Subscription>> fetchSubscriptions() async {
    final response = await _client.get(
      queryParameters: {'action': 'fetchSubscriptions'},
    );
    return _decodeList(
      response,
      'subscriptions',
    ).map(Subscription.fromJson).toList();
  }

  @override
  Future<Sale> createSale(SaleDraft draft) async {
    final response = await _client.post(
      queryParameters: {'action': 'createSale'},
      body: draft.toJson(),
    );
    return Sale.fromJson(_decodeObject(response, 'sale'));
  }

  @override
  Future<Customer> upsertCustomer(CustomerDraft draft) async {
    final response = await _client.post(
      queryParameters: {'action': 'upsertCustomer'},
      body: draft.toJson(),
    );
    return Customer.fromJson(_decodeObject(response, 'customer'));
  }

  @override
  Future<Subscription> addSubscription(SubscriptionDraft draft) async {
    final response = await _client.post(
      queryParameters: {'action': 'addSubscription'},
      body: draft.toJson(),
    );
    return Subscription.fromJson(_decodeObject(response, 'subscription'));
  }

  @override
  Future<Subscription> markSubscriptionPaid({
    required String subscriptionId,
    required DateTime paidOn,
  }) async {
    final response = await _client.put(
      queryParameters: {'action': 'markSubscriptionPaid'},
      body: {
        'subscriptionId': subscriptionId,
        'paidOn': paidOn.toIso8601String(),
      },
    );
    return Subscription.fromJson(_decodeObject(response, 'subscription'));
  }

  List<Map<String, dynamic>> _decodeList(
    Map<String, dynamic> response,
    String collectionKey,
  ) {
    final listCandidate = response[collectionKey] ?? response['data'];
    if (listCandidate is List) {
      return listCandidate
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _decodeObject(
    Map<String, dynamic> response,
    String key,
  ) {
    final data = response[key] ?? response['data'] ?? response;
    return Map<String, dynamic>.from(data as Map);
  }
}
