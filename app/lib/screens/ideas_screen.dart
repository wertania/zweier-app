import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'idea_editor_sheet.dart';

/// All leisure ideas for free days, filterable by weather and duration.
class IdeasScreen extends StatefulWidget {
  const IdeasScreen({super.key});
  @override
  State<IdeasScreen> createState() => _IdeasScreenState();
}

class _IdeasScreenState extends State<IdeasScreen> {
  Weather? _weather;
  IdeaDuration? _duration;
  bool _showDone = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final filtered = state.ideas.where((i) {
      if (!_showDone && i.done) return false;
      if (_weather != null && i.weather != _weather && i.weather != Weather.any) return false;
      if (_duration != null && i.duration != _duration) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unsere Ideen'),
        actions: [
          IconButton(
            tooltip: 'Erledigte zeigen',
            onPressed: () => setState(() => _showDone = !_showDone),
            icon: Icon(_showDone ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showIdeaEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Idee'),
      ),
      body: RefreshIndicator(
        color: ZColors.rose,
        onRefresh: state.refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          children: [
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final w in Weather.values.where((w) => w != Weather.any))
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('${w.emoji} ${w.label}'),
                        selected: _weather == w,
                        onSelected: (s) => setState(() => _weather = s ? w : null),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final d in IdeaDuration.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('${d.emoji} ${d.label}'),
                        selected: _duration == d,
                        onSelected: (s) => setState(() => _duration = s ? d : null),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (filtered.isEmpty)
              EmptyState(
                emoji: state.ideas.isEmpty ? '🌱' : '🔍',
                title: state.ideas.isEmpty ? 'Euer Ideen-Garten ist noch leer' : 'Nichts gefunden',
                text: state.ideas.isEmpty
                    ? 'Sammelt hier alles, was ihr gern zusammen machen wollt – vom Kinoabend bis zur Wanderung.'
                    : 'Probiert einen anderen Filter.',
              ),
            for (final idea in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Dismissible(
                  key: ValueKey(idea.id),
                  direction: DismissDirection.startToEnd,
                  confirmDismiss: (_) async {
                    await state.toggleDone(idea);
                    if (context.mounted && idea.done) showLove(context, 'Schön war’s! 💕');
                    return false;
                  },
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 24),
                    decoration: BoxDecoration(color: ZColors.sage, borderRadius: BorderRadius.circular(22)),
                    child: Icon(idea.done ? Icons.undo_rounded : Icons.check_rounded, color: Colors.white),
                  ),
                  child: IdeaCard(
                    idea: idea,
                    onTap: () => showIdeaEditor(context, idea: idea),
                    onToggleFavorite: () => state.toggleFavorite(idea),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
