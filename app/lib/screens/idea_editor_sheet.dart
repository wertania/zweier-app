import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Opens the bottom sheet to create or edit an idea (or a destination to-do).
Future<void> showIdeaEditor(BuildContext context, {Idea? idea, String? destinationId}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<AppState>(),
      child: _IdeaEditor(idea: idea, destinationId: destinationId),
    ),
  );
}

class _IdeaEditor extends StatefulWidget {
  const _IdeaEditor({this.idea, this.destinationId});
  final Idea? idea;
  final String? destinationId;
  @override
  State<_IdeaEditor> createState() => _IdeaEditorState();
}

class _IdeaEditorState extends State<_IdeaEditor> {
  late final Idea _draft = widget.idea == null
      ? Idea(title: '', destinationId: widget.destinationId)
      : Idea.fromJson({'id': widget.idea!.id, ...widget.idea!.toJson()});
  late final _title = TextEditingController(text: _draft.title);
  late final _desc = TextEditingController(text: _draft.description ?? '');
  bool _busy = false;

  bool get _isTodo => _draft.destinationId != null;

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    _draft
      ..title = _title.text.trim()
      ..description = _desc.text.trim().isEmpty ? null : _desc.text.trim();
    setState(() => _busy = true);
    try {
      await context.read<AppState>().saveIdea(_draft);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
      setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wirklich löschen?'),
        content: Text('„${_draft.title}“ wird entfernt.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Behalten')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Löschen')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<AppState>().deleteIdea(_draft);
    if (mounted) Navigator.pop(context);
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
            Row(children: [
              Text(
                widget.idea == null
                    ? (_isTodo ? 'Was wollen wir dort machen?' : 'Neue Idee')
                    : 'Idee bearbeiten',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              if (widget.idea != null)
                IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline_rounded, color: ZColors.roseDark)),
            ]),
            const SizedBox(height: 12),
            EmojiPickerRow(
              emojis: ideaEmojis,
              selected: _draft.emoji,
              onSelected: (e) => setState(() => _draft.emoji = e),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _title,
              autofocus: widget.idea == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'z. B. Picknick am See'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _desc,
              maxLines: 3,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Notizen, Adresse, was mitnehmen …'),
            ),
            const SectionLabel('PASST BEI'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final w in Weather.values)
                ChoiceChip(
                  label: Text('${w.emoji} ${w.label}'),
                  selected: _draft.weather == w,
                  onSelected: (_) => setState(() => _draft.weather = w),
                ),
            ]),
            const SectionLabel('DAUER'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final d in IdeaDuration.values)
                ChoiceChip(
                  label: Text('${d.emoji} ${d.label}'),
                  selected: _draft.duration == d,
                  onSelected: (_) => setState(() => _draft.duration = d),
                ),
            ]),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _draft.favorite,
              onChanged: (v) => setState(() => _draft.favorite = v),
              title: const Text('Herzensidee ❤️', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Wird bei Vorschlägen bevorzugt'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(widget.idea == null ? 'Speichern' : 'Änderungen speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
