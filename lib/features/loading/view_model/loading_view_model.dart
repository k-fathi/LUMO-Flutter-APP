import 'package:flutter/material.dart';

/// Loading ViewModel
///
/// Manages loading state and messages
class LoadingViewModel extends ChangeNotifier {
  String _message = 'جاري التحميل...';
  bool _isLoading = false;

  String get message => _message;
  bool get isLoading => _isLoading;

  /// Set loading message
  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }

  /// Show loading
  void show([String? message]) {
    _isLoading = true;
    if (message != null) {
      _message = message;
    }
    notifyListeners();
  }

  /// Hide loading
  void hide() {
    _isLoading = false;
    notifyListeners();
  }

  /// Reset to default
  void reset() {
    _message = 'جاري التحميل...';
    _isLoading = false;
    notifyListeners();
  }
}