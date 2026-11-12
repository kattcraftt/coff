import 'package:intl/intl.dart';

String formatMoney(double? amount, String? currency) {
  if (amount == null) return '—';
  if (currency == null || currency.isEmpty) {
    return NumberFormat('#,##0.00').format(amount);
  }
  return NumberFormat.simpleCurrency(name: currency).format(amount);
}

String formatDate(DateTime? date) =>
    date == null ? 'No date' : DateFormat.yMMMd().format(date);
