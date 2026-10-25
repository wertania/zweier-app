import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme.dart';

/// A softly pulsing heart, our loading indicator.
class HeartLoader extends StatefulWidget {
  const HeartLoader({super.key, this.size = 48});
  final double size;
  @override
  State<HeartLoader> createState() => _HeartLoaderState();
}

class _HeartLoaderState extends State<HeartLoader> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: Tween(begin: 0.85, end: 1.1)
            .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
        child: Icon(Icons.favorite_rounded, color: ZColors.rose, size: widget.size),
      );
}

/// Emoji on a soft round background.
class EmojiBubble extends StatelessWidget {
  const EmojiBubble(this.emoji, {super.key, this.size = 48, this.color = ZColors.apricot});
  final String emoji;
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size / 2.6)),
        child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
      );
}

/// Small rounded label like "☀️ Sonne".
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = ZColors.blush});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ZColors.plum)),
      );
}

Color weatherColor(Weather w) => switch (w) {
      Weather.sunny => const Color(0xFFFFE9A8),
      Weather.cloudy => const Color(0xFFE6E4EF),
      Weather.rainy => const Color(0xFFD5E6F6),
      Weather.snowy => const Color(0xFFEAF4FB),
      Weather.any => ZColors.blush,
    };

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.emoji, required this.title, required this.text});
  final String emoji;
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: ZColors.plumSoft, height: 1.4)),
          ],
        ),
      );
}

/// Card for one idea / to-do, used everywhere ideas show up.
class IdeaCard extends StatelessWidget {
  const IdeaCard({
    super.key,
    required this.idea,
    this.onTap,
    this.onToggleDone,
    this.onToggleFavorite,
    this.showCheckbox = false,
  });

  final Idea idea;
  final VoidCallback? onTap;
  final VoidCallback? onToggleDone;
  final VoidCallback? onToggleFavorite;
  final bool showCheckbox;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: idea.done ? 0.55 : 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                if (showCheckbox)
                  GestureDetector(
                    onTap: onToggleDone,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: idea.done ? ZColors.sage : Colors.transparent,
                        border: Border.all(
                            color: idea.done ? ZColors.sage : ZColors.peach, width: 2.5),
                      ),
                      child: idea.done
                          ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                          : null,
                    ),
                  ),
                EmojiBubble(idea.emoji, color: weatherColor(idea.weather)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        idea.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          decoration: idea.done ? TextDecoration.lineThrough : null,
                          decorationColor: ZColors.plumSoft,
                        ),
                      ),
                      if (idea.description?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 2),
                        Text(idea.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: ZColors.plumSoft, fontSize: 13)),
                      ],
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, runSpacing: 4, children: [
                        Pill('${idea.weather.emoji} ${idea.weather.label}',
                            color: weatherColor(idea.weather)),
                        Pill('${idea.duration.emoji} ${idea.duration.label}',
                            color: ZColors.apricot),
                      ]),
                    ],
                  ),
                ),
                if (onToggleFavorite != null)
                  IconButton(
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      idea.favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: ZColors.rose,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('Hoppla: $error'),
    backgroundColor: ZColors.roseDark,
    behavior: SnackBarBehavior.floating,
  ));
}

void showLove(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
    backgroundColor: ZColors.plum,
    behavior: SnackBarBehavior.floating,
  ));
}

/// Pick list of nice emojis for ideas and destinations.
const ideaEmojis = [
  '💡', '🧺', '🥾', '🚲', '🎬', '🍝', '☕', '🍰', '🎨', '🏊', '🛶', '🎳',
  '🧘', '📚', '🎲', '🌳', '🏛️', '🎭', '🍷', '🍦', '⛰️', '🏖️', '🎡', '💃',
  '🌅', '🔥', '🛁', '🎤', '🌻', '📸', '🍣', '🧗',
];
const destinationEmojis = [
  '🗺️', '🏝️', '🏔️', '🏙️', '🏰', '🌊', '🌲', '🗼', '⛵', '🚂', '🏕️', '🌋',
  '🇮🇹', '🇫🇷', '🇪🇸', '🇵🇹', '🇬🇷', '🇳🇱', '🇦🇹', '🇨🇭', '🇩🇰', '🇳🇴', '🇯🇵', '🇩🇪',
];

class EmojiPickerRow extends StatelessWidget {
  const EmojiPickerRow(
      {super.key, required this.emojis, required this.selected, required this.onSelected});
  final List<String> emojis;
  final String selected;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 56,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: emojis.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final e = emojis[i];
            final isSel = e == selected;
            return GestureDetector(
              onTap: () => onSelected(e),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSel ? ZColors.blush : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isSel ? ZColors.rose : ZColors.blush, width: 2),
                ),
                child: Text(e, style: const TextStyle(fontSize: 24)),
              ),
            );
          },
        ),
      );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 13, color: ZColors.plumSoft, letterSpacing: 0.6)),
      );
}
