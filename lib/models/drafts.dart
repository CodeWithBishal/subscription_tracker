import 'billing_cycle.dart';

class SaleDraft {
  const SaleDraft({
    required this.customerId,
    required this.title,
    required this.dealValue,
    required this.saleDate,
    this.description,
    this.channel,
    this.notes,
  });

  final String customerId;
  final String title;
  final double dealValue;
  final DateTime saleDate;
  final String? description;
  final String? channel;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    'title': title,
    'dealValue': dealValue,
    'saleDate': saleDate.toIso8601String(),
    'description': description,
    'channel': channel,
    'notes': notes,
  };
}

class CustomerDraft {
  const CustomerDraft({
    this.customerId,
    required this.name,
    required this.email,
    required this.phone,
    this.company,
    this.address,
    this.notes,
  });

  final String? customerId;
  final String name;
  final String email;
  final String phone;
  final String? company;
  final String? address;
  final String? notes;

  Map<String, dynamic> toJson() => {
    if (customerId != null) 'customerId': customerId,
    'name': name,
    'email': email,
    'phone': phone,
    'company': company,
    'address': address,
    'notes': notes,
  };
}

class SubscriptionDraft {
  const SubscriptionDraft({
    required this.saleId,
    required this.serviceName,
    required this.billingCycle,
    required this.amount,
    required this.nextDueDate,
    this.autoRenew = true,
    this.notes,
  });

  final String saleId;
  final String serviceName;
  final BillingCycle billingCycle;
  final double amount;
  final DateTime nextDueDate;
  final bool autoRenew;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'saleId': saleId,
    'serviceName': serviceName,
    'billingCycle': billingCycle.sheetValue,
    'amount': amount,
    'nextDueDate': nextDueDate.toIso8601String(),
    'autoRenew': autoRenew ? 'Y' : 'N',
    'notes': notes,
  };
}
