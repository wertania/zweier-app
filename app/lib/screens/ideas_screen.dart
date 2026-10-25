import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/labels.dart';
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
  bool _eveningOnly = false;
  Category? _category;
  bool _showDone = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final filtered = state.ideas.where((i) {
      if (!_showDone && i.done) return false;
      if (_weather != null && !i.fitsWeather(_weather!)) return false;
      if (_eveningOnly && i.timeOfDay == DayTime.day) return false;
      if (_category != null && !i.categories.contains(_category)) return false;
      if (_duration != null && i.duration != _duration) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.ourIdeas),
        actions: [
          IconButton(
            tooltip: context.l10n.showDone,
            onPressed: () => setState(() => _showDone = !_showDone),
            icon: Icon(_showDone ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showIdeaEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.ideaFab),
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
                        label: Text('${w.emoji} ${w.label(context)}'),
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
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${DayTime.evening.emoji} ${DayTime.evening.label(context)}'),
                      selected: _eveningOnly,
                      onSelected: (s) => setState(() => _eveningOnly = s),
                    ),
                  ),
                  for (final d in IdeaDuration.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('${d.emoji} ${d.label(context)}'),
                        selected: _duration == d,
                        onSelected: (s) => setState(() => _duration = s ? d : null),
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
                  for (final c in Category.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('${c.emoji} ${c.label(context)}'),
                        selected: _category == c,
                        onSelected: (s) => setState(() => _category = s ? c : null),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (filtered.isEmpty)
              EmptyState(
                emoji: state.ideas.isEmpty ? '🌱' : '🔍',
                title: state.ideas.isEmpty ? context.l10n.emptyIdeasTitle : context.l10n.nothingFound,
                text: state.ideas.isEmpty ? context.l10n.emptyIdeasText : context.l10n.tryOtherFilter,
              ),
            for (final idea in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Dismissible(
                  key: ValueKey(idea.id),
                  direction: DismissDirection.startToEnd,
                  confirmDismiss: (_) async {
                    await state.toggleDone(idea);
                    if (context.mounted && idea.done) showLove(context, context.l10n.wasLovely);
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
