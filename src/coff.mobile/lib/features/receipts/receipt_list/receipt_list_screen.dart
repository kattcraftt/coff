import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../data/receipt.dart';
import '../data/receipts_repository.dart';
import '../widgets/receipt_image.dart';

class ReceiptListScreen extends ConsumerWidget {
  const ReceiptListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipts = ref.watch(receiptListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Receipts')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(receiptListProvider.future),
        child: receipts.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('$error', textAlign: TextAlign.center),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(48),
                    child: Text(
                      'No receipts yet.\nTap "Scan" to add your first one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _ReceiptTile(receipt: items[index]),
            );
          },
        ),
      ),
    );
  }
}

class _ReceiptTile extends StatelessWidget {
  const _ReceiptTile({required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    final pending = receipt.status == ReceiptStatus.pending;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: pending ? AppColors.mint : AppColors.incomeBg,
          child: Icon(
            pending ? Icons.hourglass_top : Icons.check,
            size: 20,
            color: pending ? AppColors.primary : AppColors.income,
          ),
        ),
        title: Text(
          receipt.merchant ?? 'Unknown merchant',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(formatDate(receipt.date)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatMoney(receipt.total, receipt.currency),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (pending)
              const Text(
                'Needs review',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
          ],
        ),
        // Pending receipts reopen the review form; confirmed ones show the photo.
        onTap: pending
            ? () => context.push('/review', extra: receipt)
            : () => showReceiptImage(context, receipt.id),
      ),
    );
  }
}
