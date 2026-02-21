import 'package:flutter/material.dart';

class L10n {
  const L10n._();

  static const List<Locale> supportedLocales = [
    Locale('ar', ''), // Arabic
    Locale('en', ''), // English
  ];

  static const Locale defaultLocale = Locale('ar', '');

  static Locale _currentLocale = defaultLocale;

  static Locale get currentLocale => _currentLocale;

  static bool get isArabic => _currentLocale.languageCode == 'ar';
  static bool get isEnglish => _currentLocale.languageCode == 'en';

  static void setLocale(Locale locale) {
    if (supportedLocales.contains(locale)) {
      _currentLocale = locale;
    }
  }

  static void setLanguageCode(String languageCode) {
    final locale = Locale(languageCode, '');
    setLocale(locale);
  }

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return 'العربية';
    }
  }
}