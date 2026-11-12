import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation + the always-available "Add" button
/// (scan a receipt, or enter a transaction by hand).
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined),
              title: const Text('Scan a receipt'),
              subtitle: const Text('Take a photo and let AI read it'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/scan');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Add manually'),
              subtitle: const Text('Type in an expense or income'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/transaction');
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Import a statement'),
              subtitle: const Text('Bring in a CSV from your bank'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/import');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_vert),
            selectedIcon: Icon(Icons.swap_vert_circle),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Receipts',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
