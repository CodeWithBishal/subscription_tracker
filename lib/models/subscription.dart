import 'package:intl/intl.dart';

import 'billing_cycle.dart';
import 'payment_status.dart';

class Subscription {
  const Subscription({
    required this.id,
    required this.saleId,
    required this.serviceName,
    required this.billingCycle,
    required this.amount,
    required this.nextDueDate,
    required this.status,
    this.lastPaidDate,
    this.autoRenew = true,
    this.notes,
  });

  final String id;
  final String saleId;
  final String serviceName;
  final BillingCycle billingCycle;
  final double amount;
  final DateTime nextDueDate;
  final DateTime? lastPaidDate;
  final PaymentStatus status;
  final bool autoRenew;
  final String? notes;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? raw) =>
        raw == null || raw.isEmpty ? null : DateTime.tryParse(raw);

    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '') ?? 0;

    return Subscription(
      id: json['subscriptionId']?.toString() ?? json['id']?.toString() ?? '',
      saleId: json['saleId']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? 'Service',
      billingCycle: BillingCycle.fromSheetValue(
        json['billingCycle']?.toString() ?? '',
      ),
      amount: amount,
      nextDueDate: parseDate(json['nextDueDate']?.toString()) ?? DateTime.now(),
      lastPaidDate: parseDate(json['lastPaidDate']?.toString()),
      status: PaymentStatus.fromSheetValue(json['status']?.toString() ?? ''),
      autoRenew: (json['autoRenew']?.toString().toLowerCase() ?? 'y') == 'y',
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'subscriptionId': id,
    'saleId': saleId,
    'serviceName': serviceName,
    'billingCycle': billingCycle.sheetValue,
    'amount': amount,
    'nextDueDate': nextDueDate.toIso8601String(),
    'lastPaidDate': lastPaidDate?.toIso8601String(),
    'status': status.sheetValue,
    'autoRenew': autoRenew ? 'Y' : 'N',
    'notes': notes,
  };

  bool get isDueSoon {
    final today = DateTime.now();
    final diff = nextDueDate.difference(today).inDays;
    return diff <= 14 && diff >= -14;
  }

  bool get isOverdue => nextDueDate.isBefore(DateTime.now());

  String get dueLabel =>
      DateFormat('dd MMM yyyy').format(nextDueDate.toLocal());

  Subscription markPaid(DateTime paidOn) {
    final newNextDueDate = paidOn.add(billingCycle.duration);
    return Subscription(
      id: id,
      saleId: saleId,
      serviceName: serviceName,
      billingCycle: billingCycle,
      amount: amount,
      nextDueDate: newNextDueDate,
      lastPaidDate: paidOn,
      status: PaymentStatus.paid,
      autoRenew: autoRenew,
      notes: notes,
    );
  }
}
