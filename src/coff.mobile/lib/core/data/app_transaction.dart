/// A transaction as returned by `GET transactions`.
/// Expenses are negative amounts, income positive.
class AppTransaction {
  const AppTransaction({
    required this.id,
    required this.amount,
    required this.payee,
    required this.date,
    required this.accountId,
    required this.categoryId,
    this.notes,
  });

  final String id;
  final double amount;
  final String payee;
  final String? notes;

  /// A calendar date (no time, no timezone).
  final DateTime date;
  final String accountId;
  final String categoryId;

  bool get isExpense => amount < 0;

  factory AppTransaction.fromJson(Map<String, dynamic> json) {
    final parsed = DateTime.parse(json['date'] as String);

    return AppTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      payee: json['payee'] as String,
      notes: json['notes'] as String?,
      // Keep the y/m/d the server stored; never shift it by the device timezone.
      date: DateTime(parsed.year, parsed.month, parsed.day),
      accountId: json['accountId'] as String,
      categoryId: json['categoryId'] as String,
    );
  }
}
