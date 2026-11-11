// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CellsTable extends Cells with TableInfo<$CellsTable, Cell> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CellsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cells';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cell> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cell map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cell(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $CellsTable createAlias(String alias) {
    return $CellsTable(attachedDatabase, alias);
  }
}

class Cell extends DataClass implements Insertable<Cell> {
  final int id;
  final int at;
  const Cell({required this.id, required this.at});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['at'] = Variable<int>(at);
    return map;
  }

  CellsCompanion toCompanion(bool nullToAbsent) {
    return CellsCompanion(id: Value(id), at: Value(at));
  }

  factory Cell.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cell(
      id: serializer.fromJson<int>(json['id']),
      at: serializer.fromJson<int>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'at': serializer.toJson<int>(at),
    };
  }

  Cell copyWith({int? id, int? at}) =>
      Cell(id: id ?? this.id, at: at ?? this.at);
  Cell copyWithCompanion(CellsCompanion data) {
    return Cell(
      id: data.id.present ? data.id.value : this.id,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cell(')
          ..write('id: $id, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cell && other.id == this.id && other.at == this.at);
}

class CellsCompanion extends UpdateCompanion<Cell> {
  final Value<int> id;
  final Value<int> at;
  const CellsCompanion({
    this.id = const Value.absent(),
    this.at = const Value.absent(),
  });
  CellsCompanion.insert({this.id = const Value.absent(), required int at})
    : at = Value(at);
  static Insertable<Cell> custom({Expression<int>? id, Expression<int>? at}) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (at != null) 'at': at,
    });
  }

  CellsCompanion copyWith({Value<int>? id, Value<int>? at}) {
    return CellsCompanion(id: id ?? this.id, at: at ?? this.at);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CellsCompanion(')
          ..write('id: $id, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

class $DaysTable extends Days with TableInfo<$DaysTable, Day> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cellsMeta = const VerificationMeta('cells');
  @override
  late final GeneratedColumn<int> cells = GeneratedColumn<int>(
    'cells',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _metersMeta = const VerificationMeta('meters');
  @override
  late final GeneratedColumn<double> meters = GeneratedColumn<double>(
    'meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cachesMeta = const VerificationMeta('caches');
  @override
  late final GeneratedColumn<int> caches = GeneratedColumn<int>(
    'caches',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rareMeta = const VerificationMeta('rare');
  @override
  late final GeneratedColumn<int> rare = GeneratedColumn<int>(
    'rare',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _beaconMeta = const VerificationMeta('beacon');
  @override
  late final GeneratedColumn<bool> beacon = GeneratedColumn<bool>(
    'beacon',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("beacon" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nightMeta = const VerificationMeta('night');
  @override
  late final GeneratedColumn<int> night = GeneratedColumn<int>(
    'night',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dawnMeta = const VerificationMeta('dawn');
  @override
  late final GeneratedColumn<int> dawn = GeneratedColumn<int>(
    'dawn',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    day,
    cells,
    meters,
    caches,
    rare,
    beacon,
    night,
    dawn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'days';
  @override
  VerificationContext validateIntegrity(
    Insertable<Day> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    }
    if (data.containsKey('cells')) {
      context.handle(
        _cellsMeta,
        cells.isAcceptableOrUnknown(data['cells']!, _cellsMeta),
      );
    }
    if (data.containsKey('meters')) {
      context.handle(
        _metersMeta,
        meters.isAcceptableOrUnknown(data['meters']!, _metersMeta),
      );
    }
    if (data.containsKey('caches')) {
      context.handle(
        _cachesMeta,
        caches.isAcceptableOrUnknown(data['caches']!, _cachesMeta),
      );
    }
    if (data.containsKey('rare')) {
      context.handle(
        _rareMeta,
        rare.isAcceptableOrUnknown(data['rare']!, _rareMeta),
      );
    }
    if (data.containsKey('beacon')) {
      context.handle(
        _beaconMeta,
        beacon.isAcceptableOrUnknown(data['beacon']!, _beaconMeta),
      );
    }
    if (data.containsKey('night')) {
      context.handle(
        _nightMeta,
        night.isAcceptableOrUnknown(data['night']!, _nightMeta),
      );
    }
    if (data.containsKey('dawn')) {
      context.handle(
        _dawnMeta,
        dawn.isAcceptableOrUnknown(data['dawn']!, _dawnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  Day map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Day(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day'],
      )!,
      cells: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cells'],
      )!,
      meters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}meters'],
      )!,
      caches: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}caches'],
      )!,
      rare: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rare'],
      )!,
      beacon: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}beacon'],
      )!,
      night: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}night'],
      )!,
      dawn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dawn'],
      )!,
    );
  }

  @override
  $DaysTable createAlias(String alias) {
    return $DaysTable(attachedDatabase, alias);
  }
}

class Day extends DataClass implements Insertable<Day> {
  final int day;
  final int cells;
  final double meters;
  final int caches;
  final int rare;
  final bool beacon;
  final int night;
  final int dawn;
  const Day({
    required this.day,
    required this.cells,
    required this.meters,
    required this.caches,
    required this.rare,
    required this.beacon,
    required this.night,
    required this.dawn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<int>(day);
    map['cells'] = Variable<int>(cells);
    map['meters'] = Variable<double>(meters);
    map['caches'] = Variable<int>(caches);
    map['rare'] = Variable<int>(rare);
    map['beacon'] = Variable<bool>(beacon);
    map['night'] = Variable<int>(night);
    map['dawn'] = Variable<int>(dawn);
    return map;
  }

  DaysCompanion toCompanion(bool nullToAbsent) {
    return DaysCompanion(
      day: Value(day),
      cells: Value(cells),
      meters: Value(meters),
      caches: Value(caches),
      rare: Value(rare),
      beacon: Value(beacon),
      night: Value(night),
      dawn: Value(dawn),
    );
  }

  factory Day.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Day(
      day: serializer.fromJson<int>(json['day']),
      cells: serializer.fromJson<int>(json['cells']),
      meters: serializer.fromJson<double>(json['meters']),
      caches: serializer.fromJson<int>(json['caches']),
      rare: serializer.fromJson<int>(json['rare']),
      beacon: serializer.fromJson<bool>(json['beacon']),
      night: serializer.fromJson<int>(json['night']),
      dawn: serializer.fromJson<int>(json['dawn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<int>(day),
      'cells': serializer.toJson<int>(cells),
      'meters': serializer.toJson<double>(meters),
      'caches': serializer.toJson<int>(caches),
      'rare': serializer.toJson<int>(rare),
      'beacon': serializer.toJson<bool>(beacon),
      'night': serializer.toJson<int>(night),
      'dawn': serializer.toJson<int>(dawn),
    };
  }

  Day copyWith({
    int? day,
    int? cells,
    double? meters,
    int? caches,
    int? rare,
    bool? beacon,
    int? night,
    int? dawn,
  }) => Day(
    day: day ?? this.day,
    cells: cells ?? this.cells,
    meters: meters ?? this.meters,
    caches: caches ?? this.caches,
    rare: rare ?? this.rare,
    beacon: beacon ?? this.beacon,
    night: night ?? this.night,
    dawn: dawn ?? this.dawn,
  );
  Day copyWithCompanion(DaysCompanion data) {
    return Day(
      day: data.day.present ? data.day.value : this.day,
      cells: data.cells.present ? data.cells.value : this.cells,
      meters: data.meters.present ? data.meters.value : this.meters,
      caches: data.caches.present ? data.caches.value : this.caches,
      rare: data.rare.present ? data.rare.value : this.rare,
      beacon: data.beacon.present ? data.beacon.value : this.beacon,
      night: data.night.present ? data.night.value : this.night,
      dawn: data.dawn.present ? data.dawn.value : this.dawn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Day(')
          ..write('day: $day, ')
          ..write('cells: $cells, ')
          ..write('meters: $meters, ')
          ..write('caches: $caches, ')
          ..write('rare: $rare, ')
          ..write('beacon: $beacon, ')
          ..write('night: $night, ')
          ..write('dawn: $dawn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(day, cells, meters, caches, rare, beacon, night, dawn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Day &&
          other.day == this.day &&
          other.cells == this.cells &&
          other.meters == this.meters &&
          other.caches == this.caches &&
          other.rare == this.rare &&
          other.beacon == this.beacon &&
          other.night == this.night &&
          other.dawn == this.dawn);
}

class DaysCompanion extends UpdateCompanion<Day> {
  final Value<int> day;
  final Value<int> cells;
  final Value<double> meters;
  final Value<int> caches;
  final Value<int> rare;
  final Value<bool> beacon;
  final Value<int> night;
  final Value<int> dawn;
  const DaysCompanion({
    this.day = const Value.absent(),
    this.cells = const Value.absent(),
    this.meters = const Value.absent(),
    this.caches = const Value.absent(),
    this.rare = const Value.absent(),
    this.beacon = const Value.absent(),
    this.night = const Value.absent(),
    this.dawn = const Value.absent(),
  });
  DaysCompanion.insert({
    this.day = const Value.absent(),
    this.cells = const Value.absent(),
    this.meters = const Value.absent(),
    this.caches = const Value.absent(),
    this.rare = const Value.absent(),
    this.beacon = const Value.absent(),
    this.night = const Value.absent(),
    this.dawn = const Value.absent(),
  });
  static Insertable<Day> custom({
    Expression<int>? day,
    Expression<int>? cells,
    Expression<double>? meters,
    Expression<int>? caches,
    Expression<int>? rare,
    Expression<bool>? beacon,
    Expression<int>? night,
    Expression<int>? dawn,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (cells != null) 'cells': cells,
      if (meters != null) 'meters': meters,
      if (caches != null) 'caches': caches,
      if (rare != null) 'rare': rare,
      if (beacon != null) 'beacon': beacon,
      if (night != null) 'night': night,
      if (dawn != null) 'dawn': dawn,
    });
  }

  DaysCompanion copyWith({
    Value<int>? day,
    Value<int>? cells,
    Value<double>? meters,
    Value<int>? caches,
    Value<int>? rare,
    Value<bool>? beacon,
    Value<int>? night,
    Value<int>? dawn,
  }) {
    return DaysCompanion(
      day: day ?? this.day,
      cells: cells ?? this.cells,
      meters: meters ?? this.meters,
      caches: caches ?? this.caches,
      rare: rare ?? this.rare,
      beacon: beacon ?? this.beacon,
      night: night ?? this.night,
      dawn: dawn ?? this.dawn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (cells.present) {
      map['cells'] = Variable<int>(cells.value);
    }
    if (meters.present) {
      map['meters'] = Variable<double>(meters.value);
    }
    if (caches.present) {
      map['caches'] = Variable<int>(caches.value);
    }
    if (rare.present) {
      map['rare'] = Variable<int>(rare.value);
    }
    if (beacon.present) {
      map['beacon'] = Variable<bool>(beacon.value);
    }
    if (night.present) {
      map['night'] = Variable<int>(night.value);
    }
    if (dawn.present) {
      map['dawn'] = Variable<int>(dawn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DaysCompanion(')
          ..write('day: $day, ')
          ..write('cells: $cells, ')
          ..write('meters: $meters, ')
          ..write('caches: $caches, ')
          ..write('rare: $rare, ')
          ..write('beacon: $beacon, ')
          ..write('night: $night, ')
          ..write('dawn: $dawn')
          ..write(')'))
        .toString();
  }
}

class $WalksTable extends Walks with TableInfo<$WalksTable, Walk> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<int> start = GeneratedColumn<int>(
    'start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<int> end = GeneratedColumn<int>(
    'end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metersMeta = const VerificationMeta('meters');
  @override
  late final GeneratedColumn<double> meters = GeneratedColumn<double>(
    'meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cellsMeta = const VerificationMeta('cells');
  @override
  late final GeneratedColumn<int> cells = GeneratedColumn<int>(
    'cells',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cachesMeta = const VerificationMeta('caches');
  @override
  late final GeneratedColumn<int> caches = GeneratedColumn<int>(
    'caches',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    start,
    end,
    meters,
    cells,
    caches,
    lat,
    lon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'walks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Walk> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start')) {
      context.handle(
        _startMeta,
        start.isAcceptableOrUnknown(data['start']!, _startMeta),
      );
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('end')) {
      context.handle(
        _endMeta,
        end.isAcceptableOrUnknown(data['end']!, _endMeta),
      );
    } else if (isInserting) {
      context.missing(_endMeta);
    }
    if (data.containsKey('meters')) {
      context.handle(
        _metersMeta,
        meters.isAcceptableOrUnknown(data['meters']!, _metersMeta),
      );
    }
    if (data.containsKey('cells')) {
      context.handle(
        _cellsMeta,
        cells.isAcceptableOrUnknown(data['cells']!, _cellsMeta),
      );
    }
    if (data.containsKey('caches')) {
      context.handle(
        _cachesMeta,
        caches.isAcceptableOrUnknown(data['caches']!, _cachesMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Walk map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Walk(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      start: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start'],
      )!,
      end: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end'],
      )!,
      meters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}meters'],
      )!,
      cells: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cells'],
      )!,
      caches: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}caches'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      )!,
    );
  }

  @override
  $WalksTable createAlias(String alias) {
    return $WalksTable(attachedDatabase, alias);
  }
}

class Walk extends DataClass implements Insertable<Walk> {
  final int id;
  final int start;
  final int end;
  final double meters;
  final int cells;
  final int caches;
  final double lat;
  final double lon;
  const Walk({
    required this.id,
    required this.start,
    required this.end,
    required this.meters,
    required this.cells,
    required this.caches,
    required this.lat,
    required this.lon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start'] = Variable<int>(start);
    map['end'] = Variable<int>(end);
    map['meters'] = Variable<double>(meters);
    map['cells'] = Variable<int>(cells);
    map['caches'] = Variable<int>(caches);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    return map;
  }

  WalksCompanion toCompanion(bool nullToAbsent) {
    return WalksCompanion(
      id: Value(id),
      start: Value(start),
      end: Value(end),
      meters: Value(meters),
      cells: Value(cells),
      caches: Value(caches),
      lat: Value(lat),
      lon: Value(lon),
    );
  }

  factory Walk.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Walk(
      id: serializer.fromJson<int>(json['id']),
      start: serializer.fromJson<int>(json['start']),
      end: serializer.fromJson<int>(json['end']),
      meters: serializer.fromJson<double>(json['meters']),
      cells: serializer.fromJson<int>(json['cells']),
      caches: serializer.fromJson<int>(json['caches']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'start': serializer.toJson<int>(start),
      'end': serializer.toJson<int>(end),
      'meters': serializer.toJson<double>(meters),
      'cells': serializer.toJson<int>(cells),
      'caches': serializer.toJson<int>(caches),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
    };
  }

  Walk copyWith({
    int? id,
    int? start,
    int? end,
    double? meters,
    int? cells,
    int? caches,
    double? lat,
    double? lon,
  }) => Walk(
    id: id ?? this.id,
    start: start ?? this.start,
    end: end ?? this.end,
    meters: meters ?? this.meters,
    cells: cells ?? this.cells,
    caches: caches ?? this.caches,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
  );
  Walk copyWithCompanion(WalksCompanion data) {
    return Walk(
      id: data.id.present ? data.id.value : this.id,
      start: data.start.present ? data.start.value : this.start,
      end: data.end.present ? data.end.value : this.end,
      meters: data.meters.present ? data.meters.value : this.meters,
      cells: data.cells.present ? data.cells.value : this.cells,
      caches: data.caches.present ? data.caches.value : this.caches,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Walk(')
          ..write('id: $id, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('meters: $meters, ')
          ..write('cells: $cells, ')
          ..write('caches: $caches, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, start, end, meters, cells, caches, lat, lon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Walk &&
          other.id == this.id &&
          other.start == this.start &&
          other.end == this.end &&
          other.meters == this.meters &&
          other.cells == this.cells &&
          other.caches == this.caches &&
          other.lat == this.lat &&
          other.lon == this.lon);
}

class WalksCompanion extends UpdateCompanion<Walk> {
  final Value<int> id;
  final Value<int> start;
  final Value<int> end;
  final Value<double> meters;
  final Value<int> cells;
  final Value<int> caches;
  final Value<double> lat;
  final Value<double> lon;
  const WalksCompanion({
    this.id = const Value.absent(),
    this.start = const Value.absent(),
    this.end = const Value.absent(),
    this.meters = const Value.absent(),
    this.cells = const Value.absent(),
    this.caches = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
  });
  WalksCompanion.insert({
    this.id = const Value.absent(),
    required int start,
    required int end,
    this.meters = const Value.absent(),
    this.cells = const Value.absent(),
    this.caches = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
  }) : start = Value(start),
       end = Value(end);
  static Insertable<Walk> custom({
    Expression<int>? id,
    Expression<int>? start,
    Expression<int>? end,
    Expression<double>? meters,
    Expression<int>? cells,
    Expression<int>? caches,
    Expression<double>? lat,
    Expression<double>? lon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (start != null) 'start': start,
      if (end != null) 'end': end,
      if (meters != null) 'meters': meters,
      if (cells != null) 'cells': cells,
      if (caches != null) 'caches': caches,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    });
  }

  WalksCompanion copyWith({
    Value<int>? id,
    Value<int>? start,
    Value<int>? end,
    Value<double>? meters,
    Value<int>? cells,
    Value<int>? caches,
    Value<double>? lat,
    Value<double>? lon,
  }) {
    return WalksCompanion(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      meters: meters ?? this.meters,
      cells: cells ?? this.cells,
      caches: caches ?? this.caches,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (start.present) {
      map['start'] = Variable<int>(start.value);
    }
    if (end.present) {
      map['end'] = Variable<int>(end.value);
    }
    if (meters.present) {
      map['meters'] = Variable<double>(meters.value);
    }
    if (cells.present) {
      map['cells'] = Variable<int>(cells.value);
    }
    if (caches.present) {
      map['caches'] = Variable<int>(caches.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalksCompanion(')
          ..write('id: $id, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('meters: $meters, ')
          ..write('cells: $cells, ')
          ..write('caches: $caches, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon')
          ..write(')'))
        .toString();
  }
}

class $WaypointsTable extends Waypoints
    with TableInfo<$WaypointsTable, Waypoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaypointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _walkMeta = const VerificationMeta('walk');
  @override
  late final GeneratedColumn<int> walk = GeneratedColumn<int>(
    'walk',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, walk, at, lat, lon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'waypoints';
  @override
  VerificationContext validateIntegrity(
    Insertable<Waypoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('walk')) {
      context.handle(
        _walkMeta,
        walk.isAcceptableOrUnknown(data['walk']!, _walkMeta),
      );
    } else if (isInserting) {
      context.missing(_walkMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Waypoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Waypoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      walk: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}walk'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      )!,
    );
  }

  @override
  $WaypointsTable createAlias(String alias) {
    return $WaypointsTable(attachedDatabase, alias);
  }
}

class Waypoint extends DataClass implements Insertable<Waypoint> {
  final int id;
  final int walk;
  final int at;
  final double lat;
  final double lon;
  const Waypoint({
    required this.id,
    required this.walk,
    required this.at,
    required this.lat,
    required this.lon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['walk'] = Variable<int>(walk);
    map['at'] = Variable<int>(at);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    return map;
  }

  WaypointsCompanion toCompanion(bool nullToAbsent) {
    return WaypointsCompanion(
      id: Value(id),
      walk: Value(walk),
      at: Value(at),
      lat: Value(lat),
      lon: Value(lon),
    );
  }

  factory Waypoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Waypoint(
      id: serializer.fromJson<int>(json['id']),
      walk: serializer.fromJson<int>(json['walk']),
      at: serializer.fromJson<int>(json['at']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'walk': serializer.toJson<int>(walk),
      'at': serializer.toJson<int>(at),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
    };
  }

  Waypoint copyWith({int? id, int? walk, int? at, double? lat, double? lon}) =>
      Waypoint(
        id: id ?? this.id,
        walk: walk ?? this.walk,
        at: at ?? this.at,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
      );
  Waypoint copyWithCompanion(WaypointsCompanion data) {
    return Waypoint(
      id: data.id.present ? data.id.value : this.id,
      walk: data.walk.present ? data.walk.value : this.walk,
      at: data.at.present ? data.at.value : this.at,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Waypoint(')
          ..write('id: $id, ')
          ..write('walk: $walk, ')
          ..write('at: $at, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, walk, at, lat, lon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Waypoint &&
          other.id == this.id &&
          other.walk == this.walk &&
          other.at == this.at &&
          other.lat == this.lat &&
          other.lon == this.lon);
}

class WaypointsCompanion extends UpdateCompanion<Waypoint> {
  final Value<int> id;
  final Value<int> walk;
  final Value<int> at;
  final Value<double> lat;
  final Value<double> lon;
  const WaypointsCompanion({
    this.id = const Value.absent(),
    this.walk = const Value.absent(),
    this.at = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
  });
  WaypointsCompanion.insert({
    this.id = const Value.absent(),
    required int walk,
    required int at,
    required double lat,
    required double lon,
  }) : walk = Value(walk),
       at = Value(at),
       lat = Value(lat),
       lon = Value(lon);
  static Insertable<Waypoint> custom({
    Expression<int>? id,
    Expression<int>? walk,
    Expression<int>? at,
    Expression<double>? lat,
    Expression<double>? lon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (walk != null) 'walk': walk,
      if (at != null) 'at': at,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    });
  }

  WaypointsCompanion copyWith({
    Value<int>? id,
    Value<int>? walk,
    Value<int>? at,
    Value<double>? lat,
    Value<double>? lon,
  }) {
    return WaypointsCompanion(
      id: id ?? this.id,
      walk: walk ?? this.walk,
      at: at ?? this.at,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (walk.present) {
      map['walk'] = Variable<int>(walk.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaypointsCompanion(')
          ..write('id: $id, ')
          ..write('walk: $walk, ')
          ..write('at: $at, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon')
          ..write(')'))
        .toString();
  }
}

class $FindsTable extends Finds with TableInfo<$FindsTable, Find> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FindsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<int> rarity = GeneratedColumn<int>(
    'rarity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relicMeta = const VerificationMeta('relic');
  @override
  late final GeneratedColumn<String> relic = GeneratedColumn<String>(
    'relic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _duplicateMeta = const VerificationMeta(
    'duplicate',
  );
  @override
  late final GeneratedColumn<bool> duplicate = GeneratedColumn<bool>(
    'duplicate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("duplicate" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _coinsMeta = const VerificationMeta('coins');
  @override
  late final GeneratedColumn<int> coins = GeneratedColumn<int>(
    'coins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seenMeta = const VerificationMeta('seen');
  @override
  late final GeneratedColumn<bool> seen = GeneratedColumn<bool>(
    'seen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("seen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    at,
    rarity,
    relic,
    duplicate,
    coins,
    xp,
    lat,
    lon,
    seen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'finds';
  @override
  VerificationContext validateIntegrity(
    Insertable<Find> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    } else if (isInserting) {
      context.missing(_rarityMeta);
    }
    if (data.containsKey('relic')) {
      context.handle(
        _relicMeta,
        relic.isAcceptableOrUnknown(data['relic']!, _relicMeta),
      );
    }
    if (data.containsKey('duplicate')) {
      context.handle(
        _duplicateMeta,
        duplicate.isAcceptableOrUnknown(data['duplicate']!, _duplicateMeta),
      );
    }
    if (data.containsKey('coins')) {
      context.handle(
        _coinsMeta,
        coins.isAcceptableOrUnknown(data['coins']!, _coinsMeta),
      );
    } else if (isInserting) {
      context.missing(_coinsMeta);
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    } else if (isInserting) {
      context.missing(_xpMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('seen')) {
      context.handle(
        _seenMeta,
        seen.isAcceptableOrUnknown(data['seen']!, _seenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Find map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Find(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rarity'],
      )!,
      relic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relic'],
      )!,
      duplicate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}duplicate'],
      )!,
      coins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coins'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      )!,
      seen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}seen'],
      )!,
    );
  }

  @override
  $FindsTable createAlias(String alias) {
    return $FindsTable(attachedDatabase, alias);
  }
}

class Find extends DataClass implements Insertable<Find> {
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
  const Find({
    required this.key,
    required this.at,
    required this.rarity,
    required this.relic,
    required this.duplicate,
    required this.coins,
    required this.xp,
    required this.lat,
    required this.lon,
    required this.seen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['at'] = Variable<int>(at);
    map['rarity'] = Variable<int>(rarity);
    map['relic'] = Variable<String>(relic);
    map['duplicate'] = Variable<bool>(duplicate);
    map['coins'] = Variable<int>(coins);
    map['xp'] = Variable<int>(xp);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['seen'] = Variable<bool>(seen);
    return map;
  }

  FindsCompanion toCompanion(bool nullToAbsent) {
    return FindsCompanion(
      key: Value(key),
      at: Value(at),
      rarity: Value(rarity),
      relic: Value(relic),
      duplicate: Value(duplicate),
      coins: Value(coins),
      xp: Value(xp),
      lat: Value(lat),
      lon: Value(lon),
      seen: Value(seen),
    );
  }

  factory Find.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Find(
      key: serializer.fromJson<String>(json['key']),
      at: serializer.fromJson<int>(json['at']),
      rarity: serializer.fromJson<int>(json['rarity']),
      relic: serializer.fromJson<String>(json['relic']),
      duplicate: serializer.fromJson<bool>(json['duplicate']),
      coins: serializer.fromJson<int>(json['coins']),
      xp: serializer.fromJson<int>(json['xp']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      seen: serializer.fromJson<bool>(json['seen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'at': serializer.toJson<int>(at),
      'rarity': serializer.toJson<int>(rarity),
      'relic': serializer.toJson<String>(relic),
      'duplicate': serializer.toJson<bool>(duplicate),
      'coins': serializer.toJson<int>(coins),
      'xp': serializer.toJson<int>(xp),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'seen': serializer.toJson<bool>(seen),
    };
  }

  Find copyWith({
    String? key,
    int? at,
    int? rarity,
    String? relic,
    bool? duplicate,
    int? coins,
    int? xp,
    double? lat,
    double? lon,
    bool? seen,
  }) => Find(
    key: key ?? this.key,
    at: at ?? this.at,
    rarity: rarity ?? this.rarity,
    relic: relic ?? this.relic,
    duplicate: duplicate ?? this.duplicate,
    coins: coins ?? this.coins,
    xp: xp ?? this.xp,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    seen: seen ?? this.seen,
  );
  Find copyWithCompanion(FindsCompanion data) {
    return Find(
      key: data.key.present ? data.key.value : this.key,
      at: data.at.present ? data.at.value : this.at,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      relic: data.relic.present ? data.relic.value : this.relic,
      duplicate: data.duplicate.present ? data.duplicate.value : this.duplicate,
      coins: data.coins.present ? data.coins.value : this.coins,
      xp: data.xp.present ? data.xp.value : this.xp,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      seen: data.seen.present ? data.seen.value : this.seen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Find(')
          ..write('key: $key, ')
          ..write('at: $at, ')
          ..write('rarity: $rarity, ')
          ..write('relic: $relic, ')
          ..write('duplicate: $duplicate, ')
          ..write('coins: $coins, ')
          ..write('xp: $xp, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('seen: $seen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(key, at, rarity, relic, duplicate, coins, xp, lat, lon, seen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Find &&
          other.key == this.key &&
          other.at == this.at &&
          other.rarity == this.rarity &&
          other.relic == this.relic &&
          other.duplicate == this.duplicate &&
          other.coins == this.coins &&
          other.xp == this.xp &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.seen == this.seen);
}

class FindsCompanion extends UpdateCompanion<Find> {
  final Value<String> key;
  final Value<int> at;
  final Value<int> rarity;
  final Value<String> relic;
  final Value<bool> duplicate;
  final Value<int> coins;
  final Value<int> xp;
  final Value<double> lat;
  final Value<double> lon;
  final Value<bool> seen;
  final Value<int> rowid;
  const FindsCompanion({
    this.key = const Value.absent(),
    this.at = const Value.absent(),
    this.rarity = const Value.absent(),
    this.relic = const Value.absent(),
    this.duplicate = const Value.absent(),
    this.coins = const Value.absent(),
    this.xp = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.seen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FindsCompanion.insert({
    required String key,
    required int at,
    required int rarity,
    this.relic = const Value.absent(),
    this.duplicate = const Value.absent(),
    required int coins,
    required int xp,
    required double lat,
    required double lon,
    this.seen = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       at = Value(at),
       rarity = Value(rarity),
       coins = Value(coins),
       xp = Value(xp),
       lat = Value(lat),
       lon = Value(lon);
  static Insertable<Find> custom({
    Expression<String>? key,
    Expression<int>? at,
    Expression<int>? rarity,
    Expression<String>? relic,
    Expression<bool>? duplicate,
    Expression<int>? coins,
    Expression<int>? xp,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<bool>? seen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (at != null) 'at': at,
      if (rarity != null) 'rarity': rarity,
      if (relic != null) 'relic': relic,
      if (duplicate != null) 'duplicate': duplicate,
      if (coins != null) 'coins': coins,
      if (xp != null) 'xp': xp,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (seen != null) 'seen': seen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FindsCompanion copyWith({
    Value<String>? key,
    Value<int>? at,
    Value<int>? rarity,
    Value<String>? relic,
    Value<bool>? duplicate,
    Value<int>? coins,
    Value<int>? xp,
    Value<double>? lat,
    Value<double>? lon,
    Value<bool>? seen,
    Value<int>? rowid,
  }) {
    return FindsCompanion(
      key: key ?? this.key,
      at: at ?? this.at,
      rarity: rarity ?? this.rarity,
      relic: relic ?? this.relic,
      duplicate: duplicate ?? this.duplicate,
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      seen: seen ?? this.seen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<int>(rarity.value);
    }
    if (relic.present) {
      map['relic'] = Variable<String>(relic.value);
    }
    if (duplicate.present) {
      map['duplicate'] = Variable<bool>(duplicate.value);
    }
    if (coins.present) {
      map['coins'] = Variable<int>(coins.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (seen.present) {
      map['seen'] = Variable<bool>(seen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FindsCompanion(')
          ..write('key: $key, ')
          ..write('at: $at, ')
          ..write('rarity: $rarity, ')
          ..write('relic: $relic, ')
          ..write('duplicate: $duplicate, ')
          ..write('coins: $coins, ')
          ..write('xp: $xp, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('seen: $seen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerTable extends Ledger with TableInfo<$LedgerTable, LedgerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coinsMeta = const VerificationMeta('coins');
  @override
  late final GeneratedColumn<int> coins = GeneratedColumn<int>(
    'coins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [ref, at, coins, xp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    } else if (isInserting) {
      context.missing(_refMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('coins')) {
      context.handle(
        _coinsMeta,
        coins.isAcceptableOrUnknown(data['coins']!, _coinsMeta),
      );
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ref};
  @override
  LedgerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerData(
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
      coins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coins'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
    );
  }

  @override
  $LedgerTable createAlias(String alias) {
    return $LedgerTable(attachedDatabase, alias);
  }
}

class LedgerData extends DataClass implements Insertable<LedgerData> {
  final String ref;
  final int at;
  final int coins;
  final int xp;
  const LedgerData({
    required this.ref,
    required this.at,
    required this.coins,
    required this.xp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ref'] = Variable<String>(ref);
    map['at'] = Variable<int>(at);
    map['coins'] = Variable<int>(coins);
    map['xp'] = Variable<int>(xp);
    return map;
  }

  LedgerCompanion toCompanion(bool nullToAbsent) {
    return LedgerCompanion(
      ref: Value(ref),
      at: Value(at),
      coins: Value(coins),
      xp: Value(xp),
    );
  }

  factory LedgerData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerData(
      ref: serializer.fromJson<String>(json['ref']),
      at: serializer.fromJson<int>(json['at']),
      coins: serializer.fromJson<int>(json['coins']),
      xp: serializer.fromJson<int>(json['xp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ref': serializer.toJson<String>(ref),
      'at': serializer.toJson<int>(at),
      'coins': serializer.toJson<int>(coins),
      'xp': serializer.toJson<int>(xp),
    };
  }

  LedgerData copyWith({String? ref, int? at, int? coins, int? xp}) =>
      LedgerData(
        ref: ref ?? this.ref,
        at: at ?? this.at,
        coins: coins ?? this.coins,
        xp: xp ?? this.xp,
      );
  LedgerData copyWithCompanion(LedgerCompanion data) {
    return LedgerData(
      ref: data.ref.present ? data.ref.value : this.ref,
      at: data.at.present ? data.at.value : this.at,
      coins: data.coins.present ? data.coins.value : this.coins,
      xp: data.xp.present ? data.xp.value : this.xp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerData(')
          ..write('ref: $ref, ')
          ..write('at: $at, ')
          ..write('coins: $coins, ')
          ..write('xp: $xp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ref, at, coins, xp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerData &&
          other.ref == this.ref &&
          other.at == this.at &&
          other.coins == this.coins &&
          other.xp == this.xp);
}

class LedgerCompanion extends UpdateCompanion<LedgerData> {
  final Value<String> ref;
  final Value<int> at;
  final Value<int> coins;
  final Value<int> xp;
  final Value<int> rowid;
  const LedgerCompanion({
    this.ref = const Value.absent(),
    this.at = const Value.absent(),
    this.coins = const Value.absent(),
    this.xp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerCompanion.insert({
    required String ref,
    required int at,
    this.coins = const Value.absent(),
    this.xp = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ref = Value(ref),
       at = Value(at);
  static Insertable<LedgerData> custom({
    Expression<String>? ref,
    Expression<int>? at,
    Expression<int>? coins,
    Expression<int>? xp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ref != null) 'ref': ref,
      if (at != null) 'at': at,
      if (coins != null) 'coins': coins,
      if (xp != null) 'xp': xp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerCompanion copyWith({
    Value<String>? ref,
    Value<int>? at,
    Value<int>? coins,
    Value<int>? xp,
    Value<int>? rowid,
  }) {
    return LedgerCompanion(
      ref: ref ?? this.ref,
      at: at ?? this.at,
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (coins.present) {
      map['coins'] = Variable<int>(coins.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerCompanion(')
          ..write('ref: $ref, ')
          ..write('at: $at, ')
          ..write('coins: $coins, ')
          ..write('xp: $xp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FogDatabase extends GeneratedDatabase {
  _$FogDatabase(QueryExecutor e) : super(e);
  $FogDatabaseManager get managers => $FogDatabaseManager(this);
  late final $CellsTable cells = $CellsTable(this);
  late final $DaysTable days = $DaysTable(this);
  late final $WalksTable walks = $WalksTable(this);
  late final $WaypointsTable waypoints = $WaypointsTable(this);
  late final $FindsTable finds = $FindsTable(this);
  late final $LedgerTable ledger = $LedgerTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cells,
    days,
    walks,
    waypoints,
    finds,
    ledger,
  ];
}

typedef $$CellsTableCreateCompanionBuilder = CellsCompanion Function({
  Value<int> id,
  required int at,
});
typedef $$CellsTableUpdateCompanionBuilder = CellsCompanion Function({
  Value<int> id,
  Value<int> at,
});

class $$CellsTableFilterComposer extends Composer<_$FogDatabase, $CellsTable> {
  $$CellsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CellsTableOrderingComposer
    extends Composer<_$FogDatabase, $CellsTable> {
  $$CellsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CellsTableAnnotationComposer
    extends Composer<_$FogDatabase, $CellsTable> {
  $$CellsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$CellsTableTableManager
    extends
        RootTableManager<
          _$FogDatabase,
          $CellsTable,
          Cell,
          $$CellsTableFilterComposer,
          $$CellsTableOrderingComposer,
          $$CellsTableAnnotationComposer,
          $$CellsTableCreateCompanionBuilder,
          $$CellsTableUpdateCompanionBuilder,
          (Cell, BaseReferences<_$FogDatabase, $CellsTable, Cell>),
          Cell,
          PrefetchHooks Function()
        > {
  $$CellsTableTableManager(_$FogDatabase db, $CellsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CellsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CellsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CellsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> at = const Value.absent(),
          }) => CellsCompanion(id: id, at: at),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int at,
          }) => CellsCompanion.insert(id: id, at: at),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CellsTable, Cell>(table),
                  BaseReferences<_$FogDatabase, $CellsTable, Cell>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CellsTableProcessedTableManager =
    ProcessedTableManager<
      _$FogDatabase,
      $CellsTable,
      Cell,
      $$CellsTableFilterComposer,
      $$CellsTableOrderingComposer,
      $$CellsTableAnnotationComposer,
      $$CellsTableCreateCompanionBuilder,
      $$CellsTableUpdateCompanionBuilder,
      (Cell, BaseReferences<_$FogDatabase, $CellsTable, Cell>),
      Cell,
      PrefetchHooks Function()
    >;
typedef $$DaysTableCreateCompanionBuilder = DaysCompanion Function({
  Value<int> day,
  Value<int> cells,
  Value<double> meters,
  Value<int> caches,
  Value<int> rare,
  Value<bool> beacon,
  Value<int> night,
  Value<int> dawn,
});
typedef $$DaysTableUpdateCompanionBuilder = DaysCompanion Function({
  Value<int> day,
  Value<int> cells,
  Value<double> meters,
  Value<int> caches,
  Value<int> rare,
  Value<bool> beacon,
  Value<int> night,
  Value<int> dawn,
});

class $$DaysTableFilterComposer extends Composer<_$FogDatabase, $DaysTable> {
  $$DaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cells => $composableBuilder(
    column: $table.cells,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get meters => $composableBuilder(
    column: $table.meters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caches => $composableBuilder(
    column: $table.caches,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rare => $composableBuilder(
    column: $table.rare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get beacon => $composableBuilder(
    column: $table.beacon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get night => $composableBuilder(
    column: $table.night,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dawn => $composableBuilder(
    column: $table.dawn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DaysTableOrderingComposer extends Composer<_$FogDatabase, $DaysTable> {
  $$DaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cells => $composableBuilder(
    column: $table.cells,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get meters => $composableBuilder(
    column: $table.meters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caches => $composableBuilder(
    column: $table.caches,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rare => $composableBuilder(
    column: $table.rare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get beacon => $composableBuilder(
    column: $table.beacon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get night => $composableBuilder(
    column: $table.night,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dawn => $composableBuilder(
    column: $table.dawn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DaysTableAnnotationComposer
    extends Composer<_$FogDatabase, $DaysTable> {
  $$DaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get cells =>
      $composableBuilder(column: $table.cells, builder: (column) => column);

  GeneratedColumn<double> get meters =>
      $composableBuilder(column: $table.meters, builder: (column) => column);

  GeneratedColumn<int> get caches =>
      $composableBuilder(column: $table.caches, builder: (column) => column);

  GeneratedColumn<int> get rare =>
      $composableBuilder(column: $table.rare, builder: (column) => column);

  GeneratedColumn<bool> get beacon =>
      $composableBuilder(column: $table.beacon, builder: (column) => column);

  GeneratedColumn<int> get night =>
      $composableBuilder(column: $table.night, builder: (column) => column);

  GeneratedColumn<int> get dawn =>
      $composableBuilder(column: $table.dawn, builder: (column) => column);
}

class $$DaysTableTableManager
    extends
        RootTableManager<
          _$FogDatabase,
          $DaysTable,
          Day,
          $$DaysTableFilterComposer,
          $$DaysTableOrderingComposer,
          $$DaysTableAnnotationComposer,
          $$DaysTableCreateCompanionBuilder,
          $$DaysTableUpdateCompanionBuilder,
          (Day, BaseReferences<_$FogDatabase, $DaysTable, Day>),
          Day,
          PrefetchHooks Function()
        > {
  $$DaysTableTableManager(_$FogDatabase db, $DaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> day = const Value.absent(),
                Value<int> cells = const Value.absent(),
                Value<double> meters = const Value.absent(),
                Value<int> caches = const Value.absent(),
                Value<int> rare = const Value.absent(),
                Value<bool> beacon = const Value.absent(),
                Value<int> night = const Value.absent(),
                Value<int> dawn = const Value.absent(),
              }) => DaysCompanion(
                day: day,
                cells: cells,
                meters: meters,
                caches: caches,
                rare: rare,
                beacon: beacon,
                night: night,
                dawn: dawn,
              ),
          createCompanionCallback:
              ({
                Value<int> day = const Value.absent(),
                Value<int> cells = const Value.absent(),
                Value<double> meters = const Value.absent(),
                Value<int> caches = const Value.absent(),
                Value<int> rare = const Value.absent(),
                Value<bool> beacon = const Value.absent(),
                Value<int> night = const Value.absent(),
                Value<int> dawn = const Value.absent(),
              }) => DaysCompanion.insert(
                day: day,
                cells: cells,
                meters: meters,
                caches: caches,
                rare: rare,
                beacon: beacon,
                night: night,
                dawn: dawn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DaysTable, Day>(table),
                  BaseReferences<_$FogDatabase, $DaysTable, Day>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DaysTableProcessedTableManager =
    ProcessedTableManager<
      _$FogDatabase,
      $DaysTable,
      Day,
      $$DaysTableFilterComposer,
      $$DaysTableOrderingComposer,
      $$DaysTableAnnotationComposer,
      $$DaysTableCreateCompanionBuilder,
      $$DaysTableUpdateCompanionBuilder,
      (Day, BaseReferences<_$FogDatabase, $DaysTable, Day>),
      Day,
      PrefetchHooks Function()
    >;
typedef $$WalksTableCreateCompanionBuilder = WalksCompanion Function({
  Value<int> id,
  required int start,
  required int end,
  Value<double> meters,
  Value<int> cells,
  Value<int> caches,
  Value<double> lat,
  Value<double> lon,
});
typedef $$WalksTableUpdateCompanionBuilder = WalksCompanion Function({
  Value<int> id,
  Value<int> start,
  Value<int> end,
  Value<double> meters,
  Value<int> cells,
  Value<int> caches,
  Value<double> lat,
  Value<double> lon,
});

class $$WalksTableFilterComposer extends Composer<_$FogDatabase, $WalksTable> {
  $$WalksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get meters => $composableBuilder(
    column: $table.meters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cells => $composableBuilder(
    column: $table.cells,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caches => $composableBuilder(
    column: $table.caches,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalksTableOrderingComposer
    extends Composer<_$FogDatabase, $WalksTable> {
  $$WalksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get meters => $composableBuilder(
    column: $table.meters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cells => $composableBuilder(
    column: $table.cells,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caches => $composableBuilder(
    column: $table.caches,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalksTableAnnotationComposer
    extends Composer<_$FogDatabase, $WalksTable> {
  $$WalksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get start =>
      $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<int> get end =>
      $composableBuilder(column: $table.end, builder: (column) => column);

  GeneratedColumn<double> get meters =>
      $composableBuilder(column: $table.meters, builder: (column) => column);

  GeneratedColumn<int> get cells =>
      $composableBuilder(column: $table.cells, builder: (column) => column);

  GeneratedColumn<int> get caches =>
      $composableBuilder(column: $table.caches, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);
}

class $$WalksTableTableManager
    extends
        RootTableManager<
          _$FogDatabase,
          $WalksTable,
          Walk,
          $$WalksTableFilterComposer,
          $$WalksTableOrderingComposer,
          $$WalksTableAnnotationComposer,
          $$WalksTableCreateCompanionBuilder,
          $$WalksTableUpdateCompanionBuilder,
          (Walk, BaseReferences<_$FogDatabase, $WalksTable, Walk>),
          Walk,
          PrefetchHooks Function()
        > {
  $$WalksTableTableManager(_$FogDatabase db, $WalksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> start = const Value.absent(),
                Value<int> end = const Value.absent(),
                Value<double> meters = const Value.absent(),
                Value<int> cells = const Value.absent(),
                Value<int> caches = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
              }) => WalksCompanion(
                id: id,
                start: start,
                end: end,
                meters: meters,
                cells: cells,
                caches: caches,
                lat: lat,
                lon: lon,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int start,
                required int end,
                Value<double> meters = const Value.absent(),
                Value<int> cells = const Value.absent(),
                Value<int> caches = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
              }) => WalksCompanion.insert(
                id: id,
                start: start,
                end: end,
                meters: meters,
                cells: cells,
                caches: caches,
                lat: lat,
                lon: lon,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WalksTable, Walk>(table),
                  BaseReferences<_$FogDatabase, $WalksTable, Walk>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalksTableProcessedTableManager =
    ProcessedTableManager<
      _$FogDatabase,
      $WalksTable,
      Walk,
      $$WalksTableFilterComposer,
      $$WalksTableOrderingComposer,
      $$WalksTableAnnotationComposer,
      $$WalksTableCreateCompanionBuilder,
      $$WalksTableUpdateCompanionBuilder,
      (Walk, BaseReferences<_$FogDatabase, $WalksTable, Walk>),
      Walk,
      PrefetchHooks Function()
    >;
typedef $$WaypointsTableCreateCompanionBuilder = WaypointsCompanion Function({
  Value<int> id,
  required int walk,
  required int at,
  required double lat,
  required double lon,
});
typedef $$WaypointsTableUpdateCompanionBuilder = WaypointsCompanion Function({
  Value<int> id,
  Value<int> walk,
  Value<int> at,
  Value<double> lat,
  Value<double> lon,
});

class $$WaypointsTableFilterComposer
    extends Composer<_$FogDatabase, $WaypointsTable> {
  $$WaypointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get walk => $composableBuilder(
    column: $table.walk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WaypointsTableOrderingComposer
    extends Composer<_$FogDatabase, $WaypointsTable> {
  $$WaypointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get walk => $composableBuilder(
    column: $table.walk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WaypointsTableAnnotationComposer
    extends Composer<_$FogDatabase, $WaypointsTable> {
  $$WaypointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get walk =>
      $composableBuilder(column: $table.walk, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);
}

class $$WaypointsTableTableManager
    extends
        RootTableManager<
          _$FogDatabase,
          $WaypointsTable,
          Waypoint,
          $$WaypointsTableFilterComposer,
          $$WaypointsTableOrderingComposer,
          $$WaypointsTableAnnotationComposer,
          $$WaypointsTableCreateCompanionBuilder,
          $$WaypointsTableUpdateCompanionBuilder,
          (Waypoint, BaseReferences<_$FogDatabase, $WaypointsTable, Waypoint>),
          Waypoint,
          PrefetchHooks Function()
        > {
  $$WaypointsTableTableManager(_$FogDatabase db, $WaypointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaypointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaypointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaypointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> walk = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
              }) => WaypointsCompanion(
                id: id,
                walk: walk,
                at: at,
                lat: lat,
                lon: lon,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int walk,
                required int at,
                required double lat,
                required double lon,
              }) => WaypointsCompanion.insert(
                id: id,
                walk: walk,
                at: at,
                lat: lat,
                lon: lon,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WaypointsTable, Waypoint>(table),
                  BaseReferences<_$FogDatabase, $WaypointsTable, Waypoint>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WaypointsTableProcessedTableManager =
    ProcessedTableManager<
      _$FogDatabase,
      $WaypointsTable,
      Waypoint,
      $$WaypointsTableFilterComposer,
      $$WaypointsTableOrderingComposer,
      $$WaypointsTableAnnotationComposer,
      $$WaypointsTableCreateCompanionBuilder,
      $$WaypointsTableUpdateCompanionBuilder,
      (Waypoint, BaseReferences<_$FogDatabase, $WaypointsTable, Waypoint>),
      Waypoint,
      PrefetchHooks Function()
    >;
typedef $$FindsTableCreateCompanionBuilder = FindsCompanion Function({
  required String key,
  required int at,
  required int rarity,
  Value<String> relic,
  Value<bool> duplicate,
  required int coins,
  required int xp,
  required double lat,
  required double lon,
  Value<bool> seen,
  Value<int> rowid,
});
typedef $$FindsTableUpdateCompanionBuilder = FindsCompanion Function({
  Value<String> key,
  Value<int> at,
  Value<int> rarity,
  Value<String> relic,
  Value<bool> duplicate,
  Value<int> coins,
  Value<int> xp,
  Value<double> lat,
  Value<double> lon,
  Value<bool> seen,
  Value<int> rowid,
});

class $$FindsTableFilterComposer extends Composer<_$FogDatabase, $FindsTable> {
  $$FindsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relic => $composableBuilder(
    column: $table.relic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get duplicate => $composableBuilder(
    column: $table.duplicate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coins => $composableBuilder(
    column: $table.coins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FindsTableOrderingComposer
    extends Composer<_$FogDatabase, $FindsTable> {
  $$FindsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relic => $composableBuilder(
    column: $table.relic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get duplicate => $composableBuilder(
    column: $table.duplicate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coins => $composableBuilder(
    column: $table.coins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FindsTableAnnotationComposer
    extends Composer<_$FogDatabase, $FindsTable> {
  $$FindsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<int> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<String> get relic =>
      $composableBuilder(column: $table.relic, builder: (column) => column);

  GeneratedColumn<bool> get duplicate =>
      $composableBuilder(column: $table.duplicate, builder: (column) => column);

  GeneratedColumn<int> get coins =>
      $composableBuilder(column: $table.coins, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<bool> get seen =>
      $composableBuilder(column: $table.seen, builder: (column) => column);
}

class $$FindsTableTableManager
    extends
        RootTableManager<
          _$FogDatabase,
          $FindsTable,
          Find,
          $$FindsTableFilterComposer,
          $$FindsTableOrderingComposer,
          $$FindsTableAnnotationComposer,
          $$FindsTableCreateCompanionBuilder,
          $$FindsTableUpdateCompanionBuilder,
          (Find, BaseReferences<_$FogDatabase, $FindsTable, Find>),
          Find,
          PrefetchHooks Function()
        > {
  $$FindsTableTableManager(_$FogDatabase db, $FindsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FindsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FindsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FindsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<int> rarity = const Value.absent(),
                Value<String> relic = const Value.absent(),
                Value<bool> duplicate = const Value.absent(),
                Value<int> coins = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
                Value<bool> seen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FindsCompanion(
                key: key,
                at: at,
                rarity: rarity,
                relic: relic,
                duplicate: duplicate,
                coins: coins,
                xp: xp,
                lat: lat,
                lon: lon,
                seen: seen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required int at,
                required int rarity,
                Value<String> relic = const Value.absent(),
                Value<bool> duplicate = const Value.absent(),
                required int coins,
                required int xp,
                required double lat,
                required double lon,
                Value<bool> seen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FindsCompanion.insert(
                key: key,
                at: at,
                rarity: rarity,
                relic: relic,
                duplicate: duplicate,
                coins: coins,
                xp: xp,
                lat: lat,
                lon: lon,
                seen: seen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FindsTable, Find>(table),
                  BaseReferences<_$FogDatabase, $FindsTable, Find>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FindsTableProcessedTableManager =
    ProcessedTableManager<
      _$FogDatabase,
      $FindsTable,
      Find,
      $$FindsTableFilterComposer,
      $$FindsTableOrderingComposer,
      $$FindsTableAnnotationComposer,
      $$FindsTableCreateCompanionBuilder,
      $$FindsTableUpdateCompanionBuilder,
      (Find, BaseReferences<_$FogDatabase, $FindsTable, Find>),
      Find,
      PrefetchHooks Function()
    >;
typedef $$LedgerTableCreateCompanionBuilder = LedgerCompanion Function({
  required String ref,
  required int at,
  Value<int> coins,
  Value<int> xp,
  Value<int> rowid,
});
typedef $$LedgerTableUpdateCompanionBuilder = LedgerCompanion Function({
  Value<String> ref,
  Value<int> at,
  Value<int> coins,
  Value<int> xp,
  Value<int> rowid,
});

class $$LedgerTableFilterComposer
    extends Composer<_$FogDatabase, $LedgerTable> {
  $$LedgerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coins => $composableBuilder(
    column: $table.coins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LedgerTableOrderingComposer
    extends Composer<_$FogDatabase, $LedgerTable> {
  $$LedgerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coins => $composableBuilder(
    column: $table.coins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LedgerTableAnnotationComposer
    extends Composer<_$FogDatabase, $LedgerTable> {
  $$LedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<int> get coins =>
      $composableBuilder(column: $table.coins, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);
}

class $$LedgerTableTableManager
    extends
        RootTableManager<
          _$FogDatabase,
          $LedgerTable,
          LedgerData,
          $$LedgerTableFilterComposer,
          $$LedgerTableOrderingComposer,
          $$LedgerTableAnnotationComposer,
          $$LedgerTableCreateCompanionBuilder,
          $$LedgerTableUpdateCompanionBuilder,
          (LedgerData, BaseReferences<_$FogDatabase, $LedgerTable, LedgerData>),
          LedgerData,
          PrefetchHooks Function()
        > {
  $$LedgerTableTableManager(_$FogDatabase db, $LedgerTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ref = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<int> coins = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerCompanion(
                ref: ref,
                at: at,
                coins: coins,
                xp: xp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ref,
                required int at,
                Value<int> coins = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerCompanion.insert(
                ref: ref,
                at: at,
                coins: coins,
                xp: xp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LedgerTable, LedgerData>(table),
                  BaseReferences<_$FogDatabase, $LedgerTable, LedgerData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LedgerTableProcessedTableManager =
    ProcessedTableManager<
      _$FogDatabase,
      $LedgerTable,
      LedgerData,
      $$LedgerTableFilterComposer,
      $$LedgerTableOrderingComposer,
      $$LedgerTableAnnotationComposer,
      $$LedgerTableCreateCompanionBuilder,
      $$LedgerTableUpdateCompanionBuilder,
      (LedgerData, BaseReferences<_$FogDatabase, $LedgerTable, LedgerData>),
      LedgerData,
      PrefetchHooks Function()
    >;

class $FogDatabaseManager {
  final _$FogDatabase _db;
  $FogDatabaseManager(this._db);
  $$CellsTableTableManager get cells =>
      $$CellsTableTableManager(_db, _db.cells);
  $$DaysTableTableManager get days => $$DaysTableTableManager(_db, _db.days);
  $$WalksTableTableManager get walks =>
      $$WalksTableTableManager(_db, _db.walks);
  $$WaypointsTableTableManager get waypoints =>
      $$WaypointsTableTableManager(_db, _db.waypoints);
  $$FindsTableTableManager get finds =>
      $$FindsTableTableManager(_db, _db.finds);
  $$LedgerTableTableManager get ledger =>
      $$LedgerTableTableManager(_db, _db.ledger);
}
