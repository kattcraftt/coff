import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/data_revision.dart';
import '../../core/data/shared_data.dart';
import '../../core/widgets/named_items_screen.dart';
import 'data/accounts_repository.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(accountsRepositoryProvider);
    final revision = ref.read(dataRevisionProvider.notifier);

    return NamedItemsScreen(
      title: 'Accounts',
      itemName: 'account',
      icon: Icons.account_balance_wallet_outlined,
      items: ref.watch(accountOptionsProvider),
      onRefresh: () => ref.refresh(accountOptionsProvider.future),
      onCreate: (name) async {
        await repository.create(name);
        revision.bump();
      },
      onRename: (id, name) async {
        await repository.rename(id, name);
        revision.bump();
      },
    );
  }
}
