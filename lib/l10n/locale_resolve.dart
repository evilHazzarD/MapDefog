import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:mapdefog/data/settings_store.dart';

/// Resolves the app content locale from Settings (and device for system).
Locale resolveAppLocale(Settings settings) {
  switch (settings.language) {
    case LanguagePref.en:
      return const Locale('en');
    case LanguagePref.ru:
      return const Locale('ru');
    case LanguagePref.uk:
      return const Locale('uk');
    case LanguagePref.system:
      final code = PlatformDispatcher.instance.locale.languageCode;
      if (code == 'uk') return const Locale('uk');
      if (code == 'ru') return const Locale('ru');
      return const Locale('en');
  }
}
