import 'package:flutter/material.dart';
import 'package:mapdefog/data/settings_store.dart';

/// Parchment palette aligned with Compose LightPalette / DarkPalette.
class FogPalette {
  const FogPalette({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.line,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.gold,
    required this.goldSoft,
    required this.sage,
    required this.sageSoft,
    required this.sky,
    required this.skySoft,
    required this.violet,
    required this.violetSoft,
    required this.rose,
    required this.roseSoft,
    required this.flame,
    required this.flameSoft,
    required this.danger,
    required this.gilt,
    required this.dark,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color line;
  final Color ink;
  final Color muted;
  final Color faint;
  final Color accent;
  final Color accentSoft;
  final Color onAccent;
  final Color gold;
  final Color goldSoft;
  final Color sage;
  final Color sageSoft;
  final Color sky;
  final Color skySoft;
  final Color violet;
  final Color violetSoft;
  final Color rose;
  final Color roseSoft;
  final Color flame;
  final Color flameSoft;
  final Color danger;
  final Color gilt;
  final bool dark;
}

const lightPalette = FogPalette(
  bg: Color(0xFFEFE3C8),
  surface: Color(0xFFFBF4E2),
  surface2: Color(0xFFF4EAD2),
  line: Color(0xFFDCC9A0),
  ink: Color(0xFF2B1D10),
  muted: Color(0xFF6E5A42),
  faint: Color(0xFFA48F6D),
  accent: Color(0xFF1E6B50),
  accentSoft: Color(0xFFD7E6D3),
  onAccent: Color(0xFFFBF4E2),
  gold: Color(0xFFAE7A1C),
  goldSoft: Color(0xFFF3E1B4),
  sage: Color(0xFF55813C),
  sageSoft: Color(0xFFE1EBCB),
  sky: Color(0xFF2F6596),
  skySoft: Color(0xFFDCE6EE),
  violet: Color(0xFF6E3F9E),
  violetSoft: Color(0xFFE9DDF0),
  rose: Color(0xFF9E3A55),
  roseSoft: Color(0xFFF2DCDD),
  flame: Color(0xFFB4441E),
  flameSoft: Color(0xFFF5DCC6),
  danger: Color(0xFFA8322A),
  gilt: Color(0xFFC9A24E),
  dark: false,
);

const darkPalette = FogPalette(
  bg: Color(0xFF14100B),
  surface: Color(0xFF221A11),
  surface2: Color(0xFF2A2116),
  line: Color(0xFF433522),
  ink: Color(0xFFF1E4C6),
  muted: Color(0xFFC2AE8A),
  faint: Color(0xFF85745A),
  accent: Color(0xFF5FC79C),
  accentSoft: Color(0xFF1A3A2C),
  onAccent: Color(0xFF0E1F17),
  gold: Color(0xFFE9B949),
  goldSoft: Color(0xFF3A2C11),
  sage: Color(0xFF9CC77A),
  sageSoft: Color(0xFF233019),
  sky: Color(0xFF86B6E6),
  skySoft: Color(0xFF1B2A3A),
  violet: Color(0xFFB896E8),
  violetSoft: Color(0xFF2E2240),
  rose: Color(0xFFE88AA0),
  roseSoft: Color(0xFF3A1E26),
  flame: Color(0xFFF08A4B),
  flameSoft: Color(0xFF3B2214),
  danger: Color(0xFFFF6B5E),
  gilt: Color(0xFFB08A3C),
  dark: true,
);

extension MapDefogThemeContext on BuildContext {
  FogPalette get palette {
    final ext = Theme.of(this).extension<FogPaletteTheme>();
    return ext?.palette ?? lightPalette;
  }
}

class FogPaletteTheme extends ThemeExtension<FogPaletteTheme> {
  const FogPaletteTheme(this.palette);
  final FogPalette palette;

  @override
  FogPaletteTheme copyWith({FogPalette? palette}) => FogPaletteTheme(palette ?? this.palette);

  @override
  FogPaletteTheme lerp(FogPaletteTheme? other, double t) =>
      FogPaletteTheme(other == null ? palette : (t < 0.5 ? palette : other.palette));
}

class U {
  U._();
  static const rXl = BorderRadius.all(Radius.circular(22));
  static const rLg = BorderRadius.all(Radius.circular(18));
  static const rMd = BorderRadius.all(Radius.circular(14));
  static const rSm = BorderRadius.all(Radius.circular(10));
}

class UType {
  UType._();

  static TextStyle display(FogPalette c) => TextStyle(
    fontFamily: 'AlegreyaSC',
    fontWeight: FontWeight.w700,
    fontSize: 34,
    height: 38 / 34,
    color: c.ink,
  );

  static TextStyle title(FogPalette c) => TextStyle(
    fontFamily: 'AlegreyaSC',
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 32 / 28,
    color: c.ink,
  );

  static TextStyle sub(FogPalette c) =>
      TextStyle(fontFamily: 'AlegreyaSans', fontSize: 15.5, height: 21 / 15.5, color: c.muted);

  static TextStyle eyebrow(FogPalette c) => TextStyle(
    fontFamily: 'AlegreyaSC',
    fontWeight: FontWeight.w700,
    fontSize: 12.5,
    letterSpacing: 1,
    color: c.faint,
  );

  static TextStyle strong(FogPalette c) => TextStyle(
    fontFamily: 'AlegreyaSans',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: c.ink,
  );

  static TextStyle body(FogPalette c) =>
      TextStyle(fontFamily: 'AlegreyaSans', fontSize: 16, height: 22 / 16, color: c.ink);

  static TextStyle muted(FogPalette c) =>
      TextStyle(fontFamily: 'AlegreyaSans', fontSize: 14, height: 19 / 14, color: c.muted);

  static TextStyle small(FogPalette c) => TextStyle(
    fontFamily: 'AlegreyaSans',
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: c.faint,
  );

  static TextStyle number(FogPalette c) =>
      TextStyle(fontFamily: 'AlegreyaSC', fontWeight: FontWeight.w700, fontSize: 23, color: c.ink);

  static TextStyle button(FogPalette c) => TextStyle(
    fontFamily: 'AlegreyaSans',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: c.ink,
  );

  static TextStyle quote(FogPalette c) =>
      TextStyle(fontFamily: 'Alegreya', fontSize: 18, height: 26 / 18, color: c.ink);
}

bool isDarkMode(ThemeModePref mode, Brightness platform) => switch (mode) {
  ThemeModePref.system => platform == Brightness.dark,
  ThemeModePref.light => false,
  ThemeModePref.dark => true,
};

ThemeData mapDefogTheme(FogPalette p) {
  final base = p.dark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);
  return base.copyWith(
    extensions: [FogPaletteTheme(p)],
    colorScheme: ColorScheme(
      brightness: p.dark ? Brightness.dark : Brightness.light,
      primary: p.accent,
      onPrimary: p.onAccent,
      secondary: p.gold,
      onSecondary: p.onAccent,
      error: p.danger,
      onError: p.onAccent,
      surface: p.surface,
      onSurface: p.ink,
    ),
    scaffoldBackgroundColor: p.bg,
    textTheme: base.textTheme.apply(
      fontFamily: 'AlegreyaSans',
      bodyColor: p.ink,
      displayColor: p.ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.ink,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'AlegreyaSC',
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: p.ink,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      backgroundColor: p.surface,
      indicatorColor: p.accentSoft,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontFamily: 'AlegreyaSans', fontSize: 12, color: p.muted),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.accent,
        foregroundColor: p.onAccent,
        textStyle: const TextStyle(fontFamily: 'AlegreyaSans', fontWeight: FontWeight.w600),
      ),
    ),
  );
}
