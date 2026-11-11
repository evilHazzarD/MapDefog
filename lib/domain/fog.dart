import 'package:mapdefog/geo/grid.dart';
import 'package:mapdefog/geo/long_set.dart';

/// Explored base cells in memory, with per-level counts for zoomed-out drawing.
class FogStore {
  final LongSet _cells = LongSet(4096);
  late final List<LongIntMap> _counts = List.generate(levels.length, (_) => LongIntMap(1024));

  int _version = 0;
  final List<void Function()> _listeners = [];

  double areaM2 = 0;
  int get size => _cells.size;
  int get version => _version;

  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);

  bool contains(int key) => _cells.contains(key);

  /// Adds without announcing; call [changed] after a batch.
  bool add(int key) {
    if (!_cells.add(key)) return false;
    areaM2 += Grid.area(key);
    for (var i = 1; i < levels.length; i++) {
      _counts[i].increment(Grid.parent(key, levels[i]));
    }
    return true;
  }

  void changed() {
    _version++;
    for (final l in List.of(_listeners)) {
      l();
    }
  }

  void clear() {
    _cells.clear();
    for (final m in _counts) {
      m.clear();
    }
    areaM2 = 0;
    changed();
  }

  int count(int key, int level) {
    final i = levels.indexOf(level);
    if (i <= 0) return _cells.contains(key) ? 1 : 0;
    return _counts[i][key];
  }

  double sectorShare(int sector) => count(sector, Grid.sectorZ) / Grid.sectorCells;

  (List<int>, List<int>) sectors() => _counts[levels.indexOf(Grid.sectorZ)].entries();

  void visit(
    int level,
    int x0,
    int y0,
    int x1,
    int y1,
    void Function(int x, int y, int count) action,
  ) {
    final i = levels.indexOf(level);
    final boxCells = (x1 - x0 + 1) * (y1 - y0 + 1);
    if (i == 0) {
      if (boxCells < _cells.size) {
        for (var x = x0; x <= x1; x++) {
          for (var y = y0; y <= y1; y++) {
            if (_cells.contains(Grid.key(x, y))) action(x, y, 1);
          }
        }
      } else {
        _cells.forEach((k) {
          final x = Grid.xOf(k);
          final y = Grid.yOf(k);
          if (x >= x0 && x <= x1 && y >= y0 && y <= y1) action(x, y, 1);
        });
      }
    } else {
      final map = _counts[i];
      if (boxCells < map.size) {
        for (var x = x0; x <= x1; x++) {
          for (var y = y0; y <= y1; y++) {
            final c = map[Grid.key(x, y)];
            if (c > 0) action(x, y, c);
          }
        }
      } else {
        map.forEach((k, c) {
          final x = Grid.xOf(k);
          final y = Grid.yOf(k);
          if (x >= x0 && x <= x1 && y >= y0 && y <= y1) action(x, y, c);
        });
      }
    }
  }

  int exploredAround(double lat, double lon, double radius) {
    var n = 0;
    Grid.around(lat, lon, radius, (k) {
      if (_cells.contains(k)) n++;
    });
    return n;
  }

  static const List<int> levels = [Grid.z, 18, 16, 14, 12, 10, 8];
}
