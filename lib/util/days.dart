/// Calendar-day numbering shared by the game, matching java.time's
/// `LocalDate.toEpochDay` / `ofEpochDay` in the Android app.
///
/// All arithmetic is done on UTC dates. Subtracting or adding whole days to
/// *local* DateTimes is off by one whenever the zone's UTC offset differs from
/// 1970 (daylight saving time, or historical changes such as Kyiv's).
library;

final _epoch = DateTime.utc(1970);

/// Days since 1970-01-01 of [time]'s calendar date, in [time]'s own zone.
int epochDay(DateTime time) =>
    DateTime.utc(time.year, time.month, time.day).difference(_epoch).inDays;

/// Today's day number in the device's local zone.
int todayEpochDay() => epochDay(DateTime.now());

/// The calendar date of [day], as UTC midnight. Read its year, month, day
/// and weekday; to get a local instant, build `DateTime(d.year, d.month, ...)`.
DateTime dateOfEpochDay(int day) => _epoch.add(Duration(days: day));
