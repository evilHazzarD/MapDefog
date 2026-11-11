import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapdefog/explore/location_feed.dart';

void main() {
  test('iOS walks keep receiving fixes with the screen locked', () {
    final s = LocationFeed.walkLocationSettings(TargetPlatform.iOS);

    expect(s, isA<AppleSettings>());
    final json = s.toJson();
    expect(json['allowBackgroundLocationUpdates'], isTrue);
    expect(json['pauseLocationUpdatesAutomatically'], isFalse);
    expect(json['showBackgroundLocationIndicator'], isTrue);
  });

  test('Android walks use plain best-accuracy settings', () {
    final s = LocationFeed.walkLocationSettings(TargetPlatform.android);

    expect(s.accuracy, LocationAccuracy.best);
    expect(s.distanceFilter, 0);
  });
}
