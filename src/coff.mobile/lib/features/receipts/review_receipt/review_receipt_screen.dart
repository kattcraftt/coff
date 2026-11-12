import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/data/data_revision.dart';
import '../../../core/data/shared_data.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/widgets/lookup_dropdown.dart';
import '../data/receipt.dart';
import '../data/receipts_repository.dart';
import '../widgets/receipt_image.dart';

class ReviewReceiptScreen extends ConsumerStatefulWidget {
  const ReviewReceiptScreen({required this.receipt, super.key});

  final Receipt receipt;

  @override
  ConsumerState<ReviewReceiptScreen> createState() =>
      _ReviewReceiptScreenState();
}

class _ReviewReceiptScreenState extends ConsumerState<ReviewReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _payee;
  late final TextEditingController _amount;
  final _notes = TextEditingController();
  late DateTime _date;
  String? _accountId;
  String? _categoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.receipt;
    _payee = TextEditingController(text: r.merchant ?? '');
    _amount = TextEditingController(text: r.total?.toStringAsFixed(2) ?? '');
    _date = r.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _payee.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _discard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard this receipt?'),
        content: const Text('The scan and its photo will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await ref.read(receiptsRepositoryProvider).delete(widget.receipt.id);
      ref.read(dataRevisionProvider.notifier).bump();
      router.go('/receipts');
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await ref.read(receiptsRepositoryProvider).confirm(
        receiptId: widget.receipt.id,
        accountId: _accountId!,
        categoryId: _categoryId!,
        amount: double.parse(_amount.text.replaceAll(',', '')).abs(),
        payee: _payee.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        date: _date,
      );
      ref.read(dataRevisionProvider.notifier).bump();
      messenger.showSnackBar(const SnackBar(content: Text('Receipt saved')));
      router.go('/receipts');
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountOptionsProvider);
    final categories = ref.watch(categoryOptionsProvider);
    final ready = (accounts.value?.isNotEmpty ?? false) &&
        (categories.value?.isNotEmpty ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review receipt'),
        actions: [
          IconButton(
            tooltip: 'Discard',
            icon: const Icon(Icons.delete_outline),
            onPressed: _saving ? null : _discard,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ReceiptImageThumbnail(receiptId: widget.receipt.id),
              const SizedBox(height: 16),
              const Text(
                'Check what we read from the receipt and fix anything that is off.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _payee,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Merchant',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter a merchant' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amount,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Total',
                  prefixText: widget.receipt.currency == null
                      ? null
                      : '${widget.receipt.currency} ',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final value = double.tryParse((v ?? '').replaceAll(',', ''));
                  return (value == null || value == 0)
                      ? 'Enter the total amount'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(DateFormat.yMMMd().format(_date)),
                ),
              ),
              const SizedBox(height: 16),
              LookupDropdown(
                label: 'Account',
                items: accounts,
                emptyHint: 'Add an account to continue',
                onEmptyTap: () => context.push<void>('/accounts'),
                onCreate: ref.createAccountNamed,
                onSaved: (id) => _accountId = id,
              ),
              const SizedBox(height: 16),
              LookupDropdown(
                label: 'Category',
                items: categories,
                emptyHint: 'Add a category to continue',
                onEmptyTap: () => context.push<void>('/categories'),
                onCreate: ref.createCategoryNamed,
                onSaved: (id) => _categoryId = id,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notes,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: (_saving || !ready) ? null : _save,
                child: _saving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
