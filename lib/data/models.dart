class DayRow {
  const DayRow({
    required this.day,
    this.cells = 0,
    this.meters = 0,
    this.caches = 0,
    this.rare = 0,
    this.beacon = false,
    this.night = 0,
    this.dawn = 0,
  });

  final int day;
  final int cells;
  final double meters;
  final int caches;
  final int rare;
  final bool beacon;
  final int night;
  final int dawn;

  DayRow copyWith({
    int? cells,
    double? meters,
    int? caches,
    int? rare,
    bool? beacon,
    int? night,
    int? dawn,
  }) => DayRow(
    day: day,
    cells: cells ?? this.cells,
    meters: meters ?? this.meters,
    caches: caches ?? this.caches,
    rare: rare ?? this.rare,
    beacon: beacon ?? this.beacon,
    night: night ?? this.night,
    dawn: dawn ?? this.dawn,
  );
}

class WalkRow {
  const WalkRow({
    this.id = 0,
    required this.start,
    required this.end,
    this.meters = 0,
    this.cells = 0,
    this.caches = 0,
    this.lat = 0,
    this.lon = 0,
  });

  final int id;
  final int start;
  final int end;
  final double meters;
  final int cells;
  final int caches;
  final double lat;
  final double lon;

  WalkRow copyWith({int? id, int? end, double? meters, int? cells, int? caches}) => WalkRow(
    id: id ?? this.id,
    start: start,
    end: end ?? this.end,
    meters: meters ?? this.meters,
    cells: cells ?? this.cells,
    caches: caches ?? this.caches,
    lat: lat,
    lon: lon,
  );
}

class WaypointRow {
  const WaypointRow({
    this.id = 0,
    required this.walk,
    required this.at,
    required this.lat,
    required this.lon,
  });

  final int id;
  final int walk;
  final int at;
  final double lat;
  final double lon;
}

class FindRow {
  const FindRow({
    required this.key,
    required this.at,
    required this.rarity,
    this.relic = '',
    this.duplicate = false,
    required this.coins,
    required this.xp,
    required this.lat,
    required this.lon,
    this.seen = false,
  });

  final String key;
  final int at;
  final int rarity;
  final String relic;
  final bool duplicate;
  final int coins;
  final int xp;
  final double lat;
  final double lon;
  final bool seen;
}

class EntryRow {
  const EntryRow({required this.ref, required this.at, this.coins = 0, this.xp = 0});

  final String ref;
  final int at;
  final int coins;
  final int xp;
}

class CellRow {
  const CellRow(this.id, this.at);
  final int id;
  final int at;
}
