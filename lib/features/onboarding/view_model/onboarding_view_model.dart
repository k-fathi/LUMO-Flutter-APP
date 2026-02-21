import 'package:flutter/material.dart';

import '../../../data/datasources/local_data_source.dart';
import '../../../data/models/onboarding_model.dart';

/// Onboarding ViewModel
///
/// Features:
/// - Page management
/// - State persistence
/// - Navigation control
/// - Progress tracking
/// - Completion handling
/// - Auto-advance option
class OnboardingViewModel extends ChangeNotifier {
  final LocalDataSource _localDataSource;

  OnboardingViewModel(this._localDataSource);

  int _currentPage = 0;
  final List<OnboardingModel> _screens = OnboardingModel.screens;
  bool _isCompleting = false;
  bool _autoAdvance = false;
  String? _errorMessage;

  // Getters
  int get currentPage => _currentPage;
  List<OnboardingModel> get screens => _screens;
  bool get isLastPage => _currentPage == _screens.length - 1;
  bool get isFirstPage => _currentPage == 0;
  bool get isCompleting => _isCompleting;
  bool get autoAdvance => _autoAdvance;
  String? get errorMessage => _errorMessage;
  int get totalPages => _screens.length;
  double get progress => (_currentPage + 1) / _screens.length;

  /// Set current page
  void setPage(int page) {
    if (page >= 0 && page < _screens.length && page != _currentPage) {
      _currentPage = page;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Go to next page
  void nextPage() {
    if (!isLastPage) {
      _currentPage++;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Go to previous page
  void previousPage() {
    if (!isFirstPage) {
      _currentPage--;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Jump to specific page
  void jumpToPage(int page) {
    if (page >= 0 && page < _screens.length) {
      _currentPage = page;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Skip to last page
  void skipToEnd() {
    _currentPage = _screens.length - 1;
    _errorMessage = null;
    notifyListeners();
  }

  /// Toggle auto-advance
  void toggleAutoAdvance() {
    _autoAdvance = !_autoAdvance;
    notifyListeners();
  }

  /// Set auto-advance
  void setAutoAdvance(bool value) {
    _autoAdvance = value;
    notifyListeners();
  }

  /// Complete onboarding
  Future<bool> completeOnboarding() async {
    if (_isCompleting) return false;

    _isCompleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Save completion state
      await _localDataSource.setOnboardingCompleted(true);

      // Optional: Save completion timestamp
      final timestamp = DateTime.now().toIso8601String();
      await _localDataSource.setString('onboarding_completed_at', timestamp);

      // Optional: Save which screens were viewed
      await _localDataSource.setInt(
          'onboarding_pages_viewed', _currentPage + 1);

      _isCompleting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل حفظ التقدم: ${e.toString()}';
      _isCompleting = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset onboarding (for testing/development)
  Future<void> resetOnboarding() async {
    try {
      await _localDataSource.setOnboardingCompleted(false);
      _currentPage = 0;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل إعادة التعيين: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    try {
      return _localDataSource.isOnboardingCompleted();
    } catch (e) {
      _errorMessage = 'فشل التحقق من الحالة: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Get completion timestamp
  Future<String?> getCompletionTimestamp() async {
    try {
      return _localDataSource.getString('onboarding_completed_at');
    } catch (e) {
      return null;
    }
  }

  /// Get pages viewed count
  Future<int> getPagesViewed() async {
    try {
      return _localDataSource.getInt('onboarding_pages_viewed') ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset to first page
  void reset() {
    _currentPage = 0;
    _errorMessage = null;
    _isCompleting = false;
    notifyListeners();
  }

  /// Dispose
  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }
}
