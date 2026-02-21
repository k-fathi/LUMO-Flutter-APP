import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOnline = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;
  bool get hasError => _errorMessage != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setOnlineStatus(bool value) {
    _isOnline = value;
    notifyListeners();
  }

  void showError(String message) {
    setError(message);
    Future.delayed(const Duration(seconds: 3), clearError);
  }
}