import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/labels.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'destination_detail_screen.dart';
import 'destination_editor_sheet.dart';

class DestinationsScreen extends StatelessWidget {
  const DestinationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final dreams = state.destinations.where((d) => !d.visited).toList();
    final visited = state.destinations.where((d) => d.visited).toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.tripDreams)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDestinationEditor(context),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: Text(context.l10n.destinationFab),
      ),
      body: RefreshIndicator(
        color: ZColors.rose,
        onRefresh: state.refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          children: [
            if (state.destinations.isEmpty)
              EmptyState(
                emoji: '🧭',
                title: context.l10n.emptyTripsTitle,
                text: context.l10n.emptyTripsText,
              ),
            for (final d in dreams) _DestinationCard(destination: d),
            if (visited.isNotEmpty) ...[
              SectionLabel(context.l10n.alreadyExperienced),
              for (final d in visited) _DestinationCard(destination: d),
            ],
          ],
        ),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.destination});
  final Destination destination;

  @override
  Widget build(BuildContext context) {
    final d = destination;
    final progress = d.todoCount == 0 ? 0.0 : d.doneCount / d.todoCount;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => DestinationDetailScreen(destinationId: d.id!),
          )),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(tag: 'dest-${d.id}', child: EmojiBubble(d.emoji, size: 60, color: ZColors.blush)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      if (d.country?.isNotEmpty ?? false)
                        Text(d.country!, style: const TextStyle(color: ZColors.plumSoft)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, runSpacing: 4, children: [
                        if (d.plannedFor != null)
                          Pill('📅 ${DateFormat.yMMMd(context.localeTag).format(d.plannedFor!)}', color: ZColors.apricot),
                        Pill('✅ ${context.l10n.experiences(d.doneCount, d.todoCount)}'),
                      ]),
                      if (d.todoCount > 0) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: ZColors.blush,
                            color: ZColors.sage,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: ZColors.plumSoft),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
