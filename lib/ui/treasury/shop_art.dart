import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mapdefog/ui/map/fog_styles.dart';

/// Art for the shop: a live preview of each fog style, and engraved icons for
/// the boosts, drawn in code so they stay sharp and follow the theme.

/// A small map under the fog style [id], with a cleared path through it.
class FogSwatch extends StatelessWidget {
  const FogSwatch(this.id, {super.key, this.height = 72});

  final String id;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    child: CustomPaint(
      size: Size.fromHeight(height),
      painter: _SwatchPainter(id, FogStyles.look(id)),
    ),
  );
}

class _SwatchPainter extends CustomPainter {
  _SwatchPainter(this.id, this.look);

  final String id;
  final FogLook look;

  // The sepia map that a revealed street shows, as on the real map.
  static const _land = Color(0xFFE9DDC4);
  static const _street = Color(0xFFCDB894);
  static const _block = Color(0xFFDDCDAE);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rnd = math.Random(id.hashCode);

    // The fog itself.
    canvas.drawRect(Offset.zero & size, Paint()..color = look.base);
    _styleBackdrop(canvas, size);
    final cloud = Paint()
      ..color = look.cloud.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    for (var i = 0; i < 7; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * w, rnd.nextDouble() * h),
        h * (0.22 + rnd.nextDouble() * 0.2),
        cloud,
      );
    }

    // A walked path: the fog is cleared along it, showing the map below.
    final path = Path()
      ..moveTo(-8, h * 0.78)
      ..cubicTo(w * 0.25, h * 0.95, w * 0.3, h * 0.25, w * 0.55, h * 0.45)
      ..cubicTo(w * 0.75, h * 0.6, w * 0.8, h * 0.1, w + 8, h * 0.2);
    final width = h * 0.36;
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..color = _land
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    // Streets and blocks, kept inside the clearing.
    final inside = Paint()..blendMode = BlendMode.srcATop;
    for (var x = -w * 0.1; x < w; x += w * 0.17) {
      canvas.drawRect(
        Rect.fromLTWH(x, h * 0.1 + (x * 0.37) % (h * 0.3), w * 0.08, h * 0.16),
        inside..color = _block,
      );
    }
    final street = Paint()
      ..blendMode = BlendMode.srcATop
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = _street;
    for (var x = 0.0; x < w; x += w / 7) {
      canvas.drawLine(Offset(x, 0), Offset(x + w * 0.12, h), street);
    }
    canvas.drawLine(Offset(0, h * 0.55), Offset(w, h * 0.42), street);
    canvas.restore();

    // The rim the real fog draws around a clearing.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width + 3
        ..strokeCap = StrokeCap.round
        ..color = look.rim.withValues(alpha: 0.35)
        ..blendMode = BlendMode.dstOver,
    );

    _styleForeground(canvas, size, rnd);
  }

  /// What sits behind the clouds: aurora bands, ember glow, chart lines.
  void _styleBackdrop(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    switch (id) {
      case 'aurora':
        for (final (i, color) in [look.accent!, look.sparkles!, look.rim].indexed) {
          final band = Path()
            ..moveTo(0, h * (0.15 + i * 0.12))
            ..quadraticBezierTo(w * 0.5, h * (0.45 + i * 0.1), w, h * (0.05 + i * 0.14));
          canvas.drawPath(
            band,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = h * 0.14
              ..color = color.withValues(alpha: 0.55)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
          );
        }
      case 'ember':
        canvas.drawCircle(
          Offset(w * 0.8, h * 1.05),
          h * 0.75,
          Paint()
            ..color = look.accent!.withValues(alpha: 0.45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
        );
      case 'parchment':
        final ink = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = look.rim.withValues(alpha: 0.35);
        for (var y = h * 0.12; y < h; y += h * 0.16) {
          canvas.drawLine(Offset(0, y), Offset(w, y + h * 0.04), ink);
        }
      default:
    }
  }

  /// What sits over everything: snowflakes, stars and moon, sparks, a compass.
  void _styleForeground(Canvas canvas, Size size, math.Random rnd) {
    final w = size.width;
    final h = size.height;
    final sparkle = look.sparkles;
    if (sparkle != null) {
      final dot = Paint()..color = sparkle;
      final count = (look.sparkleCount / 4).round();
      for (var i = 0; i < count; i++) {
        final at = Offset(rnd.nextDouble() * w, rnd.nextDouble() * h);
        final r = 0.6 + rnd.nextDouble() * (id == 'snow' ? 1.6 : 1.0);
        canvas.drawCircle(
          at,
          r,
          dot..color = sparkle.withValues(alpha: 0.5 + rnd.nextDouble() / 2),
        );
      }
    }
    switch (id) {
      case 'snow':
        for (final at in [Offset(w * 0.18, h * 0.25), Offset(w * 0.86, h * 0.68)]) {
          _snowflake(canvas, at, h * 0.11, Colors.white);
        }
      case 'midnight':
        // A crescent: the lit disc minus a shifted disc of night.
        final moon = Offset(w * 0.84, h * 0.26);
        final r = h * 0.13;
        canvas.drawPath(
          Path.combine(
            PathOperation.difference,
            Path()..addOval(Rect.fromCircle(center: moon, radius: r)),
            Path()..addOval(Rect.fromCircle(center: moon.translate(r * 0.55, -r * 0.3), radius: r)),
          ),
          Paint()..color = const Color(0xFFF3EBC8),
        );
      case 'ember':
        final spark = Paint()..color = look.sparkles!;
        for (var i = 0; i < 4; i++) {
          final at = Offset(w * (0.55 + i * 0.1), h * (0.85 - i * 0.17));
          canvas.drawCircle(at, 1.6, spark);
          canvas.drawCircle(
            at,
            4,
            spark
              ..color = look.sparkles!.withValues(alpha: 0.25)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          );
          spark
            ..color = look.sparkles!
            ..maskFilter = null;
        }
      case 'parchment':
        _compass(canvas, Offset(w * 0.86, h * 0.72), h * 0.17, look.rim);
      default:
    }
  }

  static void _snowflake(Canvas canvas, Offset c, double r, Color color) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      final tip = c + Offset(math.cos(a), math.sin(a)) * r;
      canvas.drawLine(c, tip, p);
      final mid = c + Offset(math.cos(a), math.sin(a)) * r * 0.55;
      for (final s in [-1, 1]) {
        final b = a + s * math.pi / 4;
        canvas.drawLine(mid, mid + Offset(math.cos(b), math.sin(b)) * r * 0.35, p);
      }
    }
  }

  static void _compass(Canvas canvas, Offset c, double r, Color color) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(c, r, p);
    final star = Path();
    for (var i = 0; i < 8; i++) {
      final a = -math.pi / 2 + i * math.pi / 4;
      final len = i.isEven ? r * 1.25 : r * 0.55;
      final at = c + Offset(math.cos(a), math.sin(a)) * len;
      i == 0 ? star.moveTo(at.dx, at.dy) : star.lineTo(at.dx, at.dy);
      final b = a + math.pi / 8;
      final inner = c + Offset(math.cos(b), math.sin(b)) * r * 0.2;
      star.lineTo(inner.dx, inner.dy);
    }
    star.close();
    canvas.drawPath(star, Paint()..color = color.withValues(alpha: 0.8));
  }

  @override
  bool shouldRepaint(_SwatchPainter old) => old.id != id;
}

/// The boosts the shop sells.
enum BoostArt { lantern, radar, shield, reroll }

/// An engraved icon for a boost, in [color].
class BoostIcon extends StatelessWidget {
  const BoostIcon(this.art, {super.key, required this.color, this.size = 24});

  final BoostArt art;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _BoostPainter(art, color));
}

class _BoostPainter extends CustomPainter {
  _BoostPainter(this.art, this.color);

  final BoostArt art;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Drawn on a 24-unit grid.
    canvas.scale(size.width / 24);
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;
    final soft = Paint()..color = color.withValues(alpha: 0.22);
    switch (art) {
      case BoostArt.lantern:
        _lantern(canvas, line, fill, soft);
      case BoostArt.radar:
        _radar(canvas, line, fill, soft);
      case BoostArt.shield:
        _shield(canvas, line, fill, soft);
      case BoostArt.reroll:
        _reroll(canvas, line, fill, soft);
    }
  }

  /// A hanging lantern with a lit flame.
  static void _lantern(Canvas canvas, Paint line, Paint fill, Paint soft) {
    canvas.drawCircle(
      const Offset(12, 13.5),
      9.5,
      soft..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    soft.maskFilter = null;
    canvas.drawArc(const Rect.fromLTWH(9.5, 1, 5, 4), math.pi, math.pi, false, line);
    canvas.drawLine(const Offset(8, 5.5), const Offset(16, 5.5), line);
    final body = Path()
      ..moveTo(8.5, 5.5)
      ..lineTo(7, 9)
      ..lineTo(7, 18)
      ..lineTo(17, 18)
      ..lineTo(17, 9)
      ..lineTo(15.5, 5.5);
    canvas.drawPath(body, line);
    canvas.drawLine(const Offset(7, 9), const Offset(17, 9), line);
    canvas.drawLine(const Offset(6, 20.5), const Offset(18, 20.5), line);
    canvas.drawLine(const Offset(9, 18), const Offset(9, 20.5), line);
    canvas.drawLine(const Offset(15, 18), const Offset(15, 20.5), line);
    final flame = Path()
      ..moveTo(12, 10.3)
      ..cubicTo(14.6, 12.8, 14.4, 16.4, 12, 16.6)
      ..cubicTo(9.6, 16.4, 9.6, 13.6, 11.1, 12.6)
      ..cubicTo(11.2, 13.6, 11.7, 14.1, 12.2, 14.2)
      ..cubicTo(12.4, 12.8, 11.6, 11.6, 12, 10.3)
      ..close();
    canvas.drawPath(flame, fill);
  }

  /// A compass dial with a radar sweep: sense chests through the mist.
  static void _radar(Canvas canvas, Paint line, Paint fill, Paint soft) {
    const c = Offset(12, 12);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy)
        ..arcTo(Rect.fromCircle(center: c, radius: 9.5), -math.pi / 2, math.pi / 2.2, false)
        ..close(),
      soft,
    );
    canvas.drawCircle(c, 9.5, line);
    canvas.drawCircle(c, 5.2, line..strokeWidth = 1.1);
    line.strokeWidth = 1.7;
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * 9.5,
        c + Offset(math.cos(a), math.sin(a)) * 11.5,
        line,
      );
    }
    canvas.drawLine(c, c + Offset(math.cos(-0.35), math.sin(-0.35)) * 9.5, line);
    canvas.drawCircle(const Offset(15.6, 8.4), 1.5, fill);
    canvas.drawCircle(c, 1.4, fill);
  }

  /// A heraldic shield with a chevron: protects a streak.
  static void _shield(Canvas canvas, Paint line, Paint fill, Paint soft) {
    final shape = Path()
      ..moveTo(12, 2.5)
      ..lineTo(19.5, 5.2)
      ..cubicTo(19.6, 12.5, 17, 18.4, 12, 21.5)
      ..cubicTo(7, 18.4, 4.4, 12.5, 4.5, 5.2)
      ..close();
    canvas.drawPath(shape, soft);
    canvas.drawPath(shape, line);
    canvas.drawPath(
      Path()
        ..moveTo(7.6, 13.6)
        ..lineTo(12, 9.6)
        ..lineTo(16.4, 13.6),
      line,
    );
    _star(canvas, const Offset(12, 16.4), 2.2, fill);
  }

  /// The shrine's star inside a turning arrow: pick another shrine.
  static void _reroll(Canvas canvas, Paint line, Paint fill, Paint soft) {
    const c = Offset(12, 12);
    const r = 8.3;
    const start = -math.pi / 2 + 0.5;
    const sweep = math.pi * 1.6;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, sweep, false, line);
    // An arrowhead at the end of the arc, along its (clockwise) direction.
    const end = start + sweep;
    final at = c + Offset(math.cos(end), math.sin(end)) * r;
    final along = Offset(-math.sin(end), math.cos(end));
    final out = Offset(math.cos(end), math.sin(end));
    final tip = at + along * 3.2;
    final back = at - along * 0.6;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo((back + out * 2.8).dx, (back + out * 2.8).dy)
        ..lineTo((back - out * 2.8).dx, (back - out * 2.8).dy)
        ..close(),
      fill,
    );
    canvas.drawCircle(c, 4.6, soft);
    _star(canvas, c, 3.6, fill);
  }

  static void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final p = Path();
    for (var i = 0; i < 8; i++) {
      final a = -math.pi / 2 + i * math.pi / 4;
      final len = i.isEven ? r : r * 0.42;
      final at = c + Offset(math.cos(a), math.sin(a)) * len;
      i == 0 ? p.moveTo(at.dx, at.dy) : p.lineTo(at.dx, at.dy);
    }
    canvas.drawPath(p..close(), paint);
  }

  @override
  bool shouldRepaint(_BoostPainter old) => old.art != art || old.color != color;
}
