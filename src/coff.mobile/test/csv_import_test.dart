import 'package:coff_mobile/features/import/csv_parser.dart';
import 'package:coff_mobile/features/import/statement_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseCsv', () {
    test('quoted fields, commas and escaped quotes', () {
      expect(
        parseCsv('a,b\n"x, y","he said ""hi"""\n'),
        [
          ['a', 'b'],
          ['x, y', 'he said "hi"'],
        ],
      );
    });

    test('CRLF, blank lines and no trailing newline', () {
      expect(parseCsv('a,b\r\n\r\n1,2'), [
        ['a', 'b'],
        ['1', '2'],
      ]);
    });

    test('semicolon and tab delimiters', () {
      expect(parseCsv('Date;Amount\n01/02/2026;1.234,50\n'), [
        ['Date', 'Amount'],
        ['01/02/2026', '1.234,50'],
      ]);
      expect(parseCsv('a\tb\n1\t2'), [
        ['a', 'b'],
        ['1', '2'],
      ]);
    });

    test('BOM, multi-line field, inch mark, empty fields', () {
      expect(parseCsv('\uFEFFa,b\n1,2'), [
        ['a', 'b'],
        ['1', '2'],
      ]);
      expect(parseCsv('a,b\n"line1\nline2",x\n'), [
        ['a', 'b'],
        ['line1\nline2', 'x'],
      ]);
      expect(parseCsv('a,b\n5" pipe,2\n'), [
        ['a', 'b'],
        ['5" pipe', '2'],
      ]);
      expect(parseCsv('a,b,c\n1,,3\n'), [
        ['a', 'b', 'c'],
        ['1', '', '3'],
      ]);
    });
  });

  group('parseAmount', () {
    const cases = <String, double?>{
      '1,234.50': 1234.5,
      '-12.00': -12.0,
      '(45.10)': -45.1,
      'PHP 1 200': 1200.0,
      '1.234,50': 1234.5,
      '75.00-': -75.0,
      '300.00 DR': -300.0,
      '300.00 CR': 300.0,
      '12,5': 12.5,
      '1,234': 1234.0,
      '1.234.567': 1234567.0,
      '+8.00': 8.0,
      '  42 ': 42.0,
      '': null,
      'abc': null,
      '-': null,
    };
    cases.forEach((input, expected) {
      test('"$input"', () => expect(parseAmount(input), expected));
    });

    test('dates are never amounts', () {
      for (final d in ['19 Oct 2026', '10/19/2026', '2026-10-19', '19.10.2026', '14:32']) {
        expect(parseAmount(d), isNull, reason: d);
      }
    });
  });

  group('parseDate', () {
    DateTime? p(String s, [DateOrder o = DateOrder.monthFirst]) => parseDate(s, o);

    test('year first and named months', () {
      expect(p('2026-10-19'), DateTime(2026, 10, 19));
      expect(p('2026/10/19', DateOrder.dayFirst), DateTime(2026, 10, 19));
      expect(p('19 Oct 2026'), DateTime(2026, 10, 19));
      expect(p('19-Oct-26'), DateTime(2026, 10, 19));
      expect(p('Oct 19, 2026'), DateTime(2026, 10, 19));
      expect(p('October 19th, 2026'), DateTime(2026, 10, 19));
    });

    test('day / month order matters for ambiguous dates', () {
      expect(p('03/04/2026', DateOrder.monthFirst), DateTime(2026, 3, 4));
      expect(p('03/04/2026', DateOrder.dayFirst), DateTime(2026, 4, 3));
      expect(p('19/10/2026', DateOrder.dayFirst), DateTime(2026, 10, 19));
      expect(p('10/19/2026', DateOrder.monthFirst), DateTime(2026, 10, 19));
    });

    test('time parts are ignored', () {
      expect(p('2026-10-19 14:32:11'), DateTime(2026, 10, 19));
      expect(p('10/19/2026 02:15 PM'), DateTime(2026, 10, 19));
      expect(p('2026-10-19T00:00:00Z'), DateTime(2026, 10, 19));
    });

    test('two-digit years and invalid dates', () {
      expect(p('1/2/99'), DateTime(1999, 1, 2));
      expect(p('30/02/2026', DateOrder.dayFirst), isNull);
      expect(p('13/13/2026'), isNull);
      expect(p('hello'), isNull);
      expect(p(''), isNull);
    });
  });

  group('detectDateOrder', () {
    test('uses unambiguous samples', () {
      expect(detectDateOrder(['19/10/2026', '01/02/2026']), DateOrder.dayFirst);
      expect(detectDateOrder(['10/19/2026', '01/02/2026']), DateOrder.monthFirst);
    });
    test('returns null when it cannot tell', () {
      expect(detectDateOrder(['03/04/2026', '01/02/2026']), isNull);
      expect(detectDateOrder(['2026-10-19']), isNull);
    });
  });

  group('column detection', () {
    test('recognises debit / credit headers', () {
      final g = guessMapping(['Date', 'Description', 'Debit', 'Credit', 'Balance']);
      expect(g.mode, AmountMode.debitCredit);
      expect(g.mapping.date, 0);
      expect(g.mapping.description, 1);
      expect(g.mapping.debit, 2);
      expect(g.mapping.credit, 3);
    });

    test('recognises a single signed amount', () {
      final g = guessMapping(['Posting Date', 'Details', 'Amount', 'Running Balance']);
      expect(g.mode, AmountMode.single);
      expect(g.mapping.date, 0);
      expect(g.mapping.description, 1);
      expect(g.mapping.amount, 2);
    });

    test('falls back to cell contents when names are unfamiliar', () {
      final rows = [
        ['19/10/2026', 'COFFEE SHOP', '120.50', '', '4879.50'],
        ['20/10/2026', 'SALARY', '', '25000.00', '29879.50'],
        ['21/10/2026', 'GROCERY', '800.00', '', '29079.50'],
      ];
      final g = guessMapping(['Txn Dt', 'Narr', 'Withdrawal Amt', 'Deposit Amt', 'Balance']);
      final m = fillMissingFromContent(rows, g.mapping);
      expect(m.date, 0);
      expect(m.description, 1);
      expect(m.debit, 2);
      expect(m.credit, 3);
    });

    test('works without any header', () {
      final rows = [
        ['10/19/2026', 'COFFEE SHOP', '-120.50', '5000.00'],
        ['10/20/2026', 'SALARY', '25000.00', '30000.00'],
        ['10/21/2026', 'GROCERY STORE', '-800.00', '29200.00'],
      ];
      final m = fillMissingFromContent(rows, const ColumnMapping());
      expect(m.date, 0);
      expect(m.description, 1);
      expect(m.amount, 2);
    });
  });

  group('buildRows', () {
    test('single signed amount column', () {
      final out = buildRows(
        rows: [
          ['10/19/2026', 'COFFEE', '-120.50'],
          ['10/20/2026', 'SALARY', '25,000.00'],
          ['TOTAL', '', '24,879.50'],
        ],
        mapping: const ColumnMapping(date: 0, description: 1, amount: 2),
        mode: AmountMode.single,
        dateOrder: DateOrder.monthFirst,
      );
      expect(out.rows.length, 2);
      expect(out.skipped, 1); // the TOTAL line has no date
      expect(out.rows[0].amount, -120.5);
      expect(out.rows[1].amount, 25000.0);
      expect(out.rows[0].date, DateTime(2026, 10, 19));
    });

    test('debit / credit columns become negative / positive', () {
      final out = buildRows(
        rows: [
          ['19/10/2026', 'COFFEE', '120.50', ''],
          ['20/10/2026', 'SALARY', '', '25000.00'],
        ],
        mapping: const ColumnMapping(date: 0, description: 1, debit: 2, credit: 3),
        mode: AmountMode.debitCredit,
        dateOrder: DateOrder.dayFirst,
      );
      expect(out.rows.map((r) => r.amount), [-120.5, 25000.0]);
    });

    test('flip signs, zero amounts and missing description', () {
      final out = buildRows(
        rows: [
          ['2026-10-19', '', '50.00'],
          ['2026-10-20', 'NOTHING', '0.00'],
        ],
        mapping: const ColumnMapping(date: 0, description: 1, amount: 2),
        mode: AmountMode.single,
        dateOrder: DateOrder.monthFirst,
        invertSign: true,
      );
      expect(out.rows.length, 1);
      expect(out.rows.first.amount, -50.0);
      expect(out.rows.first.payee, 'Statement entry');
      expect(out.skipped, 1);
    });
  });
}
