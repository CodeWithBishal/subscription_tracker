enum PaymentStatus {
  pending,
  paid,
  overdue;

  String get label => name[0].toUpperCase() + name.substring(1);

  static PaymentStatus fromSheetValue(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'paid':
        return PaymentStatus.paid;
      case 'overdue':
        return PaymentStatus.overdue;
      default:
        return PaymentStatus.pending;
    }
  }

  String get sheetValue => name.toUpperCase();
}
