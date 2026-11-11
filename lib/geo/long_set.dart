int _tableSize(int capacity) {
  var n = 16;
  while (n * 3 < capacity * 4) {
    n <<= 1;
  }
  return n;
}

int _slot(int k, int size) {
  // Murmur3 finaliser — cell keys are regular, so spread bits before masking.
  var h = k;
  h ^= (h >>> 33);
  h = (h * -0xae502812aa7333) & 0xFFFFFFFFFFFFFFFF;
  h ^= (h >>> 33);
  h = (h * -0x3b314601e57a13ad) & 0xFFFFFFFFFFFFFFFF;
  h ^= (h >>> 33);
  return h.toSigned(32) & (size - 1);
}

/// Open-addressing set of 64-bit cell keys.
class LongSet {
  LongSet([int capacity = 1024]) {
    final n = _tableSize(capacity);
    _keys = List<int>.filled(n, 0);
    _used = List<bool>.filled(n, false);
  }

  late List<int> _keys;
  late List<bool> _used;
  int size = 0;

  bool contains(int k) {
    var i = _slot(k, _keys.length);
    while (_used[i]) {
      if (_keys[i] == k) return true;
      i = (i + 1) & (_keys.length - 1);
    }
    return false;
  }

  /// True when [k] was not there yet.
  bool add(int k) {
    if ((size + 1) * 4 > _keys.length * 3) _grow();
    var i = _slot(k, _keys.length);
    while (_used[i]) {
      if (_keys[i] == k) return false;
      i = (i + 1) & (_keys.length - 1);
    }
    _used[i] = true;
    _keys[i] = k;
    size++;
    return true;
  }

  void forEach(void Function(int key) action) {
    for (final i in indices()) {
      action(keyAt(i));
    }
  }

  List<int> indices() {
    final out = List<int>.filled(size, 0);
    var n = 0;
    for (var i = 0; i < _used.length; i++) {
      if (_used[i]) out[n++] = i;
    }
    return out;
  }

  int keyAt(int i) => _keys[i];

  void clear() {
    _used.fillRange(0, _used.length, false);
    size = 0;
  }

  void _grow() {
    final oldKeys = _keys;
    final oldUsed = _used;
    final n = oldKeys.length * 2;
    _keys = List<int>.filled(n, 0);
    _used = List<bool>.filled(n, false);
    size = 0;
    for (var i = 0; i < oldKeys.length; i++) {
      if (oldUsed[i]) add(oldKeys[i]);
    }
  }
}

class LongIntMap {
  LongIntMap([int capacity = 256]) {
    final n = _tableSize(capacity);
    _keys = List<int>.filled(n, 0);
    _values = List<int>.filled(n, 0);
    _used = List<bool>.filled(n, false);
  }

  late List<int> _keys;
  late List<int> _values;
  late List<bool> _used;
  int size = 0;

  int operator [](int k) {
    var i = _slot(k, _keys.length);
    while (_used[i]) {
      if (_keys[i] == k) return _values[i];
      i = (i + 1) & (_keys.length - 1);
    }
    return 0;
  }

  int increment(int k, [int by = 1]) {
    if ((size + 1) * 4 > _keys.length * 3) _grow();
    var i = _slot(k, _keys.length);
    while (_used[i]) {
      if (_keys[i] == k) {
        _values[i] += by;
        return _values[i];
      }
      i = (i + 1) & (_keys.length - 1);
    }
    _used[i] = true;
    _keys[i] = k;
    _values[i] = by;
    size++;
    return by;
  }

  void forEach(void Function(int key, int value) action) {
    final e = entries();
    for (var i = 0; i < e.$1.length; i++) {
      action(e.$1[i], e.$2[i]);
    }
  }

  (List<int>, List<int>) entries() {
    final k = List<int>.filled(size, 0);
    final v = List<int>.filled(size, 0);
    var n = 0;
    for (var i = 0; i < _used.length; i++) {
      if (_used[i]) {
        k[n] = _keys[i];
        v[n] = _values[i];
        n++;
      }
    }
    return (k, v);
  }

  void clear() {
    _used.fillRange(0, _used.length, false);
    size = 0;
  }

  void _grow() {
    final oldKeys = _keys;
    final oldValues = _values;
    final oldUsed = _used;
    final n = oldKeys.length * 2;
    _keys = List<int>.filled(n, 0);
    _values = List<int>.filled(n, 0);
    _used = List<bool>.filled(n, false);
    size = 0;
    for (var i = 0; i < oldKeys.length; i++) {
      if (oldUsed[i]) increment(oldKeys[i], oldValues[i]);
    }
  }
}
