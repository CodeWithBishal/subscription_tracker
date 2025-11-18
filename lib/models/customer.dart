import 'package:intl/intl.dart';

class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.company,
    this.address,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String? company;
  final String? address;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Customer.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? raw) =>
        raw == null || raw.isEmpty ? null : DateTime.tryParse(raw);

    return Customer(
      id: json['customerId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      company: json['company']?.toString(),
      address: json['address']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: parseDate(json['createdAt']?.toString()),
      updatedAt: parseDate(json['updatedAt']?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'customerId': id,
    'name': name,
    'email': email,
    'phone': phone,
    'company': company,
    'address': address,
    'notes': notes,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  String get shortDescription {
    final buffer = StringBuffer(name);
    if (company != null && company!.isNotEmpty) {
      buffer.write(' · $company');
    }
    buffer.write(' · $phone');
    return buffer.toString();
  }

  String get searchableText =>
      '${name.toLowerCase()} '
      '${company?.toLowerCase() ?? ''} '
      '${email.toLowerCase()} '
      '${phone.toLowerCase()}';

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first : '';
    final last = parts.length > 1 ? parts.last : '';
    return (first.isNotEmpty ? first[0] : '') +
        (last.isNotEmpty ? last[0] : '');
  }

  String get createdAtLabel => createdAt == null
      ? '—'
      : DateFormat('dd MMM yyyy').format(createdAt!.toLocal());
}
