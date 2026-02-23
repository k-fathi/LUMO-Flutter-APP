import 'package:flutter/material.dart';

import '../../core/di/dependency_injection.dart';
import '../../core/services/local_storage_service.dart';
import 'l10n.dart';

class LanguageController extends ChangeNotifier {
  final LocalStorageService _localStorage = getIt<LocalStorageService>();

  Locale _currentLocale = L10n.defaultLocale;

  Locale get currentLocale => _currentLocale;
  bool get isArabic => _currentLocale.languageCode == 'ar';
  bool get isEnglish => _currentLocale.languageCode == 'en';

  LanguageController() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLanguageCode = _localStorage.getLanguageCode();
    if (savedLanguageCode != null) {
      _currentLocale = Locale(savedLanguageCode, '');
      L10n.setLanguageCode(savedLanguageCode);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (!L10n.supportedLocales.any((l) => l.languageCode == languageCode)) {
      return;
    }

    _currentLocale = Locale(languageCode, '');
    L10n.setLanguageCode(languageCode);

    await _localStorage.saveLanguageCode(languageCode);

    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final newLanguageCode = isArabic ? 'en' : 'ar';
    await changeLanguage(newLanguageCode);
  }

  String getLanguageName(String languageCode) {
    return L10n.getLanguageName(languageCode);
  }
}