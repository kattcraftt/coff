/// Minimal RFC 4180 reader: quoted fields, escaped quotes, CR / LF / CRLF line
/// ends, a leading BOM, and automatic delimiter detection (comma, semicolon,
/// tab or pipe). Blank lines are dropped.
List<List<String>> parseCsv(String input) {
  final text = input.startsWith('\uFEFF') ? input.substring(1) : input;
  final delimiter = detectDelimiter(text);

  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;

  void endField() {
    row.add(field.toString());
    field.clear();
  }

  void endRow() {
    endField();
    final blank = row.length == 1 && row.first.trim().isEmpty;
    if (!blank) rows.add(row);
    row = <String>[];
  }

  var i = 0;
  while (i < text.length) {
    final c = text[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(c);
      }
    } else if (c == '"' && field.isEmpty) {
      inQuotes = true;
    } else if (c == delimiter) {
      endField();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      endRow();
    } else {
      field.write(c);
    }
    i++;
  }
  if (field.isNotEmpty || row.isNotEmpty) endRow();

  return rows;
}

/// Picks the most frequent delimiter on the first non-empty line (outside quotes).
String detectDelimiter(String text) {
  const candidates = [',', ';', '\t', '|'];
  final counts = {for (final c in candidates) c: 0};
  var inQuotes = false;
  var seenContent = false;

  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (c == '"') {
      inQuotes = !inQuotes;
      seenContent = true;
    } else if (!inQuotes && (c == '\n' || c == '\r')) {
      if (seenContent) break;
    } else if (!inQuotes && counts.containsKey(c)) {
      counts[c] = counts[c]! + 1;
      seenContent = true;
    } else if (c.trim().isNotEmpty) {
      seenContent = true;
    }
  }

  var best = ',';
  var bestCount = 0;
  for (final c in candidates) {
    if (counts[c]! > bestCount) {
      best = c;
      bestCount = counts[c]!;
    }
  }
  return best;
}
