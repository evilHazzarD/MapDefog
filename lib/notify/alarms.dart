import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mapdefog/data/database.dart';
import 'package:mapdefog/data/settings_store.dart';
import 'package:mapdefog/domain/progress.dart';
import 'package:mapdefog/domain/rarity.dart';
import 'package:mapdefog/explore/explorer.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/l10n/game_text.dart';
import 'package:mapdefog/l10n/locale_resolve.dart';
import 'package:mapdefog/util/days.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

typedef RouteHandler = void Function(String route);

/// One booked reminder: when it fires, its day number, and the streak it
/// mentions (0 for none).
@immutable
class RemindSlot {
  const RemindSlot(this.at, this.day, this.streak);
  final DateTime at;
  final int day;
  final int streak;

  @override
  String toString() => 'RemindSlot($at, day $day, streak $streak)';
}

class Alarms {
  Alarms._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static RouteHandler? onRoute;
  static FogDatabase? _db;

  static String _langTag(Settings s) => resolveAppLocale(s).languageCode;

  static String _remindChannel(Settings s) => 'remind_v1_${_langTag(s)}';

  static String _alertsChannel(Settings s) => 'alerts_v1_${_langTag(s)}';

  static void bind({required FogDatabase db, RouteHandler? routeHandler}) {
    _db = db;
    onRoute = routeHandler;
    flushLaunchRoute();
  }

  static Future<void> init() async {
    if (_ready) return;
    tz.initializeTimeZones();
    // Schedule against absolute instants from local DateTime (device zone),
    // so we do not depend on tz.local being set to a named IANA zone.
    const android = AndroidInitializationSettings('@drawable/ic_notification');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (r) {
        final route = r.payload;
        if (route != null && route.isNotEmpty) onRoute?.call(route);
      },
    );
    // Cold-start: notification that launched the app.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final response = launch?.notificationResponse;
    if (launch?.didNotificationLaunchApp == true &&
        response?.payload != null &&
        response!.payload!.isNotEmpty) {
      // Defer until bind() has set onRoute.
      _pendingLaunchRoute = response.payload;
    }
    _ready = true;
  }

  static String? _pendingLaunchRoute;

  /// Deliver any cold-start payload once [onRoute] is bound.
  static void flushLaunchRoute() {
    final route = _pendingLaunchRoute;
    if (route == null) return;
    _pendingLaunchRoute = null;
    onRoute?.call(route);
  }

  static Future<void> onEvent(
    GameEvent e, {
    required bool visible,
    required Settings settings,
  }) async {
    if (visible) return;
    await init();
    final c = lookupAppLocalizations(resolveAppLocale(settings));
    final channel = _alertsChannel(settings);

    switch (e) {
      case NearEvent(:final cache, :final meters):
        if (!settings.nearbyAlerts) return;
        final quiet = cache.rarity == Rarity.common;
        await _show(
          id: 3,
          title: c.notifyNearTitle(c.rarity(cache.rarity)),
          body: c.notifyAboutMeters(meters),
          channelId: channel,
          channelName: c.notifyChannelNearby,
          route: 'map',
          quiet: quiet,
        );
      case OpenedEvent(:final find):
        final rarity = Rarity.values[find.rarity.clamp(0, Rarity.values.length - 1)];
        await _show(
          id: 3,
          title: c.notifyOpenedTitle(c.rarity(rarity)),
          body: c.notifyOpenedCoins(find.coins),
          channelId: channel,
          channelName: c.notifyChannelNearby,
          route: 'map',
        );
      case BeaconEvent():
        await _show(
          id: 4,
          title: c.notifyShrineReached,
          body: c.notifyShrineBody,
          channelId: channel,
          channelName: c.notifyChannelNearby,
          route: 'map',
        );
      default:
        return;
    }
  }

  static Future<void> _show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required String route,
    bool quiet = false,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      payload: route,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: quiet ? Importance.low : Importance.defaultImportance,
          playSound: !quiet,
          enableVibration: !quiet,
        ),
        iOS: DarwinNotificationDetails(presentSound: !quiet),
      ),
    );
  }

  /// Notification ids 42..48 hold the scheduled reminders.
  static const _remindBaseId = 42;

  /// Reminders are booked this many days ahead, so they keep coming even if
  /// the app is not opened; every app start, resume and finished streak
  /// books the window again.
  static const remindDaysAhead = 7;

  /// Books the daily reminders for the next [remindDaysAhead] days, skipping
  /// today once its streak is done.
  static Future<void> scheduleRemind({
    required bool enabled,
    required int minutesFromMidnight,
    required Settings settings,
  }) async {
    await init();
    for (var i = 0; i < remindDaysAhead; i++) {
      await _plugin.cancel(id: _remindBaseId + i);
    }
    // Id of the single reminder used by older versions.
    await _plugin.cancel(id: 2);
    if (!enabled) return;

    final db = _db;
    final c = lookupAppLocalizations(resolveAppLocale(settings));
    var streak = const Streak(0, 0, false);
    if (db != null) {
      streak = Streaks.of(await db.allDays(), settings.shielded, todayEpochDay());
    }

    final slots = planReminders(
      now: DateTime.now(),
      minutesFromMidnight: minutesFromMidnight,
      todayDone: streak.todayDone,
      streak: streak.current,
    );
    for (final (i, slot) in slots.indexed) {
      await _plugin.zonedSchedule(
        id: _remindBaseId + i,
        title: slot.streak > 0 ? c.notifyStreakTitle(slot.streak) : c.notifyRemindBeaconTitle,
        body: c.nudge(slot.day, slot.streak > 0),
        // An absolute instant: correct wall-clock time even though tz.local
        // is never set to the device's named zone.
        scheduledDate: tz.TZDateTime.fromMillisecondsSinceEpoch(
          tz.UTC,
          slot.at.millisecondsSinceEpoch,
        ),
        payload: 'map',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(_remindChannel(settings), c.notifyChannelRemind),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// When the reminders of the coming days go off, and which streak each
  /// one can mention.
  ///
  /// A streak is only at stake today if it is not done yet, and tomorrow if
  /// today is done; further ahead it will have lapsed unless the user opens
  /// the app again (which books a fresh window).
  @visibleForTesting
  static List<RemindSlot> planReminders({
    required DateTime now,
    required int minutesFromMidnight,
    required bool todayDone,
    required int streak,
    int days = remindDaysAhead,
  }) {
    final slots = <RemindSlot>[];
    for (var offset = 0; slots.length < days; offset++) {
      final at = DateTime(
        now.year,
        now.month,
        now.day + offset,
        minutesFromMidnight ~/ 60,
        minutesFromMidnight % 60,
      );
      if (offset == 0 && (todayDone || !at.isAfter(now))) continue;
      final atStake = (offset == 0 && !todayDone) || (offset == 1 && todayDone);
      slots.add(RemindSlot(at, epochDay(at), atStake ? streak : 0));
    }
    return slots;
  }

  /// Cancel today's remind once the streak is safe and aim at tomorrow.
  static Future<void> onStreakCompleted(Settings settings) async {
    if (!settings.remind) return;
    await scheduleRemind(enabled: true, minutesFromMidnight: settings.remindAt, settings: settings);
  }
}
