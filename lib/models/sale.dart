import 'package:intl/intl.dart';

class Sale {
  const Sale({
    required this.id,
    required this.customerId,
    required this.title,
    required this.dealValue,
    required this.saleDate,
    this.description,
    this.channel,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String customerId;
  final String title;
  final double dealValue;
  final DateTime saleDate;
  final String? description;
  final String? channel;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Sale.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? raw) =>
        raw == null || raw.isEmpty ? null : DateTime.tryParse(raw);

    final saleDate = parseDate(json['saleDate']?.toString()) ?? DateTime.now();
    final rawValue = json['dealValue'];
    final value = rawValue is num
        ? rawValue.toDouble()
        : double.tryParse(rawValue?.toString() ?? '') ?? 0;

    return Sale(
      id: json['saleId']?.toString() ?? json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Sale',
      dealValue: value,
      saleDate: saleDate,
      description: json['description']?.toString(),
      channel: json['channel']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: parseDate(json['createdAt']?.toString()),
      updatedAt: parseDate(json['updatedAt']?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'saleId': id,
    'customerId': customerId,
    'title': title,
    'dealValue': dealValue,
    'saleDate': saleDate.toIso8601String(),
    'description': description,
    'channel': channel,
    'notes': notes,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  String get formattedAmount =>
      NumberFormat.currency(symbol: '₹').format(dealValue);

  String get saleDateLabel =>
      DateFormat('dd MMM yyyy').format(saleDate.toLocal());

  bool matchesQuery(String query, {String customerName = ''}) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        (description?.toLowerCase().contains(lowerQuery) ?? false) ||
        (customerName.toLowerCase().contains(lowerQuery));
  }
}
