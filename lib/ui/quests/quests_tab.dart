import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapdefog/app/app_scope.dart';
import 'package:mapdefog/data/models.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/domain/progress.dart';
import 'package:mapdefog/domain/quests.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/l10n/game_text.dart';
import 'package:mapdefog/ui/components/components.dart';
import 'package:mapdefog/ui/game_data.dart';
import 'package:mapdefog/ui/navigation.dart';
import 'package:mapdefog/ui/texts.dart';
import 'package:mapdefog/ui/theme/theme.dart';
import 'package:mapdefog/util/days.dart';

class QuestsTab extends StatelessWidget {
  const QuestsTab({super.key, required this.data, required this.go, required this.mapFocus});

  final GameData data;
  final FogGo go;
  final ValueNotifier<MapFocus?> mapFocus;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final imperial = data.settings.units == UnitsPref.imperial;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final left = tomorrow.difference(now);
    final c = AppLocalizations.of(context);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.questsTitle, style: UType.title(p)),
            const SizedBox(height: 4),
            Text(c.resetsIn(left.inHours, left.inMinutes % 60), style: UType.sub(p)),
            _StreakCard(data: data),
            SectionTitle(c.today),
            for (final q in data.quests)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _QuestCard(
                  q: q,
                  data: data,
                  imperial: imperial,
                  content: c,
                  onShow: q.goal == Goal.beacon && data.settings.beacon.day == data.today
                      ? () {
                          final b = data.settings.beacon;
                          mapFocus.value = MapFocus(b.lat, b.lon, 16);
                          go.selectTab(FogTab.map);
                        }
                      : null,
                ),
              ),
            SectionTitle(c.thisWeek),
            _QuestCard(q: data.weekly, data: data, imperial: imperial, content: c, weekly: true),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(c.weeklyRefill, style: UType.muted(p)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.data});
  final GameData data;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    final st = data.streak;
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: UCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: st.todayDone ? p.flameSoft : p.surface2,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    size: 32,
                    color: st.current > 0 ? p.flame : p.faint,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.dayStreak(st.current), style: UType.title(p).copyWith(fontSize: 22)),
                      Text(
                        st.todayDone ? c.streakSafe : c.exploreToSave(Streaks.cells),
                        style: UType.muted(p),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 6; i >= 0; i--)
                  _DayDot(day: data.today - i, data: data, today: i == 0),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.shield_rounded, size: 16, color: p.sky),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(c.shieldsBest(data.settings.shields, st.best), style: UType.muted(p)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.day, required this.data, required this.today});
  final int day;
  final GameData data;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    DayRow? row;
    for (final d in data.days) {
      if (d.day == day) {
        row = d;
        break;
      }
    }
    final on = Streaks.active(row);
    final shielded = data.settings.shielded.contains(day);
    final weekday = DateFormat.E(Localizations.localeOf(context).toString())
        .format(dateOfEpochDay(day));
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: on ? p.flame : (shielded ? p.skySoft : p.surface2),
            shape: BoxShape.circle,
            border: today ? Border.all(color: p.flame.withValues(alpha: 0.5), width: 2) : null,
          ),
          child: on
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : shielded
              ? Icon(Icons.shield_rounded, color: p.sky, size: 16)
              : null,
        ),
        const SizedBox(height: 4),
        Text(weekday.characters.first.toUpperCase(), style: UType.small(p)),
      ],
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({
    required this.q,
    required this.data,
    required this.imperial,
    required this.content,
    this.weekly = false,
    this.onShow,
  });

  final Quest q;
  final GameData data;
  final bool imperial;
  final AppLocalizations content;
  final bool weekly;
  final VoidCallback? onShow;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final progress = data.questProgress(q);
    final done = progress >= q.target;
    final claimed = data.claimed.contains(q.ref);
    final (icon, color, soft) = switch (q.goal) {
      Goal.cells => (Icons.travel_explore_rounded, p.accent, p.accentSoft),
      Goal.meters => (Icons.directions_walk_rounded, p.sage, p.sageSoft),
      Goal.caches => (Icons.inventory_2_rounded, p.gold, p.goldSoft),
      Goal.rare => (Icons.auto_awesome_rounded, p.violet, p.violetSoft),
      Goal.beacon => (Icons.flare_rounded, p.flame, p.flameSoft),
    };

    return UCard(
      onTap: onShow,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(content.quest(q), style: UType.strong(p).copyWith(fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const CoinIcon(size: 12),
                        const SizedBox(width: 4),
                        Text('${q.coins}', style: UType.small(p).copyWith(color: p.gold)),
                        const SizedBox(width: 10),
                        Text(
                          content.xpLabel(q.xp),
                          style: UType.small(p).copyWith(color: p.accent),
                        ),
                        if (weekly) ...[
                          const SizedBox(width: 10),
                          Text(
                            content.daysLeft(7 - (data.today + 3).floorMod(7)),
                            style: UType.small(p),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (claimed)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: p.accentSoft, shape: BoxShape.circle),
                  child: Icon(Icons.check_rounded, color: p.accent, size: 20),
                )
              else if (done)
                GestureDetector(
                  onTap: () => _claim(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: p.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(content.claim, style: UType.button(p).copyWith(color: p.onAccent)),
                  ),
                ),
            ],
          ),
          if (!claimed && q.goal != Goal.beacon) ...[
            const SizedBox(height: 12),
            ProgressBar(progress / q.target, color: color, track: soft),
            const SizedBox(height: 4),
            Text(
              q.goal == Goal.meters
                  ? '${formatDistance(progress.toDouble().clamp(0, q.target.toDouble()), imperial: imperial, content: content, locale: Localizations.localeOf(context))} / ${formatDistance(q.target.toDouble(), imperial: imperial, content: content, locale: Localizations.localeOf(context))}'
                  : '${progress.clamp(0, q.target)} / ${q.target}',
              style: UType.small(p),
            ),
          ] else if (!claimed && onShow != null) ...[
            const SizedBox(height: 8),
            Text(content.showOnMap, style: UType.small(p).copyWith(color: p.flame)),
          ],
        ],
      ),
    );
  }

  Future<void> _claim(BuildContext context) async {
    final db = AppScope.of(context).db;
    await db.grant(
      EntryRow(ref: q.ref, at: DateTime.now().millisecondsSinceEpoch, coins: q.coins, xp: q.xp),
    );
  }
}
