import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/receipts_repository.dart';

/// Small preview of the stored receipt photo; tap to open it full screen.
class ReceiptImageThumbnail extends ConsumerWidget {
  const ReceiptImageThumbnail({required this.receiptId, super.key});

  final String receiptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(receiptImageProvider(receiptId));

    return SizedBox(
      height: 160,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: image.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Photo unavailable',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
          data: (bytes) => InkWell(
            onTap: () => showReceiptImage(context, receiptId),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: double.infinity,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen, pinch-to-zoom view of a receipt photo.
Future<void> showReceiptImage(BuildContext context, String receiptId) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => _ReceiptImageScreen(receiptId: receiptId),
    ),
  );
}

class _ReceiptImageScreen extends ConsumerWidget {
  const _ReceiptImageScreen({required this.receiptId});

  final String receiptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(receiptImageProvider(receiptId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Receipt'),
      ),
      body: image.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('$error', style: const TextStyle(color: Colors.white)),
        ),
        data: (bytes) => InteractiveViewer(
          maxScale: 5,
          child: Center(child: Image.memory(bytes)),
        ),
      ),
    );
  }
}
