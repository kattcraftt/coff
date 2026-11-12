import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/auth/current_user.dart';
import '../../core/data/shared_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/period_picker.dart';
import '../../core/widgets/profile_menu_button.dart';
import '../../core/widgets/coff_logo.dart';
import 'data/overview.dart';
import 'data/overview_repository.dart';
import 'widgets/categories_card.dart';
import 'widgets/summary_card.dart';
import 'widgets/top_payees_card.dart';
import 'widgets/transactions_chart_card.dart';

/// Mobile take on the web dashboard: mint header with filters, summary cards
/// overlapping it, then the transactions chart and the category breakdown.
class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(overviewProvider);
    final filter = ref.watch(overviewFilterProvider);

    return RefreshIndicator(
      onRefresh: () {
        return ref.refresh(overviewProvider.future);
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(filter: filter),
          // Pull the content up so the cards overlap the mint header.
          Transform.translate(
            offset: const Offset(0, -48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: overview.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('$error', textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => ref.invalidate(overviewProvider),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (data) => _Body(data: data, filter: filter),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.filter});

  final OverviewFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final accounts = ref.watch(accountOptionsProvider).value ?? const [];
    final theme = Theme.of(context);

    final selectedAccount = accounts
        .where((a) => a.id == filter.accountId)
        .map((a) => a.name)
        .firstOrNull;

    return Container(
      color: AppColors.mint,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 12,
        16,
        72,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CoffLogo(height: 26),
              const Spacer(),
              const ProfileMenuButton(),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            user?.greetingName == null
                ? 'Welcome back 👋'
                : 'Welcome back, ${user!.greetingName} 👋',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'This is your financial overview',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          if (user != null && user.greetingName == null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: GestureDetector(
                onTap: () => context.push('/account'),
                child: const Text(
                  'Add your name so we can greet you properly',
                  style: TextStyle(color: AppColors.link, fontSize: 13),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PopupMenuButton<String>(
                onSelected: (id) => ref
                    .read(overviewFilterProvider.notifier)
                    .setAccount(id == _allAccounts ? null : id),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: _allAccounts, child: Text('All accounts')),
                  for (final a in accounts)
                    PopupMenuItem(value: a.id, child: Text(a.name)),
                ],
                child: _Pill(label: selectedAccount ?? 'All accounts'),
              ),
              _Pill(
                label: _rangeLabel(filter.range),
                onTap: () async {
                  final picked = await pickPeriod(context, current: filter.range);
                  if (picked != null) {
                    ref.read(overviewFilterProvider.notifier).setRange(picked);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const _allAccounts = 'all';

String _rangeLabel(DateTimeRange range) {
  final start = DateFormat('MMM dd').format(range.start);
  final end = DateFormat('MMM dd, yyyy').format(range.end);
  return '$start - $end';
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more, size: 18, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data, required this.filter});

  final Overview data;
  final OverviewFilter filter;

  @override
  Widget build(BuildContext context) {
    final period = _rangeLabel(filter.range);

    return Column(
      children: [
        if (data.pendingReceipts > 0) ...[
          _ReviewBanner(count: data.pendingReceipts),
          const SizedBox(height: 12),
        ],
        SummaryCard(
          title: 'Remaining',
          periodLabel: period,
          amount: data.remaining,
          previous: data.previousRemaining,
          icon: Icons.savings_outlined,
          iconBackground: AppColors.remainingBg,
          iconColor: AppColors.primary,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Income',
                periodLabel: 'This period',
                amount: data.income,
                previous: data.previousIncome,
                icon: Icons.trending_up,
                iconBackground: AppColors.incomeBg,
                iconColor: AppColors.income,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Expenses',
                periodLabel: 'This period',
                amount: data.expenses,
                previous: data.previousExpenses,
                icon: Icons.trending_down,
                iconBackground: AppColors.expenseBg,
                iconColor: AppColors.expense,
                higherIsBetter: false,
                compareMagnitude: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TransactionsChartCard(daily: data.daily),
        const SizedBox(height: 16),
        CategoriesCard(categories: data.categories),
        const SizedBox(height: 16),
        TopPayeesCard(payees: data.topPayees),
        const SizedBox(height: 96), // room for the scan button
      ],
    );
  }
}

/// Smart Receipts-style nudge: scanned receipts waiting for a quick check.
class _ReviewBanner extends StatelessWidget {
  const _ReviewBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
        title: Text(
          count == 1 ? '1 receipt to review' : '$count receipts to review',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Check what we read, then save'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/receipts'),
      ),
    );
  }
}
