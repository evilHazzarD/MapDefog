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

class WalkScreen extends StatelessWidget {
  const WalkScreen({super.key, required this.id, required this.data, required this.onBack});

  final int id;
  final GameData data;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    WalkRow? walk;
    for (final item in data.walks) {
      if (item.id == id) {
        walk = item;
        break;
      }
    }
    final imperial = data.settings.units == UnitsPref.imperial;
    final dayFmt = DateFormat.yMMMMEEEEd(locale.toString());
    final timeFmt = DateFormat.jm(locale.toString());
    final title = walk == null
        ? c.walkTitle
        : dayFmt.format(DateTime.fromMillisecondsSinceEpoch(walk.start));

    return ColoredBox(
      color: p.bg,
      child: Column(
        children: [
          TopBar(title, onBack: onBack),
          if (walk == null)
            Expanded(
              child: Center(child: Text(c.walkNotFound, style: UType.muted(p))),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                child: Column(
                  children: [
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        color: p.surface2,
                        borderRadius: U.rMd,
                        border: Border.all(color: p.gilt.withValues(alpha: 0.55)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: RouteSketch(walkId: walk.id, size: 280),
                    ),
                    const SizedBox(height: 12),
                    UCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${timeFmt.format(DateTime.fromMillisecondsSinceEpoch(walk.start))} – ${timeFmt.format(DateTime.fromMillisecondsSinceEpoch(walk.end))}',
                            style: UType.eyebrow(p),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _Figure(
                                formatDistance(
                                  walk.meters,
                                  imperial: imperial,
                                  content: c,
                                  locale: locale,
                                ),
                                c.distance,
                              ),
                              _Figure(durationLabel(walk.end - walk.start, c), c.time),
                              _Figure(_pace(walk, imperial, c), c.pace),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _Figure('+${walk.cells}', c.cells),
                              _Figure('${walk.caches}', c.chests),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _pace(WalkRow w, bool imperial, AppLocalizations c) {
    final unit = imperial ? 1609.344 : 1000.0;
    if (w.meters < 100 || w.end <= w.start) return '—';
    final sec = ((w.end - w.start) / 1000.0 / (w.meters / unit)).round();
    return '${sec ~/ 60}:${(sec % 60).toString().padLeft(2, '0')} / ${imperial ? c.unitMiles : c.unitKilometers}';
  }
}

class _Figure extends StatelessWidget {
  const _Figure(this.value, this.label);
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
            style: UType.number(p).copyWith(fontSize: 20),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(label, style: UType.small(p), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
