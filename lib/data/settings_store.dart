import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModePref { system, light, dark }

enum UnitsPref { metric, imperial }

enum LanguagePref { system, en, ru, uk }

class BeaconSpot {
  const BeaconSpot(this.day, this.lat, this.lon);
  final int day;
  final double lat;
  final double lon;
}

class Settings {
  const Settings({
    this.theme = ThemeModePref.system,
    this.onboarded = false,
    this.name = '',
    this.units = UnitsPref.metric,
    this.fog = 'mist',
    this.fogDensity = 0.92,
    this.owned = const {'mist'},
    this.shields = 0,
    this.lanternUntil = 0,
    this.radarUntil = 0,
    this.beacon = const BeaconSpot(0, 0, 0),
    this.rerollDay = 0,
    this.shielded = const {},
    this.remind = true,
    this.remindAt = 18 * 60 + 30,
    this.nearbyAlerts = true,
    this.haptics = true,
    this.lastLat = 0,
    this.lastLon = 0,
    this.walking = false,
    this.seenBadges = const {},
    this.levelSeen = 1,
    this.language = LanguagePref.system,
  });

  final ThemeModePref theme;
  final bool onboarded;
  final String name;
  final UnitsPref units;
  final String fog;
  final double fogDensity;
  final Set<String> owned;
  final int shields;
  final int lanternUntil;
  final int radarUntil;
  final BeaconSpot beacon;
  final int rerollDay;
  final Set<int> shielded;
  final bool remind;
  final int remindAt;
  final bool nearbyAlerts;
  final bool haptics;
  final double lastLat;
  final double lastLon;
  final bool walking;
  final Set<String> seenBadges;
  final int levelSeen;
  final LanguagePref language;

  Settings copyWith({
    ThemeModePref? theme,
    bool? onboarded,
    String? name,
    UnitsPref? units,
    String? fog,
    double? fogDensity,
    Set<String>? owned,
    int? shields,
    int? lanternUntil,
    int? radarUntil,
    BeaconSpot? beacon,
    int? rerollDay,
    Set<int>? shielded,
    bool? remind,
    int? remindAt,
    bool? nearbyAlerts,
    bool? haptics,
    double? lastLat,
    double? lastLon,
    bool? walking,
    Set<String>? seenBadges,
    int? levelSeen,
    LanguagePref? language,
  }) => Settings(
    theme: theme ?? this.theme,
    onboarded: onboarded ?? this.onboarded,
    name: name ?? this.name,
    units: units ?? this.units,
    fog: fog ?? this.fog,
    fogDensity: fogDensity ?? this.fogDensity,
    owned: owned ?? this.owned,
    shields: shields ?? this.shields,
    lanternUntil: lanternUntil ?? this.lanternUntil,
    radarUntil: radarUntil ?? this.radarUntil,
    beacon: beacon ?? this.beacon,
    rerollDay: rerollDay ?? this.rerollDay,
    shielded: shielded ?? this.shielded,
    remind: remind ?? this.remind,
    remindAt: remindAt ?? this.remindAt,
    nearbyAlerts: nearbyAlerts ?? this.nearbyAlerts,
    haptics: haptics ?? this.haptics,
    lastLat: lastLat ?? this.lastLat,
    lastLon: lastLon ?? this.lastLon,
    walking: walking ?? this.walking,
    seenBadges: seenBadges ?? this.seenBadges,
    levelSeen: levelSeen ?? this.levelSeen,
    language: language ?? this.language,
  );
}

class SettingsStore {
  SettingsStore(this._prefs);

  final SharedPreferences _prefs;
  final List<void Function(Settings)> _listeners = [];

  /// Called after [update] writes, but not after [refresh]: the hook that
  /// tells the other isolate to [refresh], without the two echoing forever.
  void Function()? onWrite;

  void addListener(void Function(Settings) l) => _listeners.add(l);
  void removeListener(void Function(Settings) l) => _listeners.remove(l);

  Settings now() => _read();

  /// Applies [change] and notifies listeners.
  ///
  /// The walk service runs in its own isolate with its own preferences cache,
  /// so this re-reads the stored values first and writes back only the keys
  /// [change] touched; a stale cache never overwrites the other side's writes.
  Future<void> update(Settings Function(Settings) change) async {
    await _prefs.reload();
    final before = _encode(_read());
    final next = change(_read());
    final after = _encode(next);
    for (final MapEntry(:key, :value) in after.entries) {
      if (_same(before[key], value)) continue;
      await switch (value) {
        final bool v => _prefs.setBool(key, v),
        final int v => _prefs.setInt(key, v),
        final double v => _prefs.setDouble(key, v),
        final String v => _prefs.setString(key, v),
        final List<String> v => _prefs.setStringList(key, v),
        _ => throw StateError('Unsupported setting $key: $value'),
      };
    }
    _notify(next);
    onWrite?.call();
  }

  /// Picks up values another isolate wrote, and notifies listeners.
  Future<void> refresh() async {
    await _prefs.reload();
    _notify(_read());
  }

  void _notify(Settings s) {
    for (final l in List.of(_listeners)) {
      l(s);
    }
  }

  static bool _same(Object? a, Object? b) =>
      a is List<String> && b is List<String> ? listEquals(a, b) : a == b;

  Settings _read() {
    ThemeModePref theme = ThemeModePref.system;
    final tw = _prefs.getString('theme');
    if (tw != null) {
      theme = ThemeModePref.values.firstWhere(
        (e) => e.name.toUpperCase() == tw.toUpperCase(),
        orElse: () => ThemeModePref.system,
      );
    }
    UnitsPref units = UnitsPref.metric;
    final uw = _prefs.getString('units');
    if (uw != null) {
      units = UnitsPref.values.firstWhere(
        (e) => e.name.toUpperCase() == uw.toUpperCase(),
        orElse: () => UnitsPref.metric,
      );
    }
    LanguagePref language = LanguagePref.system;
    final lw = _prefs.getString('language');
    if (lw != null) {
      language = LanguagePref.values.firstWhere(
        (e) => e.name.toUpperCase() == lw.toUpperCase(),
        orElse: () => LanguagePref.system,
      );
    }
    final owned = <String>{...(_prefs.getStringList('owned') ?? []), 'mist'};
    final shielded = (_prefs.getStringList('shielded') ?? [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
    return Settings(
      theme: theme,
      onboarded: _prefs.getBool('onboarded') ?? false,
      name: _prefs.getString('name') ?? '',
      units: units,
      fog: _prefs.getString('fog') ?? 'mist',
      fogDensity: _prefs.getDouble('fog_density') ?? 0.92,
      owned: owned,
      shields: _prefs.getInt('shields') ?? 0,
      lanternUntil: _prefs.getInt('lantern_until') ?? 0,
      radarUntil: _prefs.getInt('radar_until') ?? 0,
      beacon: BeaconSpot(
        _prefs.getInt('beacon_day') ?? 0,
        _prefs.getDouble('beacon_lat') ?? 0,
        _prefs.getDouble('beacon_lon') ?? 0,
      ),
      rerollDay: _prefs.getInt('reroll_day') ?? 0,
      shielded: shielded,
      remind: _prefs.getBool('remind') ?? true,
      remindAt: _prefs.getInt('remind_at') ?? (18 * 60 + 30),
      nearbyAlerts: _prefs.getBool('nearby_alerts') ?? true,
      haptics: _prefs.getBool('haptics') ?? true,
      lastLat: _prefs.getDouble('last_lat') ?? 0,
      lastLon: _prefs.getDouble('last_lon') ?? 0,
      walking: _prefs.getBool('walking') ?? false,
      seenBadges: (_prefs.getStringList('seen_badges') ?? []).toSet(),
      levelSeen: _prefs.getInt('level_seen') ?? 1,
      language: language,
    );
  }

  static List<String> _sorted(Iterable<String> v) => v.toList()..sort();

  static Map<String, Object> _encode(Settings s) => {
    'theme': s.theme.name.toUpperCase(),
    'onboarded': s.onboarded,
    'name': s.name,
    'units': s.units.name.toUpperCase(),
    'fog': s.fog,
    'fog_density': s.fogDensity,
    'owned': _sorted(s.owned),
    'shields': s.shields,
    'lantern_until': s.lanternUntil,
    'radar_until': s.radarUntil,
    'beacon_day': s.beacon.day,
    'beacon_lat': s.beacon.lat,
    'beacon_lon': s.beacon.lon,
    'reroll_day': s.rerollDay,
    'shielded': _sorted(s.shielded.map((e) => e.toString())),
    'remind': s.remind,
    'remind_at': s.remindAt,
    'nearby_alerts': s.nearbyAlerts,
    'haptics': s.haptics,
    'last_lat': s.lastLat,
    'last_lon': s.lastLon,
    'walking': s.walking,
    'seen_badges': _sorted(s.seenBadges),
    'level_seen': s.levelSeen,
    'language': s.language.name.toUpperCase(),
  };
}
