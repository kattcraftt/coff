/// Turns the cells of a bank statement CSV into transactions.
/// Pure Dart (no Flutter, no network), so it can be unit tested.
library;

/// How the statement expresses money.
enum AmountMode {
  /// One signed column: negative = money out (an expense).
  single,

  /// Separate "debit/withdrawal" and "credit/deposit" columns.
  debitCredit,
}

/// Day/month order for dates like 03/04/2026.
enum DateOrder { monthFirst, dayFirst }

class ColumnMapping {
  const ColumnMapping({
    this.date,
    this.description,
    this.amount,
    this.debit,
    this.credit,
    this.notes,
  });

  final int? date;
  final int? description;
  final int? amount;
  final int? debit;
  final int? credit;
  final int? notes;

  ColumnMapping copyWith({
    int? Function()? date,
    int? Function()? description,
    int? Function()? amount,
    int? Function()? debit,
    int? Function()? credit,
    int? Function()? notes,
  }) =>
      ColumnMapping(
        date: date != null ? date() : this.date,
        description: description != null ? description() : this.description,
        amount: amount != null ? amount() : this.amount,
        debit: debit != null ? debit() : this.debit,
        credit: credit != null ? credit() : this.credit,
        notes: notes != null ? notes() : this.notes,
      );
}

class StatementRow {
  const StatementRow({
    required this.date,
    required this.payee,
    required this.amount,
    this.notes,
  });

  final DateTime date;
  final String payee;

  /// Negative = expense, positive = income (the app's convention).
  final double amount;
  final String? notes;
}

class ParseOutcome {
  const ParseOutcome({required this.rows, required this.skipped});

  final List<StatementRow> rows;

  /// Lines that could not be used (no date, no amount, totals, blank...).
  final int skipped;
}

// ---------------------------------------------------------------- columns

/// Guesses the mapping from header names; returns the mode that fits.
({ColumnMapping mapping, AmountMode mode}) guessMapping(List<String> header) {
  final names = header.map((h) => h.trim().toLowerCase()).toList();

  int? find(List<RegExp> patterns, {Set<int> exclude = const {}}) {
    for (final p in patterns) {
      for (var i = 0; i < names.length; i++) {
        if (!exclude.contains(i) && p.hasMatch(names[i])) return i;
      }
    }
    return null;
  }

  final date = find([
    RegExp(r'transaction date'),
    RegExp(r'posting date|posted'),
    RegExp(r'date'),
  ]);
  final debit = find([
    RegExp(r'debit|withdraw|money out|paid out'),
    RegExp(r'^dr$'),
  ]);
  final credit = find([
    RegExp(r'credit|deposit|money in|paid in'),
    RegExp(r'^cr$'),
  ]);
  final used = <int>{
    if (date != null) date,
    if (debit != null) debit,
    if (credit != null) credit,
  };
  final description = find([
    RegExp(r'descr'),
    RegExp(r'payee|merchant'),
    RegExp(r'details|particular|narrat'),
    RegExp(r'memo|name|reference'),
  ], exclude: used);
  final amount = find([RegExp(r'^amount$|amount|^amt'), RegExp(r'value')],
      exclude: {...used, if (description != null) description});

  final split = debit != null && credit != null;

  return (
  mapping: ColumnMapping(
    date: date,
    description: description,
    amount: split ? null : amount,
    debit: split ? debit : null,
    credit: split ? credit : null,
  ),
  mode: split ? AmountMode.debitCredit : AmountMode.single,
  );
}

// ------------------------------------------------------------------ amounts

/// Parses "1,234.50", "-12.00", "(45.10)", "PHP 1 200", "1.234,50", "75.00-",
/// "300.00 DR". Returns null when there is no number.
double? parseAmount(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return null;
  // Dates and times must never be mistaken for amounts ("19 Oct 2026", "10/19/2026").
  if (s.contains('/') || s.contains(':')) return null;
  if (RegExp(r'\d\s*[A-Za-z]{3,}\s*\d').hasMatch(s)) return null;

  var negative = false;
  if (s.startsWith('(') && s.endsWith(')')) {
    negative = true;
    s = s.substring(1, s.length - 1);
  }
  if (RegExp(r'\bDR\.?$', caseSensitive: false).hasMatch(s)) negative = true;

  s = s.replaceAll(RegExp(r'[^\d.,\-+]'), '');
  if (s.endsWith('-')) {
    negative = true;
    s = s.substring(0, s.length - 1);
  }
  if (s.startsWith('-')) {
    negative = true;
    s = s.substring(1);
  } else if (s.startsWith('+')) {
    s = s.substring(1);
  }
  if (s.isEmpty) return null;

  final hasDot = s.contains('.');
  final hasComma = s.contains(',');
  if (hasDot && hasComma) {
    // The separator that comes last is the decimal point.
    if (s.lastIndexOf(',') > s.lastIndexOf('.')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else {
      s = s.replaceAll(',', '');
    }
  } else if (hasComma) {
    if (RegExp(r'^\d{1,3}(,\d{3})+$').hasMatch(s)) {
      s = s.replaceAll(',', '');
    } else if (RegExp(r'^\d+,\d{1,2}$').hasMatch(s)) {
      s = s.replaceAll(',', '.');
    } else {
      s = s.replaceAll(',', '');
    }
  } else if (hasDot && RegExp(r'^\d{1,3}(\.\d{3}){2,}$').hasMatch(s)) {
    s = s.replaceAll('.', '');
  }

  final value = double.tryParse(s);
  if (value == null) return null;
  return negative ? -value : value;
}

/// Fills date / description / amount columns that the header names did not
/// reveal, by looking at what the cells actually contain. Works without a header.
ColumnMapping fillMissingFromContent(
    List<List<String>> rows,
    ColumnMapping mapping, {
      int sample = 30,
    }) {
  final sampled = rows.take(sample).toList();
  if (sampled.isEmpty) return mapping;

  final columns = sampled.fold<int>(0, (n, r) => r.length > n ? r.length : n);
  final taken = <int>{
    if (mapping.date != null) mapping.date!,
    if (mapping.description != null) mapping.description!,
    if (mapping.amount != null) mapping.amount!,
    if (mapping.debit != null) mapping.debit!,
    if (mapping.credit != null) mapping.credit!,
    if (mapping.notes != null) mapping.notes!,
  };

  bool isDate(String v) =>
      parseDate(v, DateOrder.monthFirst) != null ||
          parseDate(v, DateOrder.dayFirst) != null;

  /// Share of non-empty cells in [column] that satisfy [test].
  double share(int column, bool Function(String) test) {
    var hits = 0;
    var total = 0;
    for (final row in sampled) {
      if (column >= row.length) continue;
      final value = row[column].trim();
      if (value.isEmpty) continue;
      total++;
      if (test(value)) hits++;
    }
    return total == 0 ? 0 : hits / total;
  }

  int? best(double Function(int column) score, {double min = 0.6}) {
    int? index;
    var top = min - 0.0001;
    for (var c = 0; c < columns; c++) {
      if (taken.contains(c)) continue;
      final value = score(c);
      if (value > top) {
        top = value;
        index = c;
      }
    }
    if (index != null) taken.add(index);
    return index;
  }

  final date = mapping.date ?? best((c) => share(c, isDate));

  final needsAmount = mapping.amount == null && mapping.debit == null && mapping.credit == null;
  final amount = needsAmount
      ? best((c) => share(c, (v) => !isDate(v) && parseAmount(v) != null))
      : mapping.amount;

  final description = mapping.description ??
      best((c) {
        // The text-heavy column: cells that are neither dates nor numbers.
        final textual = share(c, (v) => !isDate(v) && parseAmount(v) == null);
        return textual >= 0.6 ? textual : 0;
      }, min: 0.01);

  return ColumnMapping(
    date: date,
    description: description,
    amount: amount,
    debit: mapping.debit,
    credit: mapping.credit,
    notes: mapping.notes,
  );
}

// -------------------------------------------------------------------- dates

const _months = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

final _timeSuffix = RegExp(
  r'[ T]+\d{1,2}:\d{2}(:\d{2})?(\.\d+)?\s*([AaPp][Mm])?\s*(Z|[+-]\d{2}:?\d{2})?$',
);
final _yearFirst = RegExp(r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})$');
final _numeric = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})$');
final _dayMonthName = RegExp(r'^(\d{1,2})[ \-.]+([A-Za-z]{3,9})\.?[ \-.,]+(\d{2,4})$');
final _monthNameDay = RegExp(r'^([A-Za-z]{3,9})\.?[ \-.]+(\d{1,2})(?:st|nd|rd|th)?,?[ \-.]+(\d{2,4})$');

/// Looks at dates like 13/04/2026 or 04/13/2026 to tell which way round they
/// are. Returns null when every sample is ambiguous (both numbers <= 12).
DateOrder? detectDateOrder(Iterable<String> samples) {
  var dayFirst = false;
  var monthFirst = false;
  for (final raw in samples) {
    final m = _numeric.firstMatch(raw.trim().replaceFirst(_timeSuffix, ''));
    if (m == null) continue;
    final a = int.parse(m.group(1)!);
    final b = int.parse(m.group(2)!);
    if (a > 12 && b <= 12) dayFirst = true;
    if (b > 12 && a <= 12) monthFirst = true;
  }
  if (dayFirst && !monthFirst) return DateOrder.dayFirst;
  if (monthFirst && !dayFirst) return DateOrder.monthFirst;
  return null;
}

/// Parses a statement date into a calendar date (no time, no timezone).
DateTime? parseDate(String raw, DateOrder order) {
  final s = raw.trim().replaceFirst(_timeSuffix, '');
  if (s.isEmpty) return null;

  int? year;
  int? month;
  int? day;

  var m = _yearFirst.firstMatch(s);
  if (m != null) {
    year = int.parse(m.group(1)!);
    month = int.parse(m.group(2)!);
    day = int.parse(m.group(3)!);
  } else if ((m = _numeric.firstMatch(s)) != null) {
    final a = int.parse(m!.group(1)!);
    final b = int.parse(m.group(2)!);
    year = _fullYear(m.group(3)!);
    if (order == DateOrder.dayFirst) {
      day = a;
      month = b;
    } else {
      month = a;
      day = b;
    }
  } else if ((m = _dayMonthName.firstMatch(s)) != null) {
    day = int.parse(m!.group(1)!);
    month = _months[m.group(2)!.substring(0, 3).toLowerCase()];
    year = _fullYear(m.group(3)!);
  } else if ((m = _monthNameDay.firstMatch(s)) != null) {
    month = _months[m!.group(1)!.substring(0, 3).toLowerCase()];
    day = int.parse(m.group(2)!);
    year = _fullYear(m.group(3)!);
  }

  if (year == null || month == null || day == null) return null;
  final date = DateTime(year, month, day);
  // Reject impossible dates such as Feb 30 (DateTime would roll them over).
  if (date.year != year || date.month != month || date.day != day) return null;
  return date;
}

int _fullYear(String text) {
  final y = int.parse(text);
  if (text.length > 2) return y;
  return y <= 69 ? 2000 + y : 1900 + y;
}

// --------------------------------------------------------------------- rows

/// Applies the mapping to the data rows (header already removed).
ParseOutcome buildRows({
  required List<List<String>> rows,
  required ColumnMapping mapping,
  required AmountMode mode,
  required DateOrder dateOrder,
  bool invertSign = false,
}) {
  String? cell(List<String> row, int? index) =>
      (index == null || index < 0 || index >= row.length) ? null : row[index].trim();

  final result = <StatementRow>[];
  var skipped = 0;

  for (final row in rows) {
    final date = parseDate(cell(row, mapping.date) ?? '', dateOrder);

    double? amount;
    if (mode == AmountMode.single) {
      amount = parseAmount(cell(row, mapping.amount) ?? '');
      if (amount != null && invertSign) amount = -amount;
    } else {
      final debit = parseAmount(cell(row, mapping.debit) ?? '');
      final credit = parseAmount(cell(row, mapping.credit) ?? '');
      if (debit != null || credit != null) {
        amount = (credit?.abs() ?? 0) - (debit?.abs() ?? 0);
        if (invertSign) amount = -amount;
      }
    }

    if (date == null || amount == null || amount == 0) {
      skipped++;
      continue;
    }

    final description = cell(row, mapping.description) ?? '';
    final notes = cell(row, mapping.notes);

    result.add(
      StatementRow(
        date: date,
        payee: description.isEmpty ? 'Statement entry' : description,
        amount: double.parse(amount.toStringAsFixed(2)),
        notes: (notes == null || notes.isEmpty) ? null : notes,
      ),
    );
  }

  return ParseOutcome(rows: result, skipped: skipped);
}
