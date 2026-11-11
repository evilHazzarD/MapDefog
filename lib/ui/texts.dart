import 'package:flutter/material.dart' hide Badge;
import 'package:intl/intl.dart';
import 'package:mapdefog/domain/progress.dart';
import 'package:mapdefog/domain/rarity.dart';
import 'package:mapdefog/geo/grid.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/ui/theme/theme.dart';

String formatDistance(
  double meters, {
  required bool imperial,
  required AppLocalizations content,
  Locale? locale,
}) {
  final l = locale ?? const Locale('en');
  if (imperial) {
    final miles = meters / 1609.344;
    if (miles < 0.1) {
      return '${(meters * 3.28084).round()} ${content.unitFeet}';
    }
    final fmt = miles < 10 ? NumberFormat('0.0', l.toString()) : NumberFormat('0', l.toString());
    return '${fmt.format(miles)} ${content.unitMiles}';
  }
  if (meters < 1000) {
    return '${((meters / 10).round() * 10)} ${content.unitMeters}';
  }
  final km = meters / 1000;
  final fmt = km < 10 ? NumberFormat('0.0', l.toString()) : NumberFormat('0', l.toString());
  return '${fmt.format(km)} ${content.unitKilometers}';
}

String formatArea(
  double m2, {
  required bool imperial,
  required AppLocalizations content,
  Locale? locale,
}) {
  final l = locale ?? const Locale('en');
  if (imperial) {
    final mi2 = m2 / 2589988.0;
    final fmt = NumberFormat(mi2 < 1 ? '0.00' : '0.0', l.toString());
    return '${fmt.format(mi2)} ${content.unitMilesSquared}';
  }
  if (m2 < 100000) {
    return '${NumberFormat('#,###', l.toString()).format(m2.round())} ${content.unitMetersSquared}';
  }
  final km2 = m2 / 1000000;
  final fmt = NumberFormat(km2 < 10 ? '0.00' : '0.0', l.toString());
  return '${fmt.format(km2)} ${content.unitKmSquared}';
}

(String colorName, Color color, Color soft) rarityColors(Rarity r, FogPalette p) {
  return switch (r) {
    Rarity.common => ('', p.sage, p.sageSoft),
    Rarity.rare => ('', p.sky, p.skySoft),
    Rarity.epic => ('', p.violet, p.violetSoft),
    Rarity.legendary => ('', p.gold, p.goldSoft),
  };
}

(Color color, Color soft) groupColors(String group, FogPalette p) {
  return switch (group) {
    'area' || 'sector' || 'charted' || 'half' || 'cells' => (p.accent, p.accentSoft),
    'km' || 'longday' || 'walks' || 'days' => (p.sage, p.sageSoft),
    'cache' || 'legend' || 'bigday' || 'gold' => (p.gold, p.goldSoft),
    'relic' || 'set' || 'epic' || 'style' => (p.violet, p.violetSoft),
    'streak' || 'level' => (p.flame, p.flameSoft),
    'beacon' || 'dawn' => (p.rose, p.roseSoft),
    _ => (p.sky, p.skySoft),
  };
}

(Color color, Color soft) badgeColors(Badge b, FogPalette p) => groupColors(b.group, p);

IconData relicIcon(String id) {
  return switch (id) {
    'compass' => Icons.explore_rounded,
    'boots' => Icons.hiking_rounded,
    'lantern' => Icons.lightbulb_rounded,
    'staff' => Icons.directions_walk_rounded,
    'flask' => Icons.local_drink_rounded,
    'rope' => Icons.all_inclusive_rounded,
    'torn_map' || 'city_plan' => Icons.map_rounded,
    'sea_chart' => Icons.waves_rounded,
    'star_chart' => Icons.star_rounded,
    'treasure_map' => Icons.search_rounded,
    'nowhere_map' => Icons.route_rounded,
    'watch' => Icons.timer_rounded,
    'spyglass' => Icons.travel_explore_rounded,
    'music_box' => Icons.music_note_rounded,
    'hourglass' => Icons.hourglass_bottom_rounded,
    'quill' => Icons.brush_rounded,
    'snow_globe' => Icons.ac_unit_rounded,
    'moonstone' => Icons.nightlight_rounded,
    'amber' => Icons.cookie_rounded,
    'pearl' => Icons.grain_rounded,
    'fossil' => Icons.spa_rounded,
    'geode' => Icons.diamond_rounded,
    'meteorite' => Icons.landscape_rounded,
    'dragon_scale' => Icons.whatshot_rounded,
    'phoenix_feather' => Icons.local_fire_department_rounded,
    'mermaid_comb' => Icons.waves_rounded,
    'griffin_claw' => Icons.near_me_rounded,
    'unicorn_hair' => Icons.auto_awesome_rounded,
    'kraken_ink' => Icons.water_rounded,
    'comet_tail' => Icons.flash_on_rounded,
    'star_seed' => Icons.flare_rounded,
    'sun_coin' => Icons.light_mode_rounded,
    'moon_key' => Icons.key_rounded,
    'aurora_ribbon' => Icons.wb_twilight_rounded,
    _ => Icons.bedtime_rounded,
  };
}

IconData setIcon(String set) {
  return switch (set) {
    'wayfarer' => Icons.backpack_rounded,
    'maps' => Icons.map_rounded,
    'curios' => Icons.museum_rounded,
    'stones' => Icons.diamond_rounded,
    'myths' => Icons.whatshot_rounded,
    _ => Icons.star_rounded,
  };
}

IconData groupIcon(String group) {
  return switch (group) {
    'area' => Icons.public_rounded,
    'km' => Icons.hiking_rounded,
    'cells' => Icons.grid_view_rounded,
    'cache' => Icons.inventory_2_rounded,
    'rare' => Icons.diamond_rounded,
    'epic' => Icons.auto_awesome_rounded,
    'legend' => Icons.star_rounded,
    'relic' => Icons.museum_rounded,
    'set' => Icons.workspaces_rounded,
    'sector' => Icons.explore_rounded,
    'charted' => Icons.map_rounded,
    'half' => Icons.castle_rounded,
    'streak' => Icons.local_fire_department_rounded,
    'beacon' => Icons.flare_rounded,
    'quest' || 'weekly' => Icons.task_alt_rounded,
    'days' => Icons.wb_sunny_rounded,
    'bigday' => Icons.emoji_events_rounded,
    'longday' => Icons.route_rounded,
    'night' => Icons.nightlight_rounded,
    'dawn' => Icons.wb_twilight_rounded,
    'level' => Icons.military_tech_rounded,
    'walks' => Icons.directions_walk_rounded,
    'gold' => Icons.savings_rounded,
    _ => Icons.brush_rounded,
  };
}

String durationLabel(int ms, AppLocalizations content) {
  final minutes = (ms / 60000).floor().clamp(0, 1 << 30);
  if (minutes < 60) return '$minutes ${content.unitMinutes}';
  return '${minutes ~/ 60} ${content.unitHours} ${minutes % 60} ${content.unitMinutes}';
}

String worldShare(double m2) {
  final p = m2 / 1000000 / Grid.earthKm2 * 100;
  if (p <= 0) return '0';
  var digits = 2;
  while (digits < 12 && p * pow10(digits) < 10) {
    digits++;
  }
  return p.toStringAsFixed(digits);
}

double pow10(int n) {
  var v = 1.0;
  for (var i = 0; i < n; i++) {
    v *= 10;
  }
  return v;
}
