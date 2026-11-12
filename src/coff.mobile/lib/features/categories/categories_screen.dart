import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/data_revision.dart';
import '../../core/data/shared_data.dart';
import '../../core/widgets/named_items_screen.dart';
import 'data/categories_repository.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(categoriesRepositoryProvider);
    final revision = ref.read(dataRevisionProvider.notifier);

    return NamedItemsScreen(
      title: 'Categories',
      itemName: 'category',
      items: ref.watch(categoryOptionsProvider),
      onRefresh: () => ref.refresh(categoryOptionsProvider.future),
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
