import 'package:flutter_test/flutter_test.dart';
import 'package:mapdefog/notify/alarms.dart';
import 'package:mapdefog/util/days.dart';

void main() {
  const evening = 18 * 60 + 30;

  List<RemindSlot> plan(DateTime now, {bool todayDone = false, int streak = 0}) =>
      Alarms.planReminders(
        now: now,
        minutesFromMidnight: evening,
        todayDone: todayDone,
        streak: streak,
      );

  test('books a week of reminders, one per evening', () {
    final slots = plan(DateTime(2026, 11, 11, 9));

    expect(slots, hasLength(Alarms.remindDaysAhead));
    for (final (i, slot) in slots.indexed) {
      expect(slot.at, DateTime(2026, 11, 11 + i, 18, 30));
      expect(slot.day, epochDay(slot.at));
    }
  });

  test('skips today once the time has passed', () {
    final slots = plan(DateTime(2026, 11, 11, 19));
    expect(slots.first.at, DateTime(2026, 11, 12, 18, 30));
    expect(slots, hasLength(Alarms.remindDaysAhead));
  });

  test('skips today once the streak is done', () {
    final slots = plan(DateTime(2026, 11, 11, 9), todayDone: true);
    expect(slots.first.at, DateTime(2026, 11, 12, 18, 30));
  });

  test('a streak is mentioned only on the day it is at stake', () {
    final open = plan(DateTime(2026, 11, 11, 9), streak: 4);
    expect(open.map((s) => s.streak).take(3), [4, 0, 0]);

    final done = plan(DateTime(2026, 11, 11, 9), todayDone: true, streak: 5);
    expect(done.map((s) => s.streak).take(3), [5, 0, 0]);
    expect(done.first.at.day, 12);
  });

  test('keeps the wall-clock time across a DST change', () {
    // Europe switches back on 25 Oct 2026.
    final slots = plan(DateTime(2026, 10, 22, 9));
    expect(slots.every((s) => s.at.hour == 18 && s.at.minute == 30), isTrue);
  });
}
