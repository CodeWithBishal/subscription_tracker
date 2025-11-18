import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer.dart';
import '../models/sale.dart';
import '../models/subscription.dart';

class LocalCacheService {
  static const _salesKey = 'cache_sales';
  static const _customersKey = 'cache_customers';
  static const _subscriptionsKey = 'cache_subscriptions';

  Future<void> persistSales(List<Sale> sales) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(sales.map((e) => e.toJson()).toList());
    await prefs.setString(_salesKey, payload);
  }

  Future<void> persistCustomers(List<Customer> customers) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(customers.map((e) => e.toJson()).toList());
    await prefs.setString(_customersKey, payload);
  }

  Future<void> persistSubscriptions(List<Subscription> subscriptions) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(subscriptions.map((e) => e.toJson()).toList());
    await prefs.setString(_subscriptionsKey, payload);
  }

  Future<List<Sale>> readSales() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_salesKey);
    if (raw == null) return <Sale>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Sale.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<Customer>> readCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customersKey);
    if (raw == null) return <Customer>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Customer.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<Subscription>> readSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_subscriptionsKey);
    if (raw == null) return <Subscription>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Subscription.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
