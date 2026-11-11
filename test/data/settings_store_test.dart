import 'package:flutter_test/flutter_test.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<SettingsStore> store() async => SettingsStore(await SharedPreferences.getInstance());

  test('starts from the defaults', () async {
    final s = (await store()).now();
    expect(s.onboarded, isFalse);
    expect(s.units, UnitsPref.metric);
    expect(s.language, LanguagePref.system);
    expect(s.owned, contains('mist'));
  });

  test('updates persist and notify listeners', () async {
    final first = await store();
    final seen = <Settings>[];
    first.addListener(seen.add);

    await first.update(
      (s) => s.copyWith(units: UnitsPref.imperial, language: LanguagePref.uk, shielded: {3, 5}),
    );

    expect(seen.single.units, UnitsPref.imperial);
    final reread = (await store()).now();
    expect(reread.units, UnitsPref.imperial);
    expect(reread.language, LanguagePref.uk);
    expect(reread.shielded, {3, 5});
  });

  test('a removed listener is not called', () async {
    final s = await store();
    var calls = 0;
    void listener(Settings _) => calls++;
    s
      ..addListener(listener)
      ..removeListener(listener);
    await s.update((x) => x.copyWith(haptics: false));
    expect(calls, 0);
  });

  group('with another isolate writing', () {
    // The walk service has its own cache; it writes straight to storage.
    Future<void> otherIsolateWrites(String key, Object value) =>
        SharedPreferencesStorePlatform.instance.setValue(
          switch (value) {
            bool() => 'Bool',
            int() => 'Int',
            double() => 'Double',
            _ => 'String',
          },
          'flutter.$key',
          value,
        );

    test('an update keeps what the other side wrote', () async {
      final s = await store();
      s.now(); // warm the cache
      await otherIsolateWrites('beacon_day', 777);

      await s.update((x) => x.copyWith(units: UnitsPref.imperial));

      final after = s.now();
      expect(after.units, UnitsPref.imperial);
      expect(after.beacon.day, 777);
    });

    test('refresh picks up the other side and notifies', () async {
      final s = await store();
      final seen = <Settings>[];
      s.addListener(seen.add);
      await otherIsolateWrites('walking', true);

      await s.refresh();

      expect(seen.single.walking, isTrue);
      expect(s.now().walking, isTrue);
    });
  });
}
