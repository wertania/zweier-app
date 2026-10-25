import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/labels.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

Future<void> showDestinationEditor(BuildContext context, {Destination? destination}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<AppState>(),
      child: _DestinationEditor(destination: destination),
    ),
  );
}

class _DestinationEditor extends StatefulWidget {
  const _DestinationEditor({this.destination});
  final Destination? destination;
  @override
  State<_DestinationEditor> createState() => _DestinationEditorState();
}

class _DestinationEditorState extends State<_DestinationEditor> {
  late final Destination _draft = widget.destination == null
      ? Destination(name: '')
      : Destination.fromJson({'id': widget.destination!.id, ...widget.destination!.toJson()});
  late final _name = TextEditingController(text: _draft.name);
  late final _country = TextEditingController(text: _draft.country ?? '');
  late final _desc = TextEditingController(text: _draft.description ?? '');
  bool _busy = false;

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    _draft
      ..name = _name.text.trim()
      ..country = _country.text.trim().isEmpty ? null : _country.text.trim()
      ..description = _desc.text.trim().isEmpty ? null : _desc.text.trim();
    setState(() => _busy = true);
    try {
      await context.read<AppState>().saveDestination(_draft);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
      setState(() => _busy = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.plannedFor ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _draft.plannedFor = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.destination == null ? context.l10n.newDestination : context.l10n.editDestination,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            EmojiPickerRow(
              emojis: destinationEmojis,
              selected: _draft.emoji,
              onSelected: (e) => setState(() => _draft.emoji = e),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _name,
              autofocus: widget.destination == null,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: context.l10n.placeHint),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _country,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: context.l10n.countryHint),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _desc,
              maxLines: 3,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: context.l10n.whyHint),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Text('📅', style: TextStyle(fontSize: 24)),
              title: Text(_draft.plannedFor == null
                  ? context.l10n.noDateYet
                  : DateFormat.yMMMMd(context.localeTag).format(_draft.plannedFor!)),
              trailing: _draft.plannedFor == null
                  ? TextButton(onPressed: _pickDate, child: Text(context.l10n.setDate))
                  : IconButton(
                      onPressed: () => setState(() => _draft.plannedFor = null),
                      icon: const Icon(Icons.close_rounded)),
              onTap: _pickDate,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _draft.visited,
              onChanged: (v) => setState(() => _draft.visited = v),
              title: Text(context.l10n.beenThere, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _busy ? null : _save, child: Text(context.l10n.save)),
          ],
        ),
      ),
    );
  }
}
