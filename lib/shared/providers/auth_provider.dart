import 'package:flutter/material.dart';

import 'dart:io';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/enums/user_role.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository);

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Initialize auth state
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authRepository.getCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.signIn(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e; // Re-throw to handle in UI
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
    // Doctor-specific
    String? specialization,
    String? licenseNumber,
    int? yearsOfExperience,
    // Parent-specific
    String? childName,
    int? childAge,
    String? childGender,
    File? childPhoto,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
        phone: phone,
        specialization: specialization,
        licenseNumber: licenseNumber,
        yearsOfExperience: yearsOfExperience,
        childName: childName,
        childAge: childAge,
        childGender: childGender,
        childPhoto: childPhoto,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
