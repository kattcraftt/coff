import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/named_item.dart';
import '../network/api_exception.dart';
import 'name_dialog.dart';

const _createValue = '__create__';

/// Account / category picker used inside a Form. When the user has none yet it shows a
/// button to create one; with [onCreate] the list also ends with "Create new ...".
class LookupDropdown extends StatefulWidget {
  const LookupDropdown({
    required this.label,
    required this.items,
    required this.emptyHint,
    required this.onEmptyTap,
    required this.onSaved,
    this.initialId,
    this.onCreate,
    this.noun,
    super.key,
  });

  final String label;
  final AsyncValue<List<NamedItem>> items;
  final String emptyHint;
  final VoidCallback onEmptyTap;
  final void Function(String id) onSaved;
  final String? initialId;

  /// Creates the item on the server and returns its id; the new item gets selected.
  final Future<String?> Function(String name)? onCreate;

  /// Word used in "Create new ..." (defaults to the lower-cased label).
  final String? noun;

  @override
  State<LookupDropdown> createState() => _LookupDropdownState();
}

class _LookupDropdownState extends State<LookupDropdown> {
  String? _selected;

  /// Id of an item that was just created but is not in the refreshed list yet.
  String? _pendingId;

  /// Bumped to rebuild the field, e.g. to undo a "Create new" selection.
  int _nonce = 0;

  String get _noun => widget.noun ?? widget.label.toLowerCase();

  @override
  void initState() {
    super.initState();
    _selected = widget.initialId;
  }

  Future<void> _create() async {
    final create = widget.onCreate;
    if (create == null) return;
    final messenger = ScaffoldMessenger.of(context);

    final name = await showNameDialog(
      context,
      title: 'New $_noun',
    );
    if (!mounted) return;
    if (name == null) {
      setState(() => _nonce++);
      return;
    }

    try {
      final id = await create(name);
      if (mounted) {
        setState(() {
          _pendingId = id;
          _nonce++;
        });
      }
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      if (mounted) setState(() => _nonce++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.items.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text(
        '${widget.label}: $error',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      data: (list) {
        if (list.isEmpty) {
          return Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: widget.onCreate != null ? _create : widget.onEmptyTap,
              icon: const Icon(Icons.add),
              label: Text(widget.emptyHint),
            ),
          );
        }

        final pending = _pendingId;
        if (pending != null && list.any((i) => i.id == pending)) {
          _selected = pending;
          _pendingId = null;
        }
        final selected =
        list.any((i) => i.id == _selected) ? _selected : list.first.id;

        return DropdownButtonFormField<String>(
          key: ValueKey('${widget.label}-${list.length}-$selected-$_nonce'),
          initialValue: selected,
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final item in list)
              DropdownMenuItem(value: item.id, child: Text(item.name)),
            if (widget.onCreate != null)
              DropdownMenuItem(
                value: _createValue,
                child: Row(
                  children: [
                    const Icon(Icons.add, size: 18),
                    const SizedBox(width: 8),
                    Text('Create new $_noun'),
                  ],
                ),
              ),
          ],
          onChanged: (value) {
            if (value == _createValue) {
              _create();
            } else if (value != null) {
              _selected = value;
            }
          },
          onSaved: (id) =>
              widget.onSaved(id == null || id == _createValue ? selected! : id),
        );
      },
    );
  }
}
