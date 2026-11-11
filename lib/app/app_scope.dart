import 'dart:async';

import 'package:drift/drift.dart' show TableUpdate;
import 'package:flutter/material.dart';
import 'package:mapdefog/data/database.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/domain/fog.dart';
import 'package:mapdefog/explore/explorer.dart';
import 'package:mapdefog/explore/location_feed.dart';
import 'package:mapdefog/explore/walk_messages.dart';
import 'package:mapdefog/notify/walk_task.dart';

class AppContainer {
  AppContainer({
    required this.db,
    required this.settings,
    required this.fog,
    required this.explorer,
    required this.feed,
  }) {
    settings.addListener((_) => settingsTick.value++);
    fog.addListener(() => fogTick.value++);
    WalkTask.onMessage = handleServiceMessage;
    settings.onWrite = () {
      if (serviceTracking) WalkTask.send(WalkMessage.settings);
    };
  }

  final FogDatabase db;
  final SettingsStore settings;
  final FogStore fog;
  final Explorer explorer;
  final LocationFeed feed;

  final ValueNotifier<int> settingsTick = ValueNotifier(0);
  final ValueNotifier<int> fogTick = ValueNotifier(0);
  final ValueNotifier<String?> pendingRoute = ValueNotifier(null);

  Listenable get settingsListenable => settingsTick;

  /// Notifies when settings or fog exploration changes (for [GameData] rebuilds).
  Listenable get dataListenable => Listenable.merge([settingsTick, fogTick]);

  /// Whether the Android walk service is tracking; the app then only mirrors
  /// it (see [Explorer.mirrorLive]) instead of tracking itself.
  bool get serviceTracking => WalkTask.tracksInService && settings.now().walking;

  bool _visible = true;
  bool get visible => _visible;
  set visible(bool value) {
    _visible = value;
    if (serviceTracking) WalkTask.send(WalkMessage.visible, {'v': value});
  }

  /// Starts a walk, or reconnects to the one the service is still tracking.
  Future<void> startWalk() async {
    if (!await feed.requestPermission()) return;
    await settings.update((s) => s.copyWith(walking: true));
    settingsTick.value++;
    if (!WalkTask.tracksInService) await feed.acquire();
    await WalkTask.start();
    if (WalkTask.tracksInService) WalkTask.send(WalkMessage.hello, {'v': _visible});
  }

  Future<void> stopWalk() async {
    await settings.update((s) => s.copyWith(walking: false));
    settingsTick.value++;
    await WalkTask.stop();
    if (!WalkTask.tracksInService) await feed.release();
  }

  /// Reloads everything after a backup import, here and in the service.
  Future<void> reloadAll() async {
    await explorer.reloadAll();
    if (serviceTracking) WalkTask.send(WalkMessage.reload);
  }

  /// Debug: walk to a point. The service does it while it tracks, so the two
  /// explorers never record at once.
  void simulateTo(double lat, double lon) {
    if (serviceTracking) {
      WalkTask.send(WalkMessage.simulate, {'lat': lat, 'lon': lon});
    } else {
      explorer.simulateTo(lat, lon);
    }
  }

  /// Applies a [WalkMessage] from the service.
  @visibleForTesting
  Future<void> handleServiceMessage(Object data) async {
    final m = data is Map ? data : const {};
    switch (WalkMessage.typeOf(data)) {
      case WalkMessage.live:
        explorer.mirrorLive(WalkCodec.toLive(m['live']! as Map));
      case WalkMessage.cells:
        explorer.mirrorCells((m['ids']! as List).cast<int>());
      case WalkMessage.event:
        explorer.mirrorEvent(WalkCodec.toEvent(m['e']! as Map));
      case WalkMessage.tables:
        // The service wrote through its own connection; rerun our queries.
        db.notifyUpdates({for (final n in (m['names']! as List).cast<String>()) TableUpdate(n)});
      case WalkMessage.settings:
        await settings.refresh();
      case WalkMessage.stopped:
        if (WalkTask.tracksInService) {
          await settings.refresh();
        } else {
          await stopWalk();
        }
      default:
        debugPrint('AppContainer: ignored message $data');
    }
  }

  void openRoute(String route) => pendingRoute.value = route;

  void notifySettings() => settingsTick.value++;
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.container, required super.child});

  final AppContainer container;

  static AppContainer of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.container;

  @override
  bool updateShouldNotify(AppScope oldWidget) => oldWidget.container != container;
}
