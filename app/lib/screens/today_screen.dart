import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/labels.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'idea_editor_sheet.dart';

/// "What shall we do today?" – suggestions based on weather and available time.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});
  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late DateTime _day = _defaultDay();
  IdeaDuration _maxDuration = IdeaDuration.fullDay;
  Weather? _weather; // null = use the forecast
  Category? _category; // null = no preference
  DayTime _dayTime = DateTime.now().hour >= 17 ? DayTime.evening : DayTime.day;
  bool _busy = false;
  SuggestionResult? _result;

  /// On Fridays we already look at the weekend.
  static DateTime _defaultDay() {
    final now = DateTime.now();
    return now.weekday == DateTime.friday ? now.add(const Duration(days: 1)) : now;
  }

  String get _greeting {
    final h = DateTime.now().hour;
    final wd = DateFormat.EEEE(context.localeTag).format(DateTime.now());
    if (h < 11) return context.l10n.greetingMorning;
    if (h < 17) return context.l10n.greetingDay(wd);
    return context.l10n.greetingEvening;
  }

  Future<Position?> _position() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return null;
      return await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(accuracy: LocationAccuracy.low));
    } catch (_) {
      return null;
    }
  }

  Future<void> _suggest() async {
    final state = context.read<AppState>();
    setState(() => _busy = true);
    try {
      final pos = _weather == null ? await _position() : null;
      final res = await state.api.suggestions(
        weather: _weather,
        maxDuration: _maxDuration,
        timeOfDay: _dayTime,
        category: _category,
        latitude: pos?.latitude,
        longitude: pos?.longitude,
        date: _day,
      );
      setState(() => _result = res);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  List<DateTime> get _dayOptions {
    final now = DateTime.now();
    final days = <DateTime>[now];
    for (var i = 1; i <= 7 && days.length < 4; i++) {
      final d = now.add(Duration(days: i));
      if (i == 1 || d.weekday >= DateTime.saturday) days.add(d);
    }
    return days;
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(d, now)) return context.l10n.today;
    if (DateUtils.isSameDay(d, now.add(const Duration(days: 1)))) {
      return context.l10n.tomorrowWeekday(DateFormat.E(context.localeTag).format(d));
    }
    return DateFormat.EEEE(context.localeTag).format(d);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(_greeting, style: const TextStyle(color: ZColors.plumSoft, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(context.l10n.whatShallWeDo, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 18),
          _HeroCard(busy: _busy, onTap: _suggest, ideaCount: state.ideas.where((i) => !i.done).length),
          SectionLabel(context.l10n.whenLabel),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final d in _dayOptions)
              ChoiceChip(
                label: Text(_dayLabel(d)),
                selected: DateUtils.isSameDay(d, _day),
                onSelected: (_) => setState(() => _day = d),
              ),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in [DayTime.day, DayTime.evening])
              ChoiceChip(
                label: Text('${t.emoji} ${t.label(context)}'),
                selected: _dayTime == t,
                onSelected: (_) => setState(() => _dayTime = t),
              ),
          ]),
          SectionLabel(context.l10n.timeLabel),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final d in IdeaDuration.values)
              ChoiceChip(
                label: Text('${d.emoji} ${d.label(context)}'),
                selected: d == _maxDuration,
                onSelected: (_) => setState(() => _maxDuration = d),
              ),
          ]),
          SectionLabel(context.l10n.moodLabel),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in Category.values)
              ChoiceChip(
                label: Text('${c.emoji} ${c.label(context)}'),
                selected: _category == c,
                onSelected: (s) => setState(() => _category = s ? c : null),
              ),
          ]),
          SectionLabel(context.l10n.weatherLabel),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ChoiceChip(
              label: Text(context.l10n.forecast),
              selected: _weather == null,
              onSelected: (_) => setState(() => _weather = null),
            ),
            for (final w in Weather.values.where((w) => w != Weather.any))
              ChoiceChip(
                label: Text('${w.emoji} ${w.label(context)}'),
                selected: w == _weather,
                onSelected: (_) => setState(() => _weather = w),
              ),
          ]),
          if (_result != null) ...[
            const SizedBox(height: 24),
            _ResultHeader(result: _result!),
            const SizedBox(height: 12),
            if (_result!.suggestions.isEmpty)
              EmptyState(
                emoji: '🫶',
                title: context.l10n.nothingFittingTitle,
                text: context.l10n.nothingFittingText,
              ),
            for (final (i, idea) in _result!.suggestions.indexed)
              TweenAnimationBuilder<double>(
                key: ValueKey('${idea.id}-${_result.hashCode}'),
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 350 + i * 120),
                curve: Curves.easeOutBack,
                builder: (_, v, child) => Opacity(
                  opacity: v.clamp(0, 1),
                  child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: child),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: IdeaCard(
                    idea: idea,
                    onTap: () => showIdeaEditor(context, idea: idea),
                    onToggleFavorite: () => state.toggleFavorite(idea),
                  ),
                ),
              ),
            if (_result!.suggestions.isNotEmpty)
              Center(
                child: TextButton.icon(
                  onPressed: _busy ? null : _suggest,
                  icon: const Icon(Icons.casino_outlined),
                  label: Text(context.l10n.rollAgain),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.busy, required this.onTap, required this.ideaCount});
  final bool busy;
  final VoidCallback onTap;
  final int ideaCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: ZColors.loveGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: ZColors.rose.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: busy ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.heroTitle,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.heroText(ideaCount),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.92), height: 1.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: busy
                      ? const SizedBox(
                          width: 26, height: 26, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('✨', style: TextStyle(fontSize: 30)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.result});
  final SuggestionResult result;

  @override
  Widget build(BuildContext context) {
    final f = result.forecast;
    final w = result.weather;
    final l = context.l10n;
    final text = f != null
        ? '${w.emoji}  ${l.weatherExpected(w.label(context), '${f.temperatureMin?.round() ?? '?'}', '${f.temperatureMax?.round() ?? '?'}')}'
        : w == Weather.any
            ? '🌈  ${l.anyWeather}'
            : '${w.emoji}  ${w.label(context)}';
    return Row(
      children: [
        Text(context.l10n.ourTips, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const Spacer(),
        Pill(text, color: weatherColor(w)),
      ],
    );
  }
}
