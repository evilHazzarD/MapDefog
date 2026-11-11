import 'dart:math' as math;

/// Web Mercator cells — same squares map tiles use. Base cell is zoom [z] (~38 m equator).
class Grid {
  Grid._();

  static const int z = 20;
  static const int n = 1 << z;
  static const double _earthM = 6371008.8;
  static const double _equatorM = 40075016.686;

  /// Named districts: zoom-14 tiles, 64×64 base cells.
  static const int sectorZ = 14;
  static const int sectorCells = 1 << ((z - sectorZ) * 2);
  static const double earthKm2 = 510072000.0;

  static int key(int x, int y) => (x << 32) | (y & 0xffffffff);

  static int xOf(int key) => key >>> 32;

  static int yOf(int key) => (key & 0xffffffff).toSigned(32);

  static double mx(double lon) => (lon + 180.0) / 360.0;

  static double my(double lat) {
    final s = math.sin(lat.clamp(-85.05, 85.05) * math.pi / 180);
    return 0.5 - math.log((1 + s) / (1 - s)) / (4 * math.pi);
  }

  static double lon(double mx) => mx * 360.0 - 180.0;

  static double lat(double my) {
    final x = math.pi * (1 - 2 * my);
    final sinh = (math.exp(x) - math.exp(-x)) / 2;
    return math.atan(sinh) * 180 / math.pi;
  }

  static int cell(double lat, double lon) {
    final xi = (mx(lon) * n).floor().clamp(0, n - 1);
    final yi = (my(lat) * n).floor().clamp(0, n - 1);
    return key(xi, yi);
  }

  static int parent(int key, int level) {
    final d = z - level;
    return Grid.key(xOf(key) >> d, yOf(key) >> d);
  }

  static int sector(int key) => parent(key, sectorZ);

  static double centerLat(int key, [int level = z]) => lat((yOf(key) + 0.5) / (1 << level));

  static double centerLon(int key, [int level = z]) => lon((xOf(key) + 0.5) / (1 << level));

  static double cellMeters(double lat) => _equatorM * math.cos(lat * math.pi / 180) / n;

  static double area(int key) {
    final m = cellMeters(centerLat(key));
    return m * m;
  }

  static void around(double lat, double lon, double radius, void Function(int key) out) {
    final m = cellMeters(lat);
    final r = radius / m;
    final cx = mx(lon) * n;
    final cy = my(lat) * n;
    final x0 = (cx - r).floor();
    final x1 = (cx + r).floor();
    final y0 = (cy - r).floor();
    final y1 = (cy + r).floor();
    final r2 = r * r;
    for (var x = x0; x <= x1; x++) {
      for (var y = y0; y <= y1; y++) {
        final dx = x + 0.5 - cx;
        final dy = y + 0.5 - cy;
        if (dx * dx + dy * dy <= r2) {
          out(key(x.clamp(0, n - 1), y.clamp(0, n - 1)));
        }
      }
    }
  }

  static double distance(double lat1, double lon1, double lat2, double lon2) {
    final p1 = lat1 * math.pi / 180;
    final p2 = lat2 * math.pi / 180;
    final dp = p2 - p1;
    final dl = (lon2 - lon1) * math.pi / 180;
    final a =
        math.sin(dp / 2) * math.sin(dp / 2) +
        math.cos(p1) * math.cos(p2) * math.sin(dl / 2) * math.sin(dl / 2);
    return 2 * _earthM * math.asin(math.sqrt(a.clamp(0.0, 1.0)));
  }

  static double bearing(double lat1, double lon1, double lat2, double lon2) {
    final p1 = lat1 * math.pi / 180;
    final p2 = lat2 * math.pi / 180;
    final dl = (lon2 - lon1) * math.pi / 180;
    final y = math.sin(dl) * math.cos(p2);
    final x = math.cos(p1) * math.sin(p2) - math.sin(p1) * math.cos(p2) * math.cos(dl);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  static (double, double) offset(double lat, double lon, double meters, double bearing) {
    final d = meters / _earthM;
    final b = bearing * math.pi / 180;
    final p1 = lat * math.pi / 180;
    final l1 = lon * math.pi / 180;
    final p2 = math.asin(math.sin(p1) * math.cos(d) + math.cos(p1) * math.sin(d) * math.cos(b));
    final l2 =
        l1 +
        math.atan2(
          math.sin(b) * math.sin(d) * math.cos(p1),
          math.cos(d) - math.sin(p1) * math.sin(p2),
        );
    return (p2 * 180 / math.pi, ((l2 * 180 / math.pi + 540) % 360 - 180));
  }
}
