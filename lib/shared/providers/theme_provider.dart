import 'package:flutter/material.dart';
import '../../data/datasources/local_data_source.dart';

class ThemeProvider extends ChangeNotifier {
  final LocalDataSource _localDataSource;

  ThemeProvider(this._localDataSource) {
    _loadTheme();
  }

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void _loadTheme() {
    _isDarkMode = _localDataSource.getBool('is_dark_mode') ?? false;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _localDataSource.setBool('is_dark_mode', _isDarkMode);
    notifyListeners();
  }
}
