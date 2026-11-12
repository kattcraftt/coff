import 'package:coff_mobile/features/overview/data/overview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('runningBalance adds income and (negative) expenses day by day', () {
    final daily = [
      DailyTotal(date: DateTime(2026, 11, 1), income: 100, expenses: -30),
      DailyTotal(date: DateTime(2026, 11, 2), income: 0, expenses: -80),
      DailyTotal(date: DateTime(2026, 11, 3), income: 50, expenses: 0),
    ];
    expect(runningBalance(daily), [70.0, -10.0, 40.0]);
  });

  test('runningBalance of nothing is empty', () {
    expect(runningBalance(const []), isEmpty);
  });

  test('Overview.fromJson reads top payees and tolerates a server without them', () {
    final json = <String, dynamic>{
      'income': 10, 'expenses': -4, 'remaining': 6,
      'previousIncome': 0, 'previousExpenses': 0, 'previousRemaining': 0,
      'pendingReceipts': 0, 'daily': <dynamic>[], 'categories': <dynamic>[],
      'topPayees': [
        {'payee': 'Jollibee', 'amount': 4},
      ],
    };
    expect(Overview.fromJson(json).topPayees.single.payee, 'Jollibee');

    json.remove('topPayees');
    expect(Overview.fromJson(json).topPayees, isEmpty);
  });
}
