import 'package:flutter/material.dart';

import '../../../data/datasources/local_data_source.dart';
import '../../../shared/providers/auth_provider.dart';

/// Splash ViewModel
///
/// Manages splash screen initialization and navigation logic
class SplashViewModel extends ChangeNotifier {
  final LocalDataSource _localDataSource;
  final AuthProvider _authProvider;

  SplashViewModel(
      this._localDataSource,
      this._authProvider,
      );

  bool _isInitialized = false;
  String? _nextRoute;
  String? _errorMessage;

  bool get isInitialized => _isInitialized;
  String? get nextRoute => _nextRoute;
  String? get errorMessage => _errorMessage;

  /// Initialize app and determine next route
  Future<void> initialize() async {
    try {
      // Wait for splash animation
      await Future.delayed(const Duration(seconds: 2));

      // Check onboarding status
      if (!_localDataSource.isOnboardingCompleted()) {
        _nextRoute = '/onboarding';
        _isInitialized = true;
        notifyListeners();
        return;
      }

      // Check auth status
      await _authProvider.init();

      if (_authProvider.isAuthenticated) {
        _nextRoute = '/main-layout';
      } else {
        _nextRoute = '/role-selection';
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _nextRoute = '/role-selection'; // Fallback
      _isInitialized = true;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}