import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapdefog/explore/explorer.dart';
import 'package:mapdefog/explore/fix.dart';

/// Ref-counted location stream shared by map and background walk.
class LocationFeed {
  LocationFeed(this.explorer);

  final Explorer explorer;
  int _refs = 0;
  StreamSubscription<Position>? _sub;

  /// Check only — does not prompt. Matches Android [LocationFeed.permitted].
  Future<bool> permitted() async {
    final perm = await Geolocator.checkPermission();
    return perm == LocationPermission.always || perm == LocationPermission.whileInUse;
  }

  /// Prompt if denied. Returns whether location is usable afterward.
  Future<bool> requestPermission() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always || perm == LocationPermission.whileInUse;
  }

  Future<void> acquire() async {
    _refs++;
    if (_refs > 1) return;
    await _start();
  }

  Future<void> release() async {
    if (_refs == 0) return;
    _refs--;
    if (_refs == 0) {
      await _sub?.cancel();
      _sub = null;
    }
  }

  /// After permission is granted while someone already holds the feed.
  Future<void> restart() async {
    if (_refs == 0) return;
    await _sub?.cancel();
    _sub = null;
    await _start();
  }

  Future<void> _start() async {
    if (!await permitted()) return;

    // Seed last-known if fresher than 10 minutes (Android LocationFeed).
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        final age = DateTime.now().millisecondsSinceEpoch - last.timestamp.millisecondsSinceEpoch;
        if (age >= 0 && age < 10 * 60 * 1000) {
          _deliver(last);
        }
      }
    } on Exception catch (e) {
      // Only a head start; the stream below delivers fixes regardless.
      debugPrint('Last known position unavailable: $e');
    }

    _sub =
        Geolocator.getPositionStream(locationSettings: walkLocationSettings(defaultTargetPlatform))
            .listen(
              _deliver,
              // E.g. location turned off mid-walk; fixes resume once it is back on.
              onError: (Object e) => debugPrint('Location stream error: $e'),
            );
  }

  /// Settings for the walk stream, which must keep running with the screen
  /// off. Only a walk acquires the feed, so this never tracks in the
  /// background otherwise.
  @visibleForTesting
  static LocationSettings walkLocationSettings(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
        // Plain LocationSettings sends no allowBackgroundLocationUpdates, which
        // the iOS plugin reads as NO: fixes stop as soon as the screen locks.
        // Needs the `location` UIBackgroundMode (ios/Runner/Info.plist).
        return AppleSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
          activityType: ActivityType.fitness,
          allowBackgroundLocationUpdates: true,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
        );
      default:
        // Android keeps delivering while the location foreground service
        // (WalkTask) runs.
        return const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 0);
    }
  }

  void _deliver(Position p) {
    explorer.submit(
      Fix(
        lat: p.latitude,
        lon: p.longitude,
        accuracy: p.accuracy,
        time: p.timestamp.millisecondsSinceEpoch,
        bearing: p.heading.isNaN ? null : p.heading,
        // Geolocator has no LocationManager provider. Approximate Android
        // `provider == GPS_PROVIDER`: satellite-grade fixes only; coarse /
        // network-quality and mocked fixes move the dot but do not walk.
        gps: !p.isMocked && p.accuracy > 0 && p.accuracy < 100,
        speed: p.speed.isNaN ? null : p.speed,
      ),
    );
  }
}
