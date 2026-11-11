import 'package:flutter_test/flutter_test.dart';
import 'package:mapdefog/util/days.dart';

void main() {
  test('day numbers match LocalDate.toEpochDay', () {
    expect(epochDay(DateTime(1970)), 0);
    expect(epochDay(DateTime(2026, 7, 15)), 20649);
    expect(epochDay(DateTime(2026, 7, 15, 23, 59)), 20649);
    expect(epochDay(DateTime.utc(2026, 1, 1)), 20454);
  });

  test('a day number turns back into the same calendar date', () {
    for (final date in [
      DateTime(2026, 1, 15), // winter time
      DateTime(2026, 3, 29), // a DST switch day in Europe
      DateTime(2026, 7, 15), // summer time
      DateTime(2026, 10, 25),
    ]) {
      final d = dateOfEpochDay(epochDay(date));
      expect((d.year, d.month, d.day), (date.year, date.month, date.day));
    }
  });

  test('consecutive local days get consecutive numbers', () {
    var date = DateTime(2026);
    for (var i = 0; i < 366; i++) {
      final next = DateTime(date.year, date.month, date.day + 1);
      expect(epochDay(next) - epochDay(date), 1, reason: '$date');
      date = next;
    }
  });
}
