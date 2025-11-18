enum BillingCycle {
  monthly(days: 30),
  quarterly(days: 90),
  yearly(days: 365);

  const BillingCycle({required this.days});

  final int days;

  Duration get duration => Duration(days: days);

  String get sheetValue => name.toUpperCase();

  static BillingCycle fromSheetValue(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'monthly':
        return BillingCycle.monthly;
      case 'quarterly':
        return BillingCycle.quarterly;
      case 'yearly':
        return BillingCycle.yearly;
      default:
        return BillingCycle.monthly;
    }
  }
}
