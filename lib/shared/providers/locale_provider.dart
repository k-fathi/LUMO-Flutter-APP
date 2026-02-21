import 'package:flutter/material.dart';
import '../../data/datasources/local_data_source.dart';

class LocaleProvider extends ChangeNotifier {
  final LocalDataSource _localDataSource;

  LocaleProvider(this._localDataSource) {
    _loadLocale();
  }

  Locale _locale = const Locale('ar', '');
  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  void _loadLocale() {
    final langCode = _localDataSource.getString('language_code');
    if (langCode != null) {
      _locale = Locale(langCode, '');
      notifyListeners();
    }
  }

  void toggleLocale() {
    if (_locale.languageCode == 'ar') {
      _locale = const Locale('en', '');
    } else {
      _locale = const Locale('ar', '');
    }
    _localDataSource.setString('language_code', _locale.languageCode);
    notifyListeners();
  }
}
