import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bump this after anything is created, edited or deleted. Providers that show
/// server data watch it, so every tab (dashboard, transactions, receipts...)
/// refreshes itself, without features knowing about each other.
class DataRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final dataRevisionProvider =
NotifierProvider<DataRevision, int>(DataRevision.new);
