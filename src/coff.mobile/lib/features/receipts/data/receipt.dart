enum ReceiptStatus { pending, confirmed }

/// A scanned receipt as returned by `receipts/scan` and `receipts`.
///
/// Amounts are `double` for display/entry in v1. Before adding totals,
/// splits or multi-currency math, switch to integer minor units or `Decimal`.
class Receipt {
  const Receipt({
    required this.id,
    this.merchant,
    this.date,
    this.total,
    this.tax,
    this.currency,
    this.status = ReceiptStatus.pending,
    this.transactionId,
  });

  final String id;
  final String? merchant;

  /// A calendar date (no time, no timezone).
  final DateTime? date;
  final double? total;
  final double? tax;
  final String? currency;
  final ReceiptStatus status;
  final String? transactionId;

  factory Receipt.fromJson(Map<String, dynamic> json) {
    final parsed = DateTime.tryParse((json['date'] as String?) ?? '');

    return Receipt(
      id: json['id'] as String,
      merchant: json['merchant'] as String?,
      // Keep the y/m/d the server stored; never shift it by the device timezone.
      date: parsed == null ? null : DateTime(parsed.year, parsed.month, parsed.day),
      total: (json['total'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      status: (json['status'] as String?)?.toLowerCase() == 'confirmed'
          ? ReceiptStatus.confirmed
          : ReceiptStatus.pending,
      transactionId: json['transactionId'] as String?,
    );
  }
}
