import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapdefog/data/models.dart';
import 'package:mapdefog/domain/caches.dart';
import 'package:mapdefog/domain/rarity.dart';
import 'package:mapdefog/explore/explorer.dart';
import 'package:mapdefog/explore/fix.dart';
import 'package:mapdefog/explore/walk_messages.dart';

/// Sends [value] through a real port, as the service does.
Future<Object?> roundTrip(Object? value) async {
  final port = ReceivePort();
  port.sendPort.send(value);
  final got = await port.first;
  port.close();
  return got;
}

void main() {
  const fix = Fix(
    lat: 50.087,
    lon: 14.421,
    accuracy: 6.5,
    time: 1700000000000,
    bearing: 90.0,
    speed: 1.4,
  );
  const walk = WalkRow(
    id: 7,
    start: 1,
    end: 2,
    meters: 830.5,
    cells: 12,
    caches: 1,
    lat: 50.0,
    lon: 14.0,
  );

  test('live state survives the trip', () async {
    const live = Live(fix: fix, walk: walk, trail: [(50.0, 14.0), (50.1, 14.1)], tooFast: true);
    final got = WalkCodec.toLive((await roundTrip(WalkCodec.live(live)))! as Map);

    expect(got.fix!.lat, fix.lat);
    expect(got.fix!.bearing, 90.0);
    expect(got.fix!.speed, 1.4);
    expect(got.walk!.id, 7);
    expect(got.walk!.meters, 830.5);
    expect(got.trail, live.trail);
    expect(got.tooFast, isTrue);
  });

  test('an empty live state survives the trip', () async {
    final got = WalkCodec.toLive((await roundTrip(WalkCodec.live(const Live())))! as Map);
    expect(got.fix, isNull);
    expect(got.walk, isNull);
    expect(got.trail, isEmpty);
  });

  test('every game event survives the trip', () async {
    final events = <GameEvent>[
      OpenedEvent(
        const FindRow(
          key: 'c:1:a',
          at: 3,
          rarity: 2,
          relic: 'compass',
          coins: 40,
          xp: 50,
          lat: 50,
          lon: 14,
        ),
      ),
      NewSectorEvent(12),
      MilestoneEvent(12, 0.15, 50),
      BeaconEvent(),
      NearEvent(const Cache('c:1:b', 50.1, 14.1, Rarity.epic), 120),
    ];
    for (final e in events) {
      final got = WalkCodec.toEvent((await roundTrip(WalkCodec.event(e)))! as Map);
      expect(got.runtimeType, e.runtimeType);
      expect(WalkCodec.event(got), WalkCodec.event(e));
    }
  });

  test('messages carry their type', () {
    final m = WalkMessage.of(WalkMessage.visible, {'v': true});
    expect(WalkMessage.typeOf(m), WalkMessage.visible);
    expect(WalkMessage.typeOf('stop_walk'), isNull);
  });
}
