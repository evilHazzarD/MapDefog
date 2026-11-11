import 'dart:ui';

class FogLook {
  const FogLook({
    required this.base,
    required this.cloud,
    this.accent,
    this.sparkles,
    this.sparkleCount = 0,
    required this.rim,
  });

  final Color base;
  final Color cloud;
  final Color? accent;
  final Color? sparkles;
  final int sparkleCount;
  final Color rim;
}

class FogStyles {
  FogStyles._();

  static FogLook look(String id) => switch (id) {
    'parchment' => const FogLook(
      base: Color(0xFFCDB38A),
      cloud: Color(0xFFE7D5B0),
      accent: Color(0xFFB08F5E),
      rim: Color(0xFF8C6B3E),
    ),
    'snow' => const FogLook(
      base: Color(0xFFD5DEE6),
      cloud: Color(0xFFFFFFFF),
      sparkles: Color(0xFFFFFFFF),
      sparkleCount: 90,
      rim: Color(0xFF9FB4C6),
    ),
    'midnight' => const FogLook(
      base: Color(0xFF161D33),
      cloud: Color(0xFF26304F),
      sparkles: Color(0xFFE8ECFF),
      sparkleCount: 70,
      rim: Color(0xFF5C6BC0),
    ),
    'ember' => const FogLook(
      base: Color(0xFF2E211D),
      cloud: Color(0xFF4A302A),
      accent: Color(0xFFB4532A),
      sparkles: Color(0xFFFFA04D),
      sparkleCount: 40,
      rim: Color(0xFFE5672A),
    ),
    'aurora' => const FogLook(
      base: Color(0xFF15283A),
      cloud: Color(0xFF1F3F55),
      accent: Color(0xFF3FBF9A),
      sparkles: Color(0xFFB9A8FF),
      sparkleCount: 40,
      rim: Color(0xFF4FD1BC),
    ),
    _ => const FogLook(base: Color(0xFF8F979E), cloud: Color(0xFFB7BEC4), rim: Color(0xFF5F6870)),
  };
}
