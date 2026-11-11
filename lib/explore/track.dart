import 'dart:math' as math;

import 'package:mapdefog/explore/fix.dart';
import 'package:mapdefog/geo/grid.dart';

class Step {
  const Step({
    required this.lat,
    required this.lon,
    required this.accuracy,
    required this.time,
    this.bearing,
    this.from,
    required this.meters,
    required this.fast,
  });

  final double lat;
  final double lon;
  final double accuracy;
  final int time;
  final double? bearing;
  final (double, double)? from;
  final double meters;
  final bool fast;
}

/// Cleans raw positions before they touch the map (Kalman + vehicle gate).
class Track {
  double _lat = 0;
  double _lon = 0;
  double _variance = -1;
  int _time = 0;
  int _lastGps = 0;
  int _rejects = 0;
  int _fastHits = 0;
  double _anchorLat = 0;
  double _anchorLon = 0;
  int _anchorTime = 0;
  bool _hasAnchor = false;

  static const maxAccuracy = 35.0;
  static const walkNoise = 2.5;
  static const maxJumpSpeed = 12.0;
  static const minStep = 10.0;
  static const stillSpeed = 0.4;
  static const stillDrift = 25.0;
  static const fastHitsNeeded = 3;
  static const gapMs = 3 * 60 * 1000;
  static const gpsFreshMs = 30 * 1000;
  static const maxSpeed = 8.5; // Explorer.MAX_SPEED

  Step? add(Fix f) {
    if (f.simulated) return _simulated(f);
    if (!f.gps) return null;
    if (f.accuracy > maxAccuracy) return null;
    _lastGps = f.time;
    final acc = math.max(f.accuracy, 3.0);

    if (_variance < 0 || f.time - _time > gapMs) {
      _reset(f, acc);
      return Step(
        lat: _lat,
        lon: _lon,
        accuracy: f.accuracy,
        time: f.time,
        bearing: f.bearing,
        from: null,
        meters: 0,
        fast: false,
      );
    }

    final dt = math.max(0.0, (f.time - _time) / 1000.0);
    final reported = f.speed;
    final fastNow = reported != null && reported > maxSpeed;
    final jump = Grid.distance(_lat, _lon, f.lat, f.lon);
    final possible = math.sqrt(_variance) + acc + dt * maxJumpSpeed + 15;
    if (jump > possible && !fastNow) {
      _rejects++;
      if (_rejects < 3) return null;
      final fast = dt > 0 && jump / dt > maxSpeed;
      _reset(f, acc);
      if (fast) _fastHits = fastHitsNeeded;
      return Step(
        lat: _lat,
        lon: _lon,
        accuracy: f.accuracy,
        time: f.time,
        bearing: f.bearing,
        from: null,
        meters: 0,
        fast: fast,
      );
    }
    _rejects = 0;

    _variance += dt * walkNoise * walkNoise;
    final k = _variance / (_variance + acc * acc);
    _lat += k * (f.lat - _lat);
    _lon += k * (f.lon - _lon);
    _variance *= (1 - k);
    _time = f.time;

    final step = Grid.distance(_anchorLat, _anchorLon, _lat, _lon);
    final stepDt = math.max(1.0, (f.time - _anchorTime) / 1000.0);
    final bool? fastEvidence;
    if (reported != null) {
      fastEvidence = fastNow;
    } else if (step >= _minStep(acc, false)) {
      fastEvidence = step / stepDt > maxSpeed;
    } else {
      fastEvidence = null;
    }
    if (fastEvidence != null) {
      _fastHits = fastEvidence ? _fastHits + 1 : 0;
    }
    final fast = _fastHits >= fastHitsNeeded || (fastNow && reported > maxSpeed * 1.5);

    if (fast) {
      _moveAnchor(f.time);
      return Step(
        lat: _lat,
        lon: _lon,
        accuracy: f.accuracy,
        time: f.time,
        bearing: f.bearing,
        from: null,
        meters: 0,
        fast: true,
      );
    }

    final still = reported != null && reported < stillSpeed && step < stillDrift;
    if (step < _minStep(acc, reported != null) || still) {
      return Step(
        lat: _lat,
        lon: _lon,
        accuracy: f.accuracy,
        time: f.time,
        bearing: f.bearing,
        from: null,
        meters: 0,
        fast: false,
      );
    }
    final from = (_anchorLat, _anchorLon);
    _moveAnchor(f.time);
    return Step(
      lat: _lat,
      lon: _lon,
      accuracy: f.accuracy,
      time: f.time,
      bearing: f.bearing,
      from: from,
      meters: step,
      fast: false,
    );
  }

  bool hasGps(int now) => now - _lastGps < gpsFreshMs;

  Step _simulated(Fix f) {
    final had = _hasAnchor;
    final from = (_anchorLat, _anchorLon);
    _lat = f.lat;
    _lon = f.lon;
    _variance = 25.0;
    _time = f.time;
    _moveAnchor(f.time);
    final meters = had ? Grid.distance(from.$1, from.$2, _lat, _lon) : 0.0;
    return Step(
      lat: _lat,
      lon: _lon,
      accuracy: f.accuracy,
      time: f.time,
      bearing: f.bearing,
      from: had && meters > 0 ? from : null,
      meters: meters,
      fast: false,
    );
  }

  void _reset(Fix f, double acc) {
    _lat = f.lat;
    _lon = f.lon;
    _variance = acc * acc;
    _time = f.time;
    _rejects = 0;
    _fastHits = 0;
    _moveAnchor(f.time);
  }

  void _moveAnchor(int t) {
    _anchorLat = _lat;
    _anchorLon = _lon;
    _anchorTime = t;
    _hasAnchor = true;
  }

  double _minStep(double acc, bool doppler) => doppler
      ? math.max(minStep, math.min(acc, 40.0) * 0.6)
      : math.max(minStep * 1.5, math.min(acc, 40.0) * 1.2);
}
