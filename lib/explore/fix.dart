class Fix {
  const Fix({
    required this.lat,
    required this.lon,
    required this.accuracy,
    required this.time,
    this.bearing,
    this.simulated = false,
    this.gps = true,
    this.speed,
  });

  final double lat;
  final double lon;
  final double accuracy;
  final int time;
  final double? bearing;
  final bool simulated;
  final bool gps;
  final double? speed;

  Fix copyWith({double? lat, double? lon}) => Fix(
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    accuracy: accuracy,
    time: time,
    bearing: bearing,
    simulated: simulated,
    gps: gps,
    speed: speed,
  );
}
