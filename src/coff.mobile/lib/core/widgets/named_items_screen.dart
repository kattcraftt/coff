import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/named_item.dart';
import '../network/api_exception.dart';
import 'name_dialog.dart';
import '../theme/app_colors.dart';

/// List + add + rename for things that only have a name (accounts, categories).
/// The owning feature supplies the data and the API calls.
class NamedItemsScreen extends StatelessWidget {
  const NamedItemsScreen({
    required this.title,
    required this.itemName,
    required this.items,
    required this.onRefresh,
    required this.onCreate,
    required this.onRename,
    this.icon = Icons.label_outline,
    super.key,
  });

  final String title;

  /// Singular, lower-case, used in labels ("account").
  final String itemName;
  final AsyncValue<List<NamedItem>> items;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String name) onCreate;
  final Future<void> Function(String id, String name) onRename;
  final IconData icon;

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _add(BuildContext context) async {
    final name = await showNameDialog(context, title: 'New $itemName');
    if (name == null || !context.mounted) return;
    await _run(context, () => onCreate(name));
  }

  Future<void> _rename(BuildContext context, NamedItem item) async {
    final name = await showNameDialog(
      context,
      title: 'Rename $itemName',
      initial: item.name,
    );
    if (name == null || name == item.name || !context.mounted) return;
    await _run(context, () => onRename(item.id, name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        icon: const Icon(Icons.add),
        label: Text('Add $itemName'),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: items.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('$error', textAlign: TextAlign.center),
              ),
            ],
          ),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(48),
                    child: Text(
                      'No ${title.toLowerCase()} yet.\nTap "Add $itemName" to create one.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = list[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.mint,
                      child: Icon(icon, size: 20, color: AppColors.primary),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: IconButton(
                      tooltip: 'Rename',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _rename(context, item),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
