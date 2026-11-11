import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Color, Locale;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:mapdefog/explore/walk_messages.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/notify/walk_service.dart';

/// The walk's foreground service and its notification.
///
/// On Android the service also tracks the walk ([WalkService]), so it keeps
/// recording when the app is gone. On iOS its "service" only runs for short
/// bursts, so the app tracks with background location updates instead.
class WalkTask {
  WalkTask._();

  static const _brand = 'MapDefog';
  static const _stillChartingKey = 'notifyStillCharting';
  static const _statsKey = 'notifyWalkStats';
  static const _langKey = 'notifyLanguage';
  static const stopAction = 'stop_walk';

  static AppLocalizations _content = lookupAppLocalizations(const Locale('en'));
  static var _portReady = false;

  /// Whether walks are tracked by the service rather than by the app.
  static bool get tracksInService => Platform.isAndroid;

  /// Receives the service's [WalkMessage]s in the app.
  static void Function(Object data)? onMessage;

  /// Sends a [WalkMessage] to the service.
  static void send(String type, [Map<String, Object?> body = const {}]) =>
      FlutterForegroundTask.sendDataToTask(WalkMessage.of(type, body));

  /// Call once from the UI isolate before [start].
  static void ensureCommunication() {
    if (_portReady) return;
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);
    _portReady = true;
  }

  static void _onTaskData(Object data) => onMessage?.call(data);

  /// Binds notification copy. The service handler runs in a separate isolate.
  static Future<void> bindContent(AppLocalizations c, {String? langTag}) async {
    _content = c;
    await FlutterForegroundTask.saveData(key: _stillChartingKey, value: c.notifyStillCharting);
    if (langTag != null) await FlutterForegroundTask.saveData(key: _langKey, value: langTag);
    if (await FlutterForegroundTask.isRunningService) {
      final stats = await FlutterForegroundTask.getData<String>(key: _statsKey);
      await FlutterForegroundTask.updateService(
        notificationTitle: _brand,
        notificationText: stats ?? c.notifyCharting,
      );
    }
  }

  static Future<void> init({AppLocalizations? content, String langTag = 'en'}) async {
    ensureCommunication();
    await FlutterForegroundTask.saveData(key: _langKey, value: langTag);
    if (content != null) {
      _content = content;
      await FlutterForegroundTask.saveData(
        key: _stillChartingKey,
        value: content.notifyStillCharting,
      );
    }
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'walk_v1_$langTag',
        channelName: _content.notifyChannelJourney,
        channelDescription: _content.notifyJourneyDescription,
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      // On iOS the plugin's notification is an ordinary one: every update
      // pops a new banner, and it stays behind when iOS ends the app. The
      // blue location indicator already shows that a walk is recording.
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      // The service outlives the app (that is the point: it tracks), but it
      // is not brought back after a reboot, an update or a system kill;
      // `walking` stays saved, and the app resumes the walk when opened.
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(10000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowAutoRestart: false,
        stopWithTask: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> start() async {
    ensureCommunication();
    if (Platform.isAndroid) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    if (await FlutterForegroundTask.isRunningService) return;
    // Stats of the previous walk must not show on the new one.
    await FlutterForegroundTask.removeData(key: _statsKey);
    await FlutterForegroundTask.startService(
      serviceId: 1001,
      notificationTitle: _brand,
      notificationText: _content.notifyCharting,
      notificationIcon: const NotificationIcon(
        metaDataName: 'com.mapdefog.NOTIFICATION_ICON',
        backgroundColor: Color(0xFFC9A24E),
      ),
      callback: startCallback,
      notificationButtons: [NotificationButton(id: stopAction, text: _content.stopWalk)],
    );
  }

  /// The app's resolved language, for the service: a background engine may
  /// not know the device's language.
  static Future<String?> savedLanguage() => FlutterForegroundTask.getData<String>(key: _langKey);

  /// Shows the walk's stats in the notification. [content] defaults to the
  /// app's bound copy; the service isolate passes its own.
  static Future<void> updateLive({
    AppLocalizations? content,
    required int cells,
    required String distanceLabel,
    required bool hasWalk,
  }) async {
    if (!await FlutterForegroundTask.isRunningService) return;
    final c = content ?? _content;
    final text = hasWalk ? c.notifyWalkStats(cells, distanceLabel) : c.notifyCharting;
    await FlutterForegroundTask.saveData(key: _statsKey, value: text);
    await FlutterForegroundTask.updateService(notificationTitle: _brand, notificationText: text);
  }

  static Future<void> stop() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(_WalkHandler());
}

class _WalkHandler extends TaskHandler {
  /// Completes with the running service, or null when nothing is tracked
  /// here (iOS, or no walk in progress).
  Future<WalkService?> _service = Future.value();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    if (!WalkTask.tracksInService) return;
    _service = WalkService.start().catchError((Object e, StackTrace st) {
      // Without a working service nothing records: stop rather than show a
      // notification that says otherwise. The walk stays saved, and the app
      // starts it again when opened.
      debugPrint('WalkService failed to start: $e\n$st');
      return null;
    });
    if (await _service == null) await FlutterForegroundTask.stopService();
  }

  @override
  void onReceiveData(Object data) {
    _service.then((s) => s?.onMessage(data));
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _refresh();
  }

  Future<void> _refresh() async {
    final text =
        await FlutterForegroundTask.getData<String>(key: WalkTask._statsKey) ??
        await FlutterForegroundTask.getData<String>(key: WalkTask._stillChartingKey) ??
        lookupAppLocalizations(const Locale('en')).notifyStillCharting;
    await FlutterForegroundTask.updateService(
      notificationTitle: WalkTask._brand,
      notificationText: text,
    );
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id != WalkTask.stopAction) return;
    _service.then((s) async {
      if (s != null) return s.stopFromNotification();
      // Not tracking here: let the app stop the walk.
      FlutterForegroundTask.sendDataToMain(WalkMessage.of(WalkMessage.stopped));
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await (await _service)?.dispose();
  }
}
