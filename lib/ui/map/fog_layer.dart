import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapdefog/domain/caches.dart';
import 'package:mapdefog/domain/fog.dart';
import 'package:mapdefog/domain/rarity.dart';
import 'package:mapdefog/geo/grid.dart';
import 'package:mapdefog/ui/map/fog_styles.dart';

class FogScene {
  const FogScene({
    required this.fix,
    required this.accuracy,
    required this.trail,
    required this.beacon,
    required this.beaconReached,
    required this.week,
    required this.opened,
    required this.radar,
    required this.style,
    required this.density,
    this.pixelDensity = 1.0,
    this.picked,
  });

  final LatLng? fix;

  /// GPS accuracy in meters; gates sense-radius cache visibility (Android: < 200).
  final double accuracy;
  final List<LatLng> trail;
  final LatLng? beacon;
  final bool beaconReached;
  final int week;
  final Set<String> opened;
  final bool radar;
  final String style;

  /// Fog fill opacity 0–1 (settings.fogDensity).
  final double density;

  /// Device pixel density for LOD/marker thresholds. In Flutter logical pixels
  /// this is 1.0 (≈ Android dp).
  final double pixelDensity;
  final int? picked;
}

class FogLayer extends StatelessWidget {
  const FogLayer({super.key, required this.fog, required this.scene, this.onLongPress});

  final FogStore fog;
  final FogScene scene;
  final void Function(LatLng)? onLongPress;

  @override
  Widget build(BuildContext context) {
    final map = MapCamera.of(context);
    return MobileLayerTransformer(
      child: CustomPaint(
        painter: _FogPainter(fog: fog, scene: scene, map: map),
        size: map.size,
        isComplex: true,
      ),
    );
  }
}

class _FogPainter extends CustomPainter {
  _FogPainter({required this.fog, required this.scene, required this.map});

  final FogStore fog;
  final FogScene scene;
  final MapCamera map;

  static const _scale = 3;

  /// Layer-space projection (same as TileLayer / CircleLayer).
  /// Do not use [MapCamera.latLngToScreenOffset] here — that is for widgets
  /// outside [MobileLayerTransformer] and drifts under rotation/zoom/pan.
  Offset _project(LatLng latLng) => map.getOffsetFromOrigin(latLng);

  /// Screen pixels per mercator unit — Android WorldOverlay `ax`.
  double _ax(LatLngBounds bounds) {
    final nw = _project(LatLng(bounds.north, bounds.west));
    final se = _project(LatLng(bounds.south, bounds.east));
    final dmx = Grid.mx(bounds.east) - Grid.mx(bounds.west);
    if (dmx <= 0) return 1;
    return (se.dx - nw.dx).abs() / dmx;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final look = FogStyles.look(scene.style);
    final fogAlpha = (scene.density * 255).round().clamp(0, 255);
    final bounds = map.visibleBounds;
    final ax = _ax(bounds);
    // Android WorldOverlay uses DisplayMetrics.density with physical px;
    // flutter_map paints in logical px (≈ dp), so pixelDensity defaults to 1.
    final d = scene.pixelDensity;

    // Low-res fog bitmap
    final bw = (size.width / _scale).ceil().clamp(1, 4096);
    final bh = (size.height / _scale).ceil().clamp(1, 4096);
    final recorder = ui.PictureRecorder();
    final fogCanvas = Canvas(recorder);

    final base = look.base.withAlpha(fogAlpha);
    fogCanvas.drawRect(Rect.fromLTWH(0, 0, bw.toDouble(), bh.toDouble()), Paint()..color = base);

    // Soft cloud blobs (screen-space texture only — clears are punched later).
    final cloudPaint = Paint()
      ..color = look.cloud.withAlpha((fogAlpha * 0.55).round())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final rnd = math.Random(fog.version + scene.style.hashCode);
    for (var i = 0; i < 40; i++) {
      fogCanvas.drawCircle(
        Offset(rnd.nextDouble() * bw, rnd.nextDouble() * bh),
        12 + rnd.nextDouble() * 28,
        cloudPaint,
      );
    }

    final picture = recorder.endRecording();
    final image = picture.toImageSync(bw, bh);

    canvas.saveLayer(Offset.zero & size, Paint());
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: image,
      filterQuality: FilterQuality.medium,
      fit: BoxFit.fill,
    );
    image.dispose();

    _cutExplored(canvas, bounds, ax, d);
    canvas.restore();

    // Trail
    if (scene.trail.length >= 2) {
      final path = ui.Path();
      final first = _project(scene.trail.first);
      path.moveTo(first.dx, first.dy);
      for (final p in scene.trail.skip(1)) {
        final o = _project(p);
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF1E6B50).withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    _drawCaches(canvas, bounds, ax, d);

    // Beacon
    if (scene.beacon != null) {
      final o = _project(scene.beacon!);
      final color = scene.beaconReached ? const Color(0xFF1E6B50) : const Color(0xFFE9B949);
      canvas.drawCircle(o, 12, Paint()..color = color);
      canvas.drawCircle(o, 6, Paint()..color = Colors.white);
    }

    // Walker
    if (scene.fix != null) {
      final o = _project(scene.fix!);
      canvas.drawCircle(o, 10, Paint()..color = const Color(0xFF1E6B50));
      canvas.drawCircle(o, 5, Paint()..color = Colors.white);
    }
  }

  /// Multi-level fog cut with partial strength — Android [WorldOverlay.cutExplored].
  void _cutExplored(Canvas canvas, LatLngBounds bounds, double ax, double d) {
    var level = FogStore.levels.last;
    for (final l in FogStore.levels) {
      if (ax / (1 << l) >= 4 * d) {
        level = l;
        break;
      }
    }
    final n = 1 << level;
    final mx0 = Grid.mx(bounds.west);
    final mx1 = Grid.mx(bounds.east);
    final my0 = Grid.my(bounds.north);
    final my1 = Grid.my(bounds.south);
    const margin = 2;
    final x0 = math.max(0, (mx0 * n).floor() - margin);
    final x1 = math.min(n - 1, (mx1 * n).floor() + margin);
    final y0 = math.max(0, (my0 * n).floor() - margin);
    final y1 = math.min(n - 1, (my1 * n).floor() + margin);
    final capacity = 1 << ((Grid.z - level) * 2);
    final cellPx = ax / n;
    final r = math.max(1.2, cellPx * 1.05);

    final clear = Paint()..blendMode = BlendMode.dstOut;
    if (r >= 3) {
      clear.maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.7);
    }

    fog.visit(level, x0, y0, x1, y1, (x, y, count) {
      if (count <= 0) return;
      final strength = level == Grid.z
          ? 1.0
          : math.min(1.0, 0.3 + math.sqrt(count / capacity) * 1.15);
      clear.color = Colors.white.withValues(alpha: strength);
      final cx = _project(LatLng(Grid.lat((y + 0.5) / n), Grid.lon((x + 0.5) / n)));
      canvas.drawCircle(cx, r, clear);
    });
  }

  void _drawCaches(Canvas canvas, LatLngBounds bounds, double ax, double d) {
    const tiles = 1 << Caches.z;
    // Caches show from street level only; farther out they would be a rash of dots.
    if (ax / tiles < 60 * d) return;

    final mx0 = Grid.mx(bounds.west);
    final mx1 = Grid.mx(bounds.east);
    final my0 = Grid.my(bounds.north);
    final my1 = Grid.my(bounds.south);
    final tx0 = (mx0 * tiles).floor();
    final tx1 = (mx1 * tiles).floor();
    final ty0 = (my0 * tiles).floor();
    final ty1 = (my1 * tiles).floor();
    final caches = Caches.inBox(tx0, ty0, tx1, ty1, scene.week);
    final fix = scene.fix;

    for (final c in caches) {
      if (scene.opened.contains(c.key)) continue;
      // Explored cell, radar, or within sense range with accuracy gate (Android).
      final revealed = fog.contains(Grid.cell(c.lat, c.lon));
      final near =
          fix != null &&
          scene.accuracy < 200 &&
          Grid.distance(fix.latitude, fix.longitude, c.lat, c.lon) <= Caches.senseM;
      if (!revealed && !scene.radar && !near) continue;

      final o = _project(LatLng(c.lat, c.lon));
      final color = switch (c.rarity) {
        Rarity.common => const Color(0xFFAE7A1C),
        Rarity.rare => const Color(0xFF2F6596),
        Rarity.epic => const Color(0xFF6E3F9E),
        Rarity.legendary => const Color(0xFFB4441E),
      };

      if (revealed || scene.radar) {
        _drawGem(canvas, o, color, c.rarity, d);
      } else {
        _drawSensed(canvas, o, color, d);
      }
    }
  }

  void _drawGem(Canvas canvas, Offset o, Color color, Rarity rarity, double d) {
    final size = (10 + rarity.index * 1.5) * d;
    canvas.drawCircle(
      o,
      size * 3,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.43), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: o, radius: size * 3)),
    );
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(o.dx - size, o.dy - size * 0.3, o.dx + size, o.dy + size * 0.8),
      Radius.circular(2.5 * d),
    );
    final lid = RRect.fromRectAndRadius(
      Rect.fromLTRB(o.dx - size, o.dy - size * 0.95, o.dx + size, o.dy - size * 0.15),
      Radius.circular(size * 0.5),
    );
    canvas.drawRRect(
      body.shift(Offset(1.5 * d, 2.5 * d)),
      Paint()..color = const Color(0x66000000),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFF6E4320));
    canvas.drawRRect(lid, Paint()..color = const Color(0xFF8C5A2E));
    final band = size * 0.22;
    final bandPaint = Paint()..color = color;
    canvas.drawRect(
      Rect.fromLTRB(
        o.dx - size * 0.62,
        lid.outerRect.top + 1.5 * d,
        o.dx - size * 0.62 + band,
        body.outerRect.bottom,
      ),
      bandPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        o.dx + size * 0.62 - band,
        lid.outerRect.top + 1.5 * d,
        o.dx + size * 0.62,
        body.outerRect.bottom,
      ),
      bandPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        body.outerRect.left,
        body.outerRect.top,
        body.outerRect.right,
        body.outerRect.top + band * 0.8,
      ),
      bandPaint,
    );
    final stroke = Paint()
      ..color = const Color(0xFF3A2410)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3 * d;
    canvas.drawRRect(body, stroke);
    canvas.drawRRect(lid, stroke);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(o.dx - size * 0.2, o.dy - size * 0.32, o.dx + size * 0.2, o.dy + size * 0.2),
        Radius.circular(2 * d),
      ),
      Paint()..color = const Color(0xFFF2C14E),
    );
    canvas.drawCircle(
      Offset(o.dx, o.dy - size * 0.08),
      size * 0.07,
      Paint()..color = const Color(0xFF3A2410),
    );
  }

  void _drawSensed(Canvas canvas, Offset o, Color color, double d) {
    final r = 16 * d;
    canvas.drawCircle(
      o,
      r * 1.6,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.59), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: o, radius: r * 1.6)),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15 * d,
          shadows: [Shadow(color: const Color(0x99000000), blurRadius: 4 * d)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, o.translate(-tp.width / 2, -tp.height / 2 + 2 * d));
  }

  @override
  bool shouldRepaint(covariant _FogPainter old) =>
      old.fog.version != fog.version || old.scene != scene || old.map != map;
}
