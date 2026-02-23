import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../core/enums/user_role.dart';

/// Auth ViewModel
///
/// Complete authentication state management
/// Features:
/// - Sign in/up/out
/// - Current user management
/// - Loading states
/// - Error handling
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Sign in
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUser = await _authRepository.signIn(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
    String? childName,
    int? childAge,
    String? specialization,
    String? licenseNumber,
    int? yearsOfExperience,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUser = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
        phone: phone,
        childName: childName,
        childAge: childAge,
        specialization: specialization,
        licenseNumber: licenseNumber,
        yearsOfExperience: yearsOfExperience,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Load current user
  Future<void> loadCurrentUser() async {
    try {
      _currentUser = await _authRepository.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}