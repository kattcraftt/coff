import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// One line of a report, with ids already resolved to names.
class ReportRow {
  const ReportRow({
    required this.date,
    required this.payee,
    required this.category,
    required this.account,
    required this.amount,
    this.notes,
  });

  final DateTime date;
  final String payee;
  final String category;
  final String account;
  final double amount;
  final String? notes;
}

class ReportData {
  const ReportData({
    required this.rows,
    required this.periodLabel,
    required this.accountLabel,
    required this.currency,
  });

  final List<ReportRow> rows;
  final String periodLabel;
  final String accountLabel;
  final String currency;

  /// Expenses are negative amounts.
  double get income => rows.where((r) => r.amount > 0).fold(0, (s, r) => s + r.amount);
  double get expenses => rows.where((r) => r.amount < 0).fold(0, (s, r) => s + r.amount);
  double get net => income + expenses;

  /// Expense totals per category (positive numbers), biggest first.
  List<MapEntry<String, double>> get categoryTotals {
    final totals = <String, double>{};
    for (final r in rows.where((r) => r.amount < 0)) {
      totals.update(r.category, (v) => v - r.amount, ifAbsent: () => -r.amount);
    }
    return totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }
}

final _day = DateFormat('yyyy-MM-dd');
final _money = NumberFormat('#,##0.00');

String _csvCell(String value) {
  final needsQuotes = value.contains(',') || value.contains('"') || value.contains('\n');
  final escaped = value.replaceAll('"', '""');
  return needsQuotes ? '"$escaped"' : escaped;
}

/// UTF-8 with a BOM so Excel opens accents and symbols correctly.
Uint8List buildCsv(ReportData data) {
  final lines = <String>['Date,Payee,Category,Account,Amount,Notes'];
  for (final r in data.rows) {
    lines.add([
      _day.format(r.date),
      r.payee,
      r.category,
      r.account,
      r.amount.toStringAsFixed(2),
      r.notes ?? '',
    ].map(_csvCell).join(','));
  }
  return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(lines.join('\r\n'))]);
}

/// The default PDF font only covers Latin-1, so amounts use the currency CODE
/// (e.g. "PHP 1,250.00") rather than a symbol like the peso sign.
Future<Uint8List> buildPdf(ReportData data) async {
  String money(double v) => '${data.currency} ${_money.format(v)}';

  final doc = pw.Document(title: 'coff expense report');
  final bold = pw.TextStyle(fontWeight: pw.FontWeight.bold);

  pw.Widget stat(String label, double value) => pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text(money(value), style: bold),
        ],
      ),
    ),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Text(
          'coff expense report',
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text('${data.periodLabel} - ${data.accountLabel}'),
        pw.SizedBox(height: 16),
        pw.Row(
          children: [
            stat('Income', data.income),
            pw.SizedBox(width: 8),
            stat('Expenses', data.expenses),
            pw.SizedBox(width: 8),
            stat('Net', data.net),
          ],
        ),
        if (data.categoryTotals.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          pw.Text('Spending by category', style: bold),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            context: context,
            headers: ['Category', 'Spent'],
            data: [
              for (final e in data.categoryTotals) [e.key, money(e.value)],
            ],
            cellAlignments: {1: pw.Alignment.centerRight},
            headerStyle: bold,
          ),
        ],
        pw.SizedBox(height: 20),
        pw.Text('Transactions (${data.rows.length})', style: bold),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          context: context,
          headers: ['Date', 'Payee', 'Category', 'Account', 'Amount'],
          data: [
            for (final r in data.rows)
              [_day.format(r.date), r.payee, r.category, r.account, money(r.amount)],
          ],
          cellAlignments: {4: pw.Alignment.centerRight},
          headerStyle: bold,
          cellStyle: const pw.TextStyle(fontSize: 9),
        ),
      ],
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ),
    ),
  );

  return doc.save();
}
