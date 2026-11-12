class DailyTotal {
  const DailyTotal({
    required this.date,
    required this.income,
    required this.expenses,
  });

  final DateTime date;
  final double income;

  /// Negative, as stored on transactions.
  final double expenses;

  factory DailyTotal.fromJson(Map<String, dynamic> json) => DailyTotal(
    date: DateTime.parse(json['date'] as String),
    income: (json['income'] as num).toDouble(),
    expenses: (json['expenses'] as num).toDouble(),
  );
}

class CategoryTotal {
  const CategoryTotal({required this.name, required this.amount});

  final String name;
  final double amount;

  factory CategoryTotal.fromJson(Map<String, dynamic> json) => CategoryTotal(
    name: json['name'] as String,
    amount: (json['amount'] as num).toDouble(),
  );
}

class PayeeTotal {
  const PayeeTotal({required this.payee, required this.amount});

  final String payee;
  final double amount;

  factory PayeeTotal.fromJson(Map<String, dynamic> json) => PayeeTotal(
    payee: json['payee'] as String,
    amount: (json['amount'] as num).toDouble(),
  );
}

/// Cumulative net (income + expenses) at the end of each day, starting from zero.
List<double> runningBalance(List<DailyTotal> daily) {
  var total = 0.0;
  return [
    for (final d in daily) total += d.income + d.expenses,
  ];
}

class Overview {
  const Overview({
    required this.income,
    required this.expenses,
    required this.remaining,
    required this.previousIncome,
    required this.previousExpenses,
    required this.previousRemaining,
    required this.pendingReceipts,
    required this.daily,
    required this.categories,
    required this.topPayees,
  });

  final double income;
  final double expenses; // negative
  final double remaining;
  final double previousIncome;
  final double previousExpenses; // negative
  final double previousRemaining;
  final int pendingReceipts;
  final List<DailyTotal> daily;
  final List<CategoryTotal> categories;
  final List<PayeeTotal> topPayees;

  factory Overview.fromJson(Map<String, dynamic> json) {
    double num_(String key) => (json[key] as num).toDouble();

    return Overview(
      income: num_('income'),
      expenses: num_('expenses'),
      remaining: num_('remaining'),
      previousIncome: num_('previousIncome'),
      previousExpenses: num_('previousExpenses'),
      previousRemaining: num_('previousRemaining'),
      pendingReceipts: (json['pendingReceipts'] as num).toInt(),
      daily: (json['daily'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(DailyTotal.fromJson)
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(CategoryTotal.fromJson)
          .toList(),
      topPayees: (json['topPayees'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(PayeeTotal.fromJson)
          .toList(),
    );
  }
}
