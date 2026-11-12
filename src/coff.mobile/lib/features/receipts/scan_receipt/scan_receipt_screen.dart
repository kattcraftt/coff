import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/data/data_revision.dart';
import '../../../core/network/api_exception.dart';
import '../data/receipts_repository.dart';

class ScanReceiptScreen extends ConsumerStatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen> {
  final _picker = ImagePicker();
  bool _busy = false;
  String? _error;

  Future<void> _scan(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      // Downscale on-device: faster upload, and under the AI's 5 MB image limit.
      maxWidth: 2400,
      maxHeight: 2400,
      imageQuality: 85,
    );
    if (picked == null) return; // cancelled

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final receipt = await ref.read(receiptsRepositoryProvider).scan(picked.path);
      ref.read(dataRevisionProvider.notifier).bump();
      if (!mounted) return;
      // Replace, so Back from the review screen returns to the list.
      context.pushReplacement('/review', extra: receipt);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan receipt')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _busy
            ? const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Reading your receipt…'),
            ],
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Lay the receipt flat in good light so the whole thing is in frame.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _scan(ImageSource.camera),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Take photo'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _scan(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose from gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
