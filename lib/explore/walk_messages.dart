import 'package:mapdefog/data/models.dart';
import 'package:mapdefog/domain/caches.dart';
import 'package:mapdefog/domain/rarity.dart';
import 'package:mapdefog/explore/explorer.dart';
import 'package:mapdefog/explore/fix.dart';

/// Messages between the app and the Android walk service, which run in
/// different isolates. The plugin carrying them only passes maps, lists and
/// primitives, so everything is encoded as such.
abstract final class WalkMessage {
  // Service -> app.
  static const live = 'live';
  static const cells = 'cells';
  static const event = 'event';
  static const tables = 'tables';
  static const settings = 'settings';
  static const stopped = 'stopped';

  // App -> service.
  static const hello = 'hello';
  static const visible = 'visible';
  static const reload = 'reload';
  static const simulate = 'simulate';

  static Map<String, Object?> of(String type, [Map<String, Object?> body = const {}]) => {
    't': type,
    ...body,
  };

  /// The message type, or null for data that is not a [WalkMessage].
  static String? typeOf(Object? data) =>
      data is Map && data['t'] is String ? data['t'] as String : null;
}

abstract final class WalkCodec {
  static Map<String, Object?> live(Live l) => {
    'fix': l.fix == null ? null : fix(l.fix!),
    'walk': l.walk == null ? null : walk(l.walk!),
    'trail': [
      for (final (lat, lon) in l.trail) ...[lat, lon],
    ],
    'fast': l.tooFast,
  };

  static Live toLive(Map<Object?, Object?> m) {
    final flat = (m['trail']! as List).cast<double>();
    return Live(
      fix: m['fix'] == null ? null : toFix(m['fix']! as Map),
      walk: m['walk'] == null ? null : toWalk(m['walk']! as Map),
      trail: [for (var i = 0; i + 1 < flat.length; i += 2) (flat[i], flat[i + 1])],
      tooFast: m['fast']! as bool,
    );
  }

  static Map<String, Object?> fix(Fix f) => {
    'lat': f.lat,
    'lon': f.lon,
    'acc': f.accuracy,
    'time': f.time,
    'bearing': f.bearing,
    'sim': f.simulated,
    'gps': f.gps,
    'speed': f.speed,
  };

  static Fix toFix(Map<Object?, Object?> m) => Fix(
    lat: m['lat']! as double,
    lon: m['lon']! as double,
    accuracy: m['acc']! as double,
    time: m['time']! as int,
    bearing: m['bearing'] as double?,
    simulated: m['sim']! as bool,
    gps: m['gps']! as bool,
    speed: m['speed'] as double?,
  );

  static Map<String, Object?> walk(WalkRow w) => {
    'id': w.id,
    'start': w.start,
    'end': w.end,
    'meters': w.meters,
    'cells': w.cells,
    'caches': w.caches,
    'lat': w.lat,
    'lon': w.lon,
  };

  static WalkRow toWalk(Map<Object?, Object?> m) => WalkRow(
    id: m['id']! as int,
    start: m['start']! as int,
    end: m['end']! as int,
    meters: m['meters']! as double,
    cells: m['cells']! as int,
    caches: m['caches']! as int,
    lat: m['lat']! as double,
    lon: m['lon']! as double,
  );

  static Map<String, Object?> event(GameEvent e) => switch (e) {
    OpenedEvent(:final find) => {
      'kind': 'opened',
      'key': find.key,
      'at': find.at,
      'rarity': find.rarity,
      'relic': find.relic,
      'duplicate': find.duplicate,
      'coins': find.coins,
      'xp': find.xp,
      'lat': find.lat,
      'lon': find.lon,
      'seen': find.seen,
    },
    NewSectorEvent(:final sector) => {'kind': 'sector', 'sector': sector},
    MilestoneEvent(:final sector, :final share, :final coins) => {
      'kind': 'milestone',
      'sector': sector,
      'share': share,
      'coins': coins,
    },
    BeaconEvent() => {'kind': 'beacon'},
    NearEvent(:final cache, :final meters) => {
      'kind': 'near',
      'key': cache.key,
      'lat': cache.lat,
      'lon': cache.lon,
      'rarity': cache.rarity.index,
      'meters': meters,
    },
  };

  static GameEvent toEvent(Map<Object?, Object?> m) => switch (m['kind']) {
    'opened' => OpenedEvent(
      FindRow(
        key: m['key']! as String,
        at: m['at']! as int,
        rarity: m['rarity']! as int,
        relic: m['relic']! as String,
        duplicate: m['duplicate']! as bool,
        coins: m['coins']! as int,
        xp: m['xp']! as int,
        lat: m['lat']! as double,
        lon: m['lon']! as double,
        seen: m['seen']! as bool,
      ),
    ),
    'sector' => NewSectorEvent(m['sector']! as int),
    'milestone' => MilestoneEvent(m['sector']! as int, m['share']! as double, m['coins']! as int),
    'beacon' => BeaconEvent(),
    'near' => NearEvent(
      Cache(
        m['key']! as String,
        m['lat']! as double,
        m['lon']! as double,
        Rarity.values[m['rarity']! as int],
      ),
      m['meters']! as int,
    ),
    final kind => throw FormatException('Unknown game event $kind'),
  };
}
