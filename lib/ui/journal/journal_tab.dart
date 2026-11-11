import 'dart:math' as math;

import 'package:flutter/material.dart' hide Badge;
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/domain/progress.dart' show Badge, Badges;
import 'package:mapdefog/domain/quests.dart';
import 'package:mapdefog/geo/grid.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/l10n/game_text.dart';
import 'package:mapdefog/ui/components/components.dart';
import 'package:mapdefog/ui/game_data.dart';
import 'package:mapdefog/ui/journal/walks_screen.dart';
import 'package:mapdefog/ui/navigation.dart';
import 'package:mapdefog/ui/texts.dart';
import 'package:mapdefog/ui/theme/theme.dart';

class JournalTab extends StatelessWidget {
  const JournalTab({super.key, required this.data, required this.go, required this.mapFocus});

  final GameData data;
  final FogGo go;
  final ValueNotifier<MapFocus?> mapFocus;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final imperial = data.settings.units == UnitsPref.imperial;
    final c = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final walks = journeys(data.walks);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(c.journalTitle, style: UType.title(p))),
                IconButton(
                  onPressed: go.openSettings,
                  icon: Icon(Icons.settings_rounded, color: p.muted),
                ),
              ],
            ),
            UCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.explored, style: UType.eyebrow(p)),
                  const SizedBox(height: 6),
                  Text(
                    formatArea(data.areaM2, imperial: imperial, content: c, locale: locale),
                    style: UType.display(p),
                  ),
                  const SizedBox(height: 2),
                  Text(c.percentOfEarth(worldShare(data.areaM2)), style: UType.muted(p)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Stat(
                        Icons.directions_walk_rounded,
                        formatDistance(
                          data.facts.km * 1000,
                          imperial: imperial,
                          content: c,
                          locale: locale,
                        ),
                        c.walked,
                        p.sage,
                      ),
                      _Stat(Icons.explore_rounded, '${data.facts.sectors}', c.sectors, p.accent),
                      _Stat(Icons.inventory_2_rounded, '${data.facts.caches}', c.caches, p.gold),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Stat(Icons.flare_rounded, '${data.facts.beacons}', c.beacons, p.rose),
                      _Stat(
                        Icons.local_fire_department_rounded,
                        '${data.streak.best}',
                        c.bestStreak,
                        p.flame,
                      ),
                      _Stat(Icons.explore_rounded, '${data.cells}', c.cells, p.sky),
                    ],
                  ),
                ],
              ),
            ),
            SectionTitle(c.activity),
            UCard(child: _Heatmap(data: data)),
            SectionTitle(c.sectors),
            if (data.sectors.$1.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(c.exploreFirstSector, style: UType.muted(p)),
              )
            else
              UCard(
                child: Column(
                  children: [
                    for (final (i, idx) in _topSectors(data).indexed)
                      Padding(
                        padding: EdgeInsets.only(bottom: i < 7 ? 8 : 0),
                        child: _SectorRow(
                          sector: data.sectors.$1[idx],
                          count: data.sectors.$2[idx],
                          name: c.sectorName(data.sectors.$1[idx]),
                          onTap: () {
                            final key = data.sectors.$1[idx];
                            mapFocus.value = MapFocus(
                              Grid.centerLat(key, Grid.sectorZ),
                              Grid.centerLon(key, Grid.sectorZ),
                              14.6,
                            );
                            go.selectTab(FogTab.map);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            SectionTitle(c.badgesCount(data.badges.length, Badges.all.length)),
            _DeedsSummary(data: data, go: go),
            if (walks.isNotEmpty) ...[
              SectionTitle(c.recentWalks),
              UCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  children: [
                    for (final (i, w) in walks.take(5).indexed) ...[
                      InkWell(
                        onTap: () => go.openWalk(w.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: WalkRowTile(w: w, data: data, imperial: imperial),
                        ),
                      ),
                      if (i < walks.take(5).length - 1) Divider(height: 1, color: p.line),
                    ],
                    InkWell(
                      onTap: go.openWalks,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        child: Text(
                          c.allWalksCount(walks.length),
                          style: UType.button(p).copyWith(color: p.accent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<int> _topSectors(GameData data) {
    final indices = List.generate(data.sectors.$1.length, (i) => i);
    indices.sort((a, b) => data.sectors.$2[b].compareTo(data.sectors.$2[a]));
    return indices.take(8).toList();
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.value, this.label, this.color);
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: UType.number(p).copyWith(fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(label, style: UType.small(p), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _SectorRow extends StatelessWidget {
  const _SectorRow({
    required this.sector,
    required this.count,
    required this.name,
    required this.onTap,
  });

  final int sector;
  final int count;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final share = count / Grid.sectorCells;
    final pct = share < 0.01 ? '<1%' : '${(share * 100).round()}%';
    return InkWell(
      onTap: onTap,
      borderRadius: U.rSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: UType.strong(p).copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  pct,
                  style: UType.strong(p)
                      .copyWith(fontSize: 14, color: share >= Sectors.charted ? p.accent : p.muted),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _SectorBar(share: share),
          ],
        ),
      ),
    );
  }
}

class _SectorBar extends StatelessWidget {
  const _SectorBar({required this.share});
  final double share;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const max = 0.5;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: CustomPaint(
          painter: _SectorBarPainter(share: share, max: max, p: p),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _SectorBarPainter extends CustomPainter {
  _SectorBarPainter({required this.share, required this.max, required this.p});
  final double share;
  final double max;
  final FogPalette p;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(size.height / 2);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, r), Paint()..color = p.accentSoft);
    final w = size.width * (share / max).clamp(0.02, 1.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, size.height), r),
      Paint()..color = p.accent,
    );
    for (final (at, _, _) in Sectors.milestones) {
      final x = size.width * at / max;
      canvas.drawCircle(
        Offset(x, size.height / 2),
        size.height * 0.28,
        Paint()..color = share >= at ? Colors.white : p.gold,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SectorBarPainter oldDelegate) => oldDelegate.share != share;
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.data});
  final GameData data;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const weeks = 16;
    final byDay = {for (final d in data.days) d.day: d.cells};
    final max = byDay.values.fold<int>(0, (a, v) => v > a ? v : a).clamp(1, 1 << 30);
    final monday = data.today - (data.today + 3).floorMod(7);
    final first = monday - (weeks - 1) * 7;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: weeks / 7,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                size: constraints.biggest,
                painter: _HeatmapPainter(
                  weeks: weeks,
                  first: first,
                  today: data.today,
                  byDay: byDay,
                  max: max,
                  p: p,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).activeDays(data.days.where((d) => d.cells > 0).length),
          style: UType.small(p),
        ),
      ],
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.weeks,
    required this.first,
    required this.today,
    required this.byDay,
    required this.max,
    required this.p,
  });

  final int weeks;
  final int first;
  final int today;
  final Map<int, int> byDay;
  final int max;
  final FogPalette p;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / weeks;
    final gap = cell * 0.16;
    for (var w = 0; w < weeks; w++) {
      for (var d = 0; d < 7; d++) {
        final day = first + w * 7 + d;
        if (day > today) continue;
        final v = byDay[day] ?? 0;
        final k = v == 0 ? 0.0 : (0.25 + 0.75 * math.sqrt(v / max));
        final tl = Offset(w * cell + gap / 2, d * cell + gap / 2);
        final sz = Size(cell - gap, cell - gap);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(tl.dx, tl.dy, sz.width, sz.height),
            Radius.circular(cell * 0.2),
          ),
          Paint()..color = v == 0 ? p.surface2 : p.accent.withValues(alpha: k),
        );
        if (day == today) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(tl.dx, tl.dy, sz.width, sz.height),
              Radius.circular(cell * 0.2),
            ),
            Paint()
              ..color = p.ink
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) => true;
}

class _DeedsSummary extends StatelessWidget {
  const _DeedsSummary({required this.data, required this.go});
  final GameData data;
  final FogGo go;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    final done = {for (final b in data.badges) b.id};
    final next = <Badge>[];
    for (final g in Badges.groups) {
      for (final b in Badges.all) {
        if (b.group == g.id && !done.contains(b.id)) {
          next.add(b);
          break;
        }
      }
    }
    next.sort((a, b) => b.share(data.facts).compareTo(a.share(data.facts)));

    return UCard(
      onTap: go.openDeeds,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.nextDeeds, style: UType.eyebrow(p)),
          for (final b in next.take(4))
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: groupColors(b.group, p).$2,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(groupIcon(b.group), color: groupColors(b.group, p).$1, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.badgeTitle(b.id), style: UType.strong(p).copyWith(fontSize: 15)),
                        Text(c.badgeText(b), style: UType.muted(p)),
                        const SizedBox(height: 5),
                        ProgressBar(
                          b.share(data.facts),
                          color: groupColors(b.group, p).$1,
                          track: groupColors(b.group, p).$2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Text(c.openDeedBook, style: UType.button(p).copyWith(color: p.accent)),
        ],
      ),
    );
  }
}
