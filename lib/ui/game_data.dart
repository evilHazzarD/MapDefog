import 'package:flutter/material.dart';
import 'package:mapdefog/app/app_scope.dart';
import 'package:mapdefog/data/models.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/domain/caches.dart';
import 'package:mapdefog/domain/progress.dart' as prog;
import 'package:mapdefog/domain/quests.dart';
import 'package:mapdefog/domain/rarity.dart';
import 'package:mapdefog/domain/relics.dart';
import 'package:mapdefog/geo/grid.dart';
import 'package:mapdefog/l10n/game_text.dart';
import 'package:mapdefog/util/days.dart';

/// Everything stored plus what follows from it; rebuilt when any input changes.
@immutable
class GameData {
  const GameData({
    required this.settings,
    required this.days,
    required this.finds,
    required this.ledger,
    required this.walks,
    required this.cells,
    required this.areaM2,
    required this.sectors,
    required this.now,
  });

  final Settings settings;
  final List<DayRow> days;
  final List<FindRow> finds;
  final List<EntryRow> ledger;
  final List<WalkRow> walks;
  final int cells;
  final double areaM2;
  final (List<int> keys, List<int> counts) sectors;
  final int now;

  int get today => epochDay(DateTime.fromMillisecondsSinceEpoch(now));

  int get week => Caches.week(today);

  DayRow get todayRow {
    for (var i = days.length - 1; i >= 0; i--) {
      if (days[i].day == today) return days[i];
    }
    return DayRow(day: today);
  }

  int get coins => prog.Wallet.coins(finds, ledger);

  int get xp => prog.Wallet.xp(cells, finds, ledger);

  int get level => prog.Levels.level(xp);

  prog.Streak get streak => prog.Streaks.of(days, settings.shielded, today);

  Set<String> get relics => {
    for (final f in finds)
      if (f.relic.isNotEmpty) f.relic,
  };

  Set<String> get claimed => {for (final e in ledger) e.ref};

  Set<String> get opened => {
    for (final f in finds)
      if (f.key.startsWith('c:$week:')) f.key,
  };

  int _levelBefore(int day) {
    // Start of that calendar day in local time.
    final utc = dateOfEpochDay(day);
    final start = DateTime(utc.year, utc.month, utc.day).millisecondsSinceEpoch;
    final later =
        days.where((d) => d.day >= day).fold<int>(0, (a, d) => a + d.cells) +
        finds.where((f) => f.at >= start).fold<int>(0, (a, f) => a + f.xp) +
        ledger.where((e) => e.at >= start).fold<int>(0, (a, e) => a + e.xp);
    return prog.Levels.level(xp - later);
  }

  List<Quest> get quests => Quests.daily(today, _levelBefore(today));

  Quest get weekly => Quests.weekly(week, _levelBefore(today - (today + 3).floorMod(7)));

  int questProgress(Quest q) {
    if (q.ref.startsWith('w:')) {
      return Quests.progress(q, days.where((d) => Caches.week(d.day) == week).toList());
    }
    return Quests.progress(q, [todayRow]);
  }

  bool done(Quest q) => questProgress(q) >= q.target;

  bool claimable(Quest q) => done(q) && !claimed.contains(q.ref);

  int get toClaim => [...quests, weekly].where(claimable).length;

  double share(int sector) {
    final i = sectors.$1.indexOf(sector);
    if (i < 0) return 0;
    return sectors.$2[i] / Grid.sectorCells;
  }

  prog.Facts get facts {
    final sectorKeys = sectors.$1;
    final sectorCounts = sectors.$2;
    return prog.Facts(
      areaKm2: areaM2 / 1000000,
      km: days.fold<double>(0, (a, d) => a + d.meters) / 1000,
      cells: cells,
      caches: finds.length,
      rare: finds.where((f) => f.rarity >= Rarity.rare.index).length,
      epic: finds.where((f) => f.rarity >= Rarity.epic.index).length,
      legendary: finds.where((f) => f.rarity == Rarity.legendary.index).length,
      relics: relics.length,
      sets: Relics.completeSets(relics).length,
      sectors: sectorKeys.length,
      charted: sectorCounts.where((c) => c / Grid.sectorCells >= Sectors.charted).length,
      half: sectorCounts.where((c) => c / Grid.sectorCells >= 0.5).length,
      bestStreak: streak.best,
      beacons: days.where((d) => d.beacon).length,
      quests: ledger.where((e) => e.ref.startsWith('q:') || e.ref.startsWith('w:')).length,
      weeklies: ledger.where((e) => e.ref.startsWith('w:')).length,
      activeDays: days.where(prog.Streaks.active).length,
      bestDayCells: days.fold<int>(0, (best, d) => d.cells > best ? d.cells : best),
      bestDayKm: (days.fold<double>(0, (best, d) => d.meters > best ? d.meters : best)) / 1000,
      night: days.fold<int>(0, (a, d) => a + d.night),
      dawn: days.fold<int>(0, (a, d) => a + d.dawn),
      level: level,
      walks: walks.where((w) => w.meters >= 300).length,
      gold:
          finds.fold<int>(0, (a, f) => a + f.coins) +
          ledger.fold<int>(0, (a, e) => a + (e.coins > 0 ? e.coins : 0)),
      styles: settings.owned.length,
    );
  }

  List<prog.Badge> get badges => prog.Badges.unlocked(facts);
}

/// Rebuilds [GameData] when database streams, fog, or settings change.
class GameDataBuilder extends StatelessWidget {
  const GameDataBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, GameData data) builder;

  @override
  Widget build(BuildContext context) {
    final container = AppScope.of(context);
    return StreamBuilder<List<DayRow>>(
      stream: container.db.observeDays(),
      builder: (context, daysSnap) {
        return StreamBuilder<List<FindRow>>(
          stream: container.db.observeFinds(),
          builder: (context, findsSnap) {
            return StreamBuilder<List<EntryRow>>(
              stream: container.db.observeLedger(),
              builder: (context, ledgerSnap) {
                return StreamBuilder<List<WalkRow>>(
                  stream: container.db.observeWalks(),
                  builder: (context, walksSnap) {
                    return ListenableBuilder(
                      listenable: container.dataListenable,
                      builder: (context, _) {
                        final data = GameData(
                          settings: container.settings.now(),
                          days: daysSnap.data ?? const [],
                          finds: findsSnap.data ?? const [],
                          ledger: ledgerSnap.data ?? const [],
                          walks: walksSnap.data ?? const [],
                          cells: container.fog.size,
                          areaM2: container.fog.areaM2,
                          sectors: container.fog.sectors(),
                          now: DateTime.now().millisecondsSinceEpoch,
                        );
                        return builder(context, data);
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
