import 'dart:ui' show VoidCallback;

/// Main tabs and in-app navigation targets (Compose `Tab`, `Go`, `MapFocus`).
enum FogTab { map, quests, treasury, journal }

class MapFocus {
  const MapFocus(this.lat, this.lon, this.zoom);
  final double lat;
  final double lon;
  final double zoom;
}

class FogGo {
  FogGo({
    required this.openSettings,
    required this.openDeeds,
    required this.openWalks,
    required this.openWalk,
    required this.selectTab,
    required this.back,
  });

  final VoidCallback openSettings;
  final VoidCallback openDeeds;
  final VoidCallback openWalks;
  final void Function(int id) openWalk;
  final void Function(FogTab tab) selectTab;
  final VoidCallback back;
}
