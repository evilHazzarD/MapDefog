# MapDefog

**Your city, hidden in mist. Walk to reveal it.**

A real-world exploration game driven by your daily walks. The map starts covered
in fog; every street you walk is revealed for good. Along the way there are
weekly treasure chests, a daily shrine, 36 relics, 160 deeds, quests and streaks.
No ads, no account, and all data stays on the device.


## Highlights

- **Fog of war on a real map.** The world is a Web Mercator grid of ~20–40 m
  cells. Revealed cells live in a custom open-addressing `LongSet` and are drawn
  as a custom `flutter_map` layer, with coarser zoom levels aggregated on the fly.
- **Background walks.** On Android the walk is tracked inside a location
  foreground service with its own isolate, database connection and game
  engine, so it keeps recording after the app is swiped away; the app mirrors
  it over isolate messages while open. On iOS, background location updates
  keep the app tracking with the screen off. GPS noise and vehicle speeds are
  filtered out before cells are revealed.
- **Deterministic game world.** Chests, shrines and quests are seeded from the
  week/day, so they are identical across reinstalls and match the Android app.
- **Offline-first storage.** Drift (SQLite) on a background isolate, versioned
  schema snapshots, and JSON backup import/export that is compatible with the
  Android app.
- **Localisation.** All UI and game copy in ARB files via `gen-l10n`, including
  ICU plurals for Russian and Ukrainian, with a test that every string exists in
  every language.

## Getting started

```bash
flutter pub get
flutter run
```

In debug builds, long-press the map to simulate walking to that point.

## Project structure

```
lib/
  app/       AppContainer (dependency wiring) and AppScope
  geo/       Web Mercator grid, LongSet
  domain/    Fog, caches, quests, relics, progress (pure Dart, no Flutter)
  data/      Drift database, settings, backup
  explore/   Location feed, track filtering, Explorer (turns fixes into progress)
  notify/    Walk foreground task, alerts, daily reminders
  l10n/      ARB files and generated localisations
  ui/        Map and fog layer, tabs, onboarding, settings, theme
```

## Development

```bash
flutter analyze                     # strict lints, see analysis_options.yaml
dart format lib test
flutter test                        # unit, database and widget tests
```

Code generation:

```bash
dart run build_runner build         # Drift database code
flutter gen-l10n                    # after editing lib/l10n/*.arb
```

When changing a table, bump `schemaVersion` in `lib/data/database.dart`, run
`dart run drift_dev make-migrations` and add the upgrade step; schema snapshots
live in `drift_schemas/`.

CI (`.github/workflows/ci.yml`) checks generated code, formatting, analysis and
tests, and builds an Android APK.

### Release signing (Android)

Copy `android/key.properties.example` to `android/key.properties` and fill in
your upload keystore. Without it, release builds are signed with the debug key.

## Platform notes

- **Android 8+** (minSdk 26): location foreground service for walks.
- **iOS**: "Always" location and background modes so walks continue with the
  screen off.
- **Map tiles**: OpenStreetMap via `flutter_map`. Heavy use should switch to a
  tile provider that allows it, per the
  [OSM tile usage policy](https://operations.osmfoundation.org/policies/tiles/).

## License

[MIT](LICENSE).
