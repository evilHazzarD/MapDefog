import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mapdefog/app/app_scope.dart';
import 'package:mapdefog/l10n/app_localizations.dart';
import 'package:mapdefog/ui/components/components.dart';
import 'package:mapdefog/ui/theme/theme.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  Future<void> _finish() async {
    await AppScope.of(context).settings.update((s) => s.copyWith(onboarded: true));
    widget.onDone();
  }

  Future<void> _askLocation() async {
    // iOS only allows the "Always" upgrade after "When in use" is granted,
    // so the two must be requested one after the other, never together.
    try {
      final whenInUse = await Permission.locationWhenInUse.request();
      if (whenInUse.isGranted) {
        await Permission.locationAlways.request();
      }
    } on Exception catch (e) {
      debugPrint('Location permission request failed: $e');
      // A permission failure must not trap the user in onboarding.
    }
    await _finish();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(colors: [p.surface, p.bg], radius: 1.4, center: Alignment.center),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _page,
                  onPageChanged: (i) => setState(() => _index = i),
                  children: [_PageOne(), _PageTwo(), _PageThree()],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final on = i == _index;
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Transform.rotate(
                      angle: 0.785398,
                      child: Container(
                        width: on ? 12 : 8,
                        height: on ? 12 : 8,
                        color: on ? p.gold : p.line,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              if (_index < 2)
                PrimaryButton(
                  c.next,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => _page.nextPage(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOut,
                  ),
                )
              else ...[
                PrimaryButton(
                  c.allowLocation,
                  icon: Icons.my_location_rounded,
                  onPressed: _askLocation,
                ),
                TextButton(
                  onPressed: _finish,
                  child: Text(c.later, style: UType.button(p).copyWith(color: p.muted)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FramedAtlas(),
        const SizedBox(height: 26),
        Text(c.onboardingTitle1, style: UType.display(p)),
        const SizedBox(height: 10),
        Text(c.onboardingBody1, style: UType.sub(p)),
      ],
    );
  }
}

class _FramedAtlas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        borderRadius: U.rLg,
        border: Border.all(color: p.gilt, width: 2),
      ),
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: U.rMd,
          border: Border.all(color: p.gilt.withValues(alpha: 0.6)),
        ),
        child: AspectRatio(
          aspectRatio: 1.05,
          child: CustomPaint(painter: _AtlasPainter(p), child: const SizedBox.expand()),
        ),
      ),
    );
  }
}

class _AtlasPainter extends CustomPainter {
  _AtlasPainter(this.p);
  final FogPalette p;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEBDAB2));
    const ink = Color(0xFF6B4E2E);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.55),
      size.width * 0.22,
      Paint()..color = p.accentSoft,
    );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.35),
      size.width * 0.08,
      Paint()..color = p.gold,
    );
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.55,
        size.width * 0.85,
        size.height * 0.22,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = ink.withValues(alpha: 0.7)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(c.onboardingTitle2, style: UType.display(p)),
        const SizedBox(height: 18),
        _Feature(
          Icons.inventory_2_rounded,
          p.gold,
          p.goldSoft,
          c.featureCachesTitle,
          c.featureCachesBody,
        ),
        _Feature(
          Icons.flare_rounded,
          p.sky,
          p.skySoft,
          c.featureBeaconsTitle,
          c.featureBeaconsBody,
        ),
        _Feature(
          Icons.auto_awesome_rounded,
          p.violet,
          p.violetSoft,
          c.featureRelicsTitle,
          c.featureRelicsBody,
        ),
        _Feature(
          Icons.local_fire_department_rounded,
          p.flame,
          p.flameSoft,
          c.featureStreaksTitle,
          c.featureStreaksBody,
        ),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.color, this.soft, this.title, this.text);
  final IconData icon;
  final Color color;
  final Color soft;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: soft,
              shape: BoxShape.circle,
              border: Border.all(color: p.gilt, width: 1.5),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: UType.strong(p).copyWith(fontFamily: 'AlegreyaSC')),
                const SizedBox(height: 2),
                Text(text, style: UType.muted(p)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(width: 220, height: 220, child: CustomPaint(painter: _CompassPainter(p))),
        ),
        const SizedBox(height: 26),
        Text(c.onboardingTitle3, style: UType.display(p)),
        const SizedBox(height: 10),
        Text(c.onboardingBody3, style: UType.sub(p)),
      ],
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter(this.p);
  final FogPalette p;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFF6EBCF));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = p.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05,
    );
    for (var i = 0; i < 8; i++) {
      final a = i * 3.1415926535 / 4 - 3.1415926535 / 2;
      final len = i.isEven ? r * 0.74 : r * 0.45;
      final tip = c + Offset(len * math.cos(a), len * math.sin(a));
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(tip.dx, tip.dy)
        ..close();
      canvas.drawPath(path, Paint()..color = i.isEven ? p.gilt : const Color(0xFFE8D7AE));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
