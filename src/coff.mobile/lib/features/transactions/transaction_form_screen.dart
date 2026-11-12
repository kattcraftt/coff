import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/data/app_transaction.dart';
import '../../core/data/data_revision.dart';
import '../../core/data/shared_data.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/lookup_dropdown.dart';
import 'data/transactions_repository.dart';

/// Add a transaction by hand, or edit / delete an existing one.
class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({this.transaction, super.key});

  final AppTransaction? transaction;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _payee;
  late final TextEditingController _amount;
  late final TextEditingController _notes;
  late bool _isExpense;
  late DateTime _date;
  String? _accountId;
  String? _categoryId;
  bool _busy = false;

  AppTransaction? get _existing => widget.transaction;

  @override
  void initState() {
    super.initState();
    final t = _existing;
    _payee = TextEditingController(text: t?.payee ?? '');
    _amount = TextEditingController(text: t?.amount.abs().toStringAsFixed(2) ?? '');
    _notes = TextEditingController(text: t?.notes ?? '');
    _isExpense = t?.isExpense ?? true;
    _date = t?.date ?? DateTime.now();
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();

    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final repository = ref.read(transactionsRepositoryProvider);

    // Expenses are stored as negative amounts, income as positive.
    final magnitude = double.parse(_amount.text.replaceAll(',', '')).abs();
    final amount = _isExpense ? -magnitude : magnitude;
    final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();

    try {
      final existing = _existing;
      if (existing == null) {
        await repository.create(
          accountId: _accountId!,
          categoryId: _categoryId!,
          amount: amount,
          payee: _payee.text.trim(),
          date: _date,
          notes: notes,
        );
      } else {
        await repository.update(
          id: existing.id,
          accountId: _accountId!,
          categoryId: _categoryId!,
          amount: amount,
          payee: _payee.text.trim(),
          date: _date,
          notes: notes,
        );
      }
      ref.read(dataRevisionProvider.notifier).bump();
      messenger.showSnackBar(const SnackBar(content: Text('Saved')));
      router.pop();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final existing = _existing;
    if (existing == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('"${existing.payee}" will be removed. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await ref.read(transactionsRepositoryProvider).delete(existing.id);
      ref.read(dataRevisionProvider.notifier).bump();
      messenger.showSnackBar(const SnackBar(content: Text('Deleted')));
      router.pop();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      if (mounted) setState(() => _busy = false);
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
        title: Text(_existing == null ? 'Add transaction' : 'Edit transaction'),
        actions: [
          if (_existing != null)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _busy ? null : _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('Expense'),
                    icon: Icon(Icons.trending_down),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('Income'),
                    icon: Icon(Icons.trending_up),
                  ),
                ],
                selected: {_isExpense},
                onSelectionChanged: (s) => setState(() => _isExpense = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _payee,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Payee',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter a payee' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amount,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final value = double.tryParse((v ?? '').replaceAll(',', ''));
                  return (value == null || value == 0) ? 'Enter an amount' : null;
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
                initialId: _existing?.accountId,
                emptyHint: 'Add an account to continue',
                onEmptyTap: () => context.push<void>('/accounts'),
                onCreate: ref.createAccountNamed,
                onSaved: (id) => _accountId = id,
              ),
              const SizedBox(height: 16),
              LookupDropdown(
                label: 'Category',
                items: categories,
                initialId: _existing?.categoryId,
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
                onPressed: (_busy || !ready) ? null : _save,
                child: _busy
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
