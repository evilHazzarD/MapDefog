import 'dart:typed_data';

int _i32(int v) => v.toSigned(32);

class Random {
  Random(int seed) : this._fromParts(_i32(seed), _i32(seed >>> 32));

  Random._fromParts(int seed1, int seed2)
    : _x = seed1,
      _y = seed2,
      _z = 0,
      _w = 0,
      _v = _i32(~seed1),
      _addend = _i32((seed1 << 10) ^ (seed2 >>> 4)) {
    for (var i = 0; i < 64; i++) {
      nextInt();
    }
  }

  int _x, _y, _z, _w, _v, _addend;

  int nextBits(int bitCount) => nextInt() >>> (32 - bitCount);

  int nextInt([int? until]) {
    if (until == null) {
      var t = _x;
      t = _i32(t ^ (t >>> 2));
      _x = _y;
      _y = _z;
      _z = _w;
      final v0 = _v;
      _w = v0;
      t = _i32((t ^ (t << 1)) ^ v0 ^ (v0 << 4));
      _v = t;
      _addend = _i32(_addend + 362437);
      return _i32(t + _addend);
    }
    if (until <= 0) throw ArgumentError('until must be positive');
    if ((until & -until) == until) {
      return _i32((until * nextBits(31)) >>> 31);
    }
    int v;
    int bits;
    do {
      bits = nextBits(31);
      v = bits % until;
    } while (bits - v + (until - 1) < 0);
    return v;
  }

  double nextDouble() {
    return ((nextBits(26) << 27) + nextBits(27)) / (1 << 53).toDouble();
  }
}

/// String.hashCode for loot seed parity.
int stringHashCode(String s) {
  var h = 0;
  final units = Uint16List.fromList(s.codeUnits);
  for (final c in units) {
    h = _i32(31 * h + c);
  }
  return h;
}
