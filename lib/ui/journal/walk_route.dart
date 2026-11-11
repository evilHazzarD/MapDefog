import 'package:flutter/material.dart';
import 'package:mapdefog/app/app_scope.dart';
import 'package:mapdefog/data/models.dart';
import 'package:mapdefog/geo/grid.dart';
import 'package:mapdefog/ui/theme/theme.dart';

class RouteSketch extends StatelessWidget {
  const RouteSketch({super.key, required this.walkId, this.size = 52});

  final int walkId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final db = AppScope.of(context).db;
    return FutureBuilder<List<WaypointRow>>(
      future: db.waypointsFor(walkId),
      builder: (context, snap) {
        final route = snap.data;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: p.surface2, borderRadius: U.rSm),
          clipBehavior: Clip.antiAlias,
          child: route == null
              ? const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : route.length < 2
              ? Icon(Icons.directions_walk_rounded, color: p.faint, size: 22)
              : CustomPaint(
                  painter: _RoutePainter(route, p.accent),
                  child: const SizedBox.expand(),
                ),
        );
      },
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(this.route, this.ink);
  final List<WaypointRow> route;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final xs = route.map((w) => Grid.mx(w.lon)).toList();
    final ys = route.map((w) => Grid.my(w.lat)).toList();
    final x0 = xs.reduce((a, b) => a < b ? a : b);
    final y0 = ys.reduce((a, b) => a < b ? a : b);
    final xMax = xs.reduce((a, b) => a > b ? a : b);
    final yMax = ys.reduce((a, b) => a > b ? a : b);
    final span = (xMax - x0).abs() > (yMax - y0).abs() ? (xMax - x0) : (yMax - y0);
    final spanSafe = span < 1e-9 ? 1e-9 : span;
    final k = (size.shortestSide - 14) / spanSafe;
    final dx = (size.width - (xMax - x0) * k) / 2;
    final dy = (size.height - (yMax - y0) * k) / 2;
    final path = Path();
    for (var i = 0; i < xs.length; i++) {
      final x = (xs[i] - x0) * k + dx;
      final y = (ys[i] - y0) * k + dy;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    final lx = (xs.last - x0) * k + dx;
    final ly = (ys.last - y0) * k + dy;
    canvas.drawCircle(Offset(lx, ly), 2.6, Paint()..color = ink);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => oldDelegate.route != route;
}
