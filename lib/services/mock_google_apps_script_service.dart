import 'dart:async';
import 'dart:math';

import '../models/billing_cycle.dart';
import '../models/customer.dart';
import '../models/drafts.dart';
import '../models/payment_status.dart';
import '../models/sale.dart';
import '../models/subscription.dart';
import 'sheets_data_source.dart';

class MockGoogleAppsScriptService implements SheetsDataSource {
  MockGoogleAppsScriptService() {
    _seed();
  }

  final _random = Random();
  final List<Sale> _sales = [];
  final List<Customer> _customers = [];
  final List<Subscription> _subscriptions = [];

  void _seed() {
    final customer = Customer(
      id: 'CUST-1',
      name: 'Acme Retail',
      email: 'ops@acme.test',
      phone: '+91 98765 43210',
      company: 'Acme',
    );
    _customers.add(customer);

    final sale = Sale(
      id: 'SALE-1',
      customerId: customer.id,
      title: 'E-commerce Suite',
      dealValue: 150000,
      saleDate: DateTime.now().subtract(const Duration(days: 10)),
      description: 'Full E-commerce build',
    );
    _sales.add(sale);

    _subscriptions.add(
      Subscription(
        id: 'SUB-1',
        saleId: sale.id,
        serviceName: 'Database Hosting',
        billingCycle: BillingCycle.yearly,
        amount: 24000,
        nextDueDate: DateTime.now().add(const Duration(days: 20)),
        lastPaidDate: DateTime.now().subtract(const Duration(days: 345)),
        status: PaymentStatus.pending,
        autoRenew: true,
      ),
    );
  }

  @override
  Future<Customer> upsertCustomer(CustomerDraft draft) async {
    final existingIndex = _customers.indexWhere(
      (element) => element.email == draft.email,
    );
    if (existingIndex != -1) {
      return _customers[existingIndex];
    }
    final customer = Customer(
      id: 'CUST-${_random.nextInt(99999)}',
      name: draft.name,
      email: draft.email,
      phone: draft.phone,
      company: draft.company,
      address: draft.address,
      notes: draft.notes,
    );
    _customers.add(customer);
    return Future.delayed(const Duration(milliseconds: 300), () => customer);
  }

  @override
  Future<Sale> createSale(SaleDraft draft) async {
    final sale = Sale(
      id: 'SALE-${_random.nextInt(999999)}',
      customerId: draft.customerId,
      title: draft.title,
      dealValue: draft.dealValue,
      saleDate: draft.saleDate,
      description: draft.description,
      channel: draft.channel,
      notes: draft.notes,
    );
    _sales.add(sale);
    return Future.delayed(const Duration(milliseconds: 300), () => sale);
  }

  @override
  Future<Subscription> addSubscription(SubscriptionDraft draft) async {
    final subscription = Subscription(
      id: 'SUB-${_random.nextInt(999999)}',
      saleId: draft.saleId,
      serviceName: draft.serviceName,
      billingCycle: draft.billingCycle,
      amount: draft.amount,
      nextDueDate: draft.nextDueDate,
      status: PaymentStatus.pending,
      autoRenew: draft.autoRenew,
      notes: draft.notes,
    );
    _subscriptions.add(subscription);
    return Future.delayed(
      const Duration(milliseconds: 300),
      () => subscription,
    );
  }

  @override
  Future<List<Customer>> fetchCustomers() async => Future.delayed(
    const Duration(milliseconds: 250),
    () => List.unmodifiable(_customers),
  );

  @override
  Future<List<Sale>> fetchSales() async => Future.delayed(
    const Duration(milliseconds: 250),
    () => List.unmodifiable(_sales),
  );

  @override
  Future<List<Subscription>> fetchSubscriptions() async => Future.delayed(
    const Duration(milliseconds: 250),
    () => List.unmodifiable(_subscriptions),
  );

  @override
  Future<Subscription> markSubscriptionPaid({
    required String subscriptionId,
    required DateTime paidOn,
  }) async {
    final index = _subscriptions.indexWhere((e) => e.id == subscriptionId);
    if (index == -1) {
      throw StateError('Subscription not found');
    }
    final updated = _subscriptions[index].markPaid(paidOn);
    _subscriptions[index] = updated;
    return Future.delayed(const Duration(milliseconds: 200), () => updated);
  }
}
