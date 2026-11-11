import 'package:intl/intl.dart';
import 'package:mapdefog/domain/progress.dart' show Badge;
import 'package:mapdefog/domain/quests.dart';
import 'package:mapdefog/domain/rarity.dart';
import 'package:mapdefog/l10n/app_localizations.dart';

/// Maps game objects (relics, deeds, quests, sectors…) to ARB messages.
///
/// The words live in `lib/l10n/app_*.arb`; this only picks the message and
/// its arguments. Id-keyed tables are ICU `select` messages; index-keyed ones
/// take `"i" + index`.
extension GameText on AppLocalizations {
  String rarity(Rarity r) => rarityLabel(r.name);

  String relicName(String id) => _or(relicNameById(id), id);
  String relicLore(String id) => relicLoreById(id);
  String setName(String set) => relicSetName(set);

  /// Title earned by completing [set].
  String setTitle(String set) => relicSetTitle(set);

  String rank(int index) => rankName('i${index.clamp(0, GameWords.ranks - 1)}');

  /// "Adjective Noun", with the adjective agreeing with the noun's gender.
  String sectorName(int sector) {
    final (a, n) = GameWords.sectorWords(sector, GameWords.adjectives, GameWords.nouns);
    final gender = sectorNounGender('i$n');
    return sectorNameFormat(sectorAdjective('i$a$gender'), sectorNoun('i$n'));
  }

  String badgeTitle(String id) => _or(badgeTitleById(id), id);

  /// Heading for a kind of deed in the book of deeds.
  String groupName(String group) => badgeGroupName(group);

  String badgeText(Badge b) {
    final g = b.goal.toInt();
    final first = g == 1;
    return switch (b.group) {
      'km' => badgeKm(g),
      'area' => badgeArea(_decimal(GameWords.km2(b.goal))),
      'cells' => badgeCells(g),
      'cache' => first ? badgeCacheFirst : badgeCache(g),
      'rare' => first ? badgeRareFirst : badgeRare(g),
      'epic' => first ? badgeEpicFirst : badgeEpic(g),
      'legend' => first ? badgeLegendFirst : badgeLegend(g),
      'relic' => g == 36 ? badgeRelicAll : badgeRelic(g),
      'set' => first ? badgeSetFirst : badgeSet(g),
      'sector' => first ? badgeSectorFirst : badgeSector(g),
      'charted' => first ? badgeChartedFirst : badgeCharted(g),
      'half' => first ? badgeHalfFirst : badgeHalf(g),
      'streak' => badgeStreak(g),
      'beacon' => first ? badgeBeaconFirst : badgeBeacon(g),
      'quest' => first ? badgeQuestFirst : badgeQuest(g),
      'weekly' => first ? badgeWeeklyFirst : badgeWeekly(g),
      'days' => badgeDays(g),
      'bigday' => badgeBigday(g),
      'longday' => badgeLongday(g),
      'night' => badgeNight(g),
      'dawn' => badgeDawn(g),
      'level' => badgeLevel(g),
      'walks' => first ? badgeWalksFirst : badgeWalks(g),
      'gold' => badgeGold(g),
      'style' => badgeStyle(g),
      _ => '',
    };
  }

  String styleName(String id) => fogStyleName(id);
  String styleText(String id) => fogStyleText(id);

  String quest(Quest q) => switch (q.goal) {
    Goal.cells => questCells(q.target),
    Goal.meters => questMeters(_decimal(_km(q.target))),
    Goal.caches => q.target == 1 ? questCachesFirst : questCaches(q.target),
    Goal.rare => questRare,
    Goal.beacon => questBeacon,
  };

  /// The evening nudge, rotating by [day].
  String nudge(int day, bool streak) {
    final i = 'i${day.floorMod(GameWords.nudges)}';
    return streak ? nudgeStreak(i) : nudgeFresh(i);
  }

  /// A line for the map's empty fog, rotating by [day].
  String motto(int day) => mottoLine('i${day.floorMod(GameWords.mottos)}');

  static String _or(String s, String fallback) => s.isEmpty ? fallback : s;

  static String _km(int m) => m % 1000 == 0 ? '${m ~/ 1000}' : (m / 1000).toStringAsFixed(1);

  /// Swaps '.' for the locale's decimal separator.
  String _decimal(String s) =>
      s.replaceAll('.', NumberFormat.decimalPattern(localeName).symbols.DECIMAL_SEP);
}

/// Sizes of the ARB word tables, and the language-independent maths on them.
class GameWords {
  GameWords._();

  /// Case counts of `rankName`, `sectorAdjective`, `sectorNoun`,
  /// `nudgeStreak`/`nudgeFresh` and `mottoLine` in every app_*.arb.
  static const ranks = 8;
  static const adjectives = 24;
  static const nouns = 24;
  static const nudges = 4;
  static const mottos = 7;

  /// Adjective and noun indexes for a sector: the same pair in every language.
  static (int, int) sectorWords(int sector, int adjectives, int nouns) {
    var h = _toSigned64(BigInt.from(sector) * BigInt.from(-0x61c8864680b583eb));
    h = h ^ _ushr64(h, 29);
    final u = h & 0x7fffffffffffffff;
    return (u % adjectives, (u ~/ adjectives) % nouns);
  }

  static String km2(double km2) {
    if (km2 < 0.1) {
      return km2.toStringAsFixed(2);
    }
    if (km2 < 10) {
      final s = km2.toStringAsFixed(1);
      return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
    }
    return km2.toInt().toString();
  }

  static int _toSigned64(BigInt value) {
    const bits = 64;
    final mask = (BigInt.one << bits) - BigInt.one;
    var result = value & mask;
    final signBit = BigInt.one << (bits - 1);
    if (result >= signBit) {
      result -= BigInt.one << bits;
    }
    return result.toInt();
  }

  static int _ushr64(int n, int shift) {
    const mask64 = 0xffffffffffffffff;
    final u = BigInt.from(n) & BigInt.from(mask64);
    return _toSigned64(u >> shift);
  }
}

extension MapDefogFloorMod on int {
  int floorMod(int m) {
    final r = this % m;
    return r < 0 ? r + m : r;
  }
}
