import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapdefog/data/models.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/ui/components/components.dart';
import 'package:mapdefog/ui/game_data.dart';
import 'package:mapdefog/ui/journal/walk_route.dart';
import 'package:mapdefog/ui/texts.dart';
import 'package:mapdefog/ui/theme/theme.dart';

List<WalkRow> journeys(List<WalkRow> walks) =>
    walks.where((w) => w.meters >= 50 || w.cells > 0).toList();

class WalksScreen extends StatelessWidget {
  const WalksScreen({super.key, required this.data, required this.onBack, required this.onOpen});

  final GameData data;
  final VoidCallback onBack;
  final void Function(int id) onOpen;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final imperial = data.settings.units == UnitsPref.imperial;
    final walks = journeys(data.walks);
    final monthFmt = DateFormat.yMMMM(locale.toString());
    final byMonth = <String, List<WalkRow>>{};
    for (final w in walks) {
      final title = monthFmt.format(DateTime.fromMillisecondsSinceEpoch(w.start));
      byMonth.putIfAbsent(title, () => []).add(w);
    }

    return ColoredBox(
      color: p.bg,
      child: Column(
        children: [
          TopBar(c.allWalksTitle, onBack: onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              children: [
                UCard(
                  child: Row(
                    children: [
                      _Total(walks.length.toString(), c.walks),
                      _Total(
                        formatDistance(
                          walks.fold(0.0, (a, w) => a + w.meters),
                          imperial: imperial,
                          content: c,
                          locale: locale,
                        ),
                        c.walked,
                      ),
                      _Total(
                        durationLabel(walks.fold(0, (a, w) => a + (w.end - w.start)), c),
                        c.time,
                      ),
                    ],
                  ),
                ),
                if (walks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(c.noWalksYet, style: UType.muted(p)),
                  ),
                for (final entry in byMonth.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                    child: Text(entry.key.toUpperCase(), style: UType.eyebrow(p)),
                  ),
                  for (final w in entry.value)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: UCard(
                        onTap: () => onOpen(w.id),
                        padding: const EdgeInsets.all(12),
                        child: WalkRowTile(w: w, data: data, imperial: imperial),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: UType.number(p).copyWith(fontSize: 19),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(label, style: UType.small(p), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class WalkRowTile extends StatelessWidget {
  const WalkRowTile({super.key, required this.w, required this.data, required this.imperial});

  final WalkRow w;
  final GameData data;
  final bool imperial;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final fmt = DateFormat.yMMMd(locale.toString()).add_jm();
    final when = fmt.format(DateTime.fromMillisecondsSinceEpoch(w.start));
    final meta = [
      formatDistance(w.meters, imperial: imperial, content: c, locale: locale),
      durationLabel(w.end - w.start, c),
      if (w.caches > 0) c.cachesFound(w.caches),
    ].join(' · ');
    return Row(
      children: [
        RouteSketch(walkId: w.id, size: 52),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                when,
                style: UType.body(p).copyWith(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(meta, style: UType.muted(p), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Text('+${w.cells}', style: UType.strong(p).copyWith(color: p.accent)),
      ],
    );
  }
}
