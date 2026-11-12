import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/session_controller.dart';
import '../core/data/app_transaction.dart';
import '../features/account/account_screen.dart';
import '../features/accounts/accounts_screen.dart';
import '../features/auth/login/login_screen.dart';
import '../features/auth/register/register_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/import/import_screen.dart';
import '../features/overview/overview_screen.dart';
import '../features/receipts/data/receipt.dart';
import '../features/receipts/receipt_list/receipt_list_screen.dart';
import '../features/receipts/review_receipt/review_receipt_screen.dart';
import '../features/receipts/scan_receipt/scan_receipt_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/transactions/transaction_form_screen.dart';
import '../features/transactions/transactions_screen.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run `redirect` whenever the session changes (login / logout / 401).
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (previous, next) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;

      if (session.isLoading) {
        return location == '/splash' ? null : '/splash';
      }

      final signedIn = session.value ?? false;
      final onAuthScreen = location == '/login' || location == '/register';

      if (!signedIn) {
        return onAuthScreen ? null : '/login';
      }
      if (onAuthScreen || location == '/splash') {
        return '/overview';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/overview',
                builder: (context, state) => const OverviewScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/receipts',
                builder: (context, state) => const ReceiptListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Full-screen flows that sit on top of the tab bar.
      GoRoute(
        path: '/scan',
        builder: (context, state) => const ScanReceiptScreen(),
      ),
      GoRoute(
        path: '/transaction',
        // No extra = add a new one; an AppTransaction = edit it.
        builder: (context, state) => TransactionFormScreen(
          transaction: state.extra is AppTransaction
              ? state.extra! as AppTransaction
              : null,
        ),
      ),
      GoRoute(
        path: '/import',
        builder: (context, state) => const ImportScreen(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/accounts',
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/review',
        // Needs the scanned receipt; without it (e.g. a restored session) go back.
        redirect: (context, state) => state.extra is Receipt ? null : '/receipts',
        builder: (context, state) =>
            ReviewReceiptScreen(receipt: state.extra! as Receipt),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
