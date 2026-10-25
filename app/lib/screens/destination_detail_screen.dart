import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/labels.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'destination_editor_sheet.dart';
import 'idea_editor_sheet.dart';

/// A destination with its to-do list of things to experience there.
class DestinationDetailScreen extends StatefulWidget {
  const DestinationDetailScreen({super.key, required this.destinationId});
  final String destinationId;
  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  List<Idea>? _todos;
  int _lastSeenTodos = -1;

  Future<void> _load() async {
    try {
      final todos = await context.read<AppState>().api.ideas(destinationId: widget.destinationId);
      if (mounted) setState(() => _todos = todos);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _toggle(Idea idea) async {
    setState(() => idea.done = !idea.done);
    await context.read<AppState>().saveIdea(idea);
  }

  Future<void> _delete(Destination d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteDestinationTitle(d.name)),
        content: Text(context.l10n.deleteDestinationText),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.keep)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.delete)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<AppState>().deleteDestination(d);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final d = state.destinations.where((x) => x.id == widget.destinationId).firstOrNull;
    if (d == null) return const Scaffold(body: Center(child: HeartLoader()));
    // reload the to-dos whenever the shared state changed them (add/edit/delete)
    if (_lastSeenTodos != d.todoCount * 1000 + d.doneCount) {
      _lastSeenTodos = d.todoCount * 1000 + d.doneCount;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
    final todos = _todos ?? [];
    final open = todos.where((t) => !t.done).toList();
    final done = todos.where((t) => t.done).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showIdeaEditor(context, destinationId: d.id),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.experienceFab),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: ZColors.blush,
            actions: [
              IconButton(
                  onPressed: () => showDestinationEditor(context, destination: d),
                  icon: const Icon(Icons.edit_outlined)),
              IconButton(onPressed: () => _delete(d), icon: const Icon(Icons.delete_outline_rounded)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w800, color: ZColors.plum)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ZColors.blush, ZColors.apricot],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Hero(tag: 'dest-${d.id}', child: Text(d.emoji, style: const TextStyle(fontSize: 84))),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList.list(children: [
              if (d.country != null || d.description != null)
                Text(
                  [d.country, d.description].whereType<String>().join(' · '),
                  style: const TextStyle(color: ZColors.plumSoft, height: 1.4),
                ),
              if (_todos == null)
                const Padding(padding: EdgeInsets.all(40), child: Center(child: HeartLoader())),
              if (_todos != null && todos.isEmpty)
                EmptyState(
                  emoji: '📝',
                  title: context.l10n.emptyTodosTitle,
                  text: context.l10n.emptyTodosText,
                ),
              if (open.isNotEmpty) SectionLabel(context.l10n.stillAhead),
              for (final t in open) _todoTile(t),
              if (done.isNotEmpty) SectionLabel(context.l10n.alreadyDone),
              for (final t in done) _todoTile(t),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _todoTile(Idea t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: IdeaCard(
          idea: t,
          showCheckbox: true,
          onToggleDone: () => _toggle(t),
          onTap: () => showIdeaEditor(context, idea: t),
        ),
      );
}
