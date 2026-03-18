import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../data/models/auth/auth_models.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/datasources/local_data_source.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  final LocalDataSource _localDataSource;

  AuthProvider(
      this._authRepository, this._profileRepository, this._localDataSource);

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authRepository.isLoggedIn;

  // ─────────────────────────────────────────────
  //  Initialize — restore session from stored token
  // ─────────────────────────────────────────────

  Future<void> init() async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    if (!_authRepository.isLoggedIn) {
      // No token — user is definitively logged out.
      _setLoading(false);
      return;
    }

    // ── Priority 1: Restore from local cache (always available offline) ──
    final cachedUserJson = _localDataSource.getCurrentUser();
    if (cachedUserJson != null) {
      try {
        _currentUser = UserModel.fromJson(cachedUserJson);
        debugPrint(
            '✅ Session restored from local cache: ${_currentUser?.name}');
      } catch (e) {
        // Cache is corrupted (stale model schema). Wipe and force re-login.
        debugPrint('❌ Cached user JSON is corrupt: $e — clearing session.');
        await logout();
        await _localDataSource.clearAll();
        _setLoading(false);
        notifyListeners();
        return;
      }
    }

    // ── Priority 2: Silently refresh profile from REST API in background ──
    // If this fails (no internet, server down) we keep the cached user.
    // We do NOT force-logout on network failures.
    final userIdStr = _localDataSource.getCurrentUserId();
    if (userIdStr != null) {
      final userId = int.tryParse(userIdStr);
      if (userId != null) {
        try {
          final refreshed = await _profileRepository
              .getUserProfile(userId)
              .timeout(const Duration(seconds: 8));
          if (refreshed != null) {
            _currentUser = refreshed;
            await _localDataSource.saveCurrentUser(refreshed.toJson());
            debugPrint(
                '✅ Profile refreshed from server: ${_currentUser?.name}');
          }
        } catch (e) {
          // Network / Firebase not available — keep cached user, do NOT logout.
          debugPrint('⚠️ Profile refresh failed (keeping cache): $e');
        }
      }
    }

    // ── Priority 3: Last resort — if still no user, token is useless → logout ──
    if (_currentUser == null) {
      debugPrint('❌ Token exists but no cached user found. Forcing logout.');
      await logout();
    }

    _setLoading(false);
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  //  Login
  // ─────────────────────────────────────────────

  Future<bool> login({
    required String phone,
    required String password,
    VoidCallback? onSuccess,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Fetch FCM token
      final fcmToken = await _getFcmToken();

      final request = LoginRequest(
        phone: phone,
        password: password,
        fcmToken: fcmToken,
      );

      final AuthResponse response = await _authRepository.login(request);

      if (response.user != null) {
        _currentUser = response.user;
        // Persist user to local cache so session survives cold starts
        await _localDataSource.saveCurrentUser(_currentUser!.toJson());
        notifyListeners();
        if (onSuccess != null) onSuccess();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  //  Register
  // ─────────────────────────────────────────────

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? childName,
    int? childAge,
    String? doctorNumber,
    String? clinicLocation,
    VoidCallback? onSuccess,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
        childName: childName,
        childAge: childAge,
        doctorNumber: doctorNumber,
        clinicLocation: clinicLocation,
      );

      final AuthResponse response = await _authRepository.register(request);

      if (response.user != null) {
        _currentUser = response.user;
        // Persist user to local cache so session survives cold starts
        await _localDataSource.saveCurrentUser(_currentUser!.toJson());
        notifyListeners();
        if (onSuccess != null) onSuccess();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  //  OTP — Registration flow
  // ─────────────────────────────────────────────

  Future<MessageResponse?> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _authRepository.verifyOtp(
        VerifyOtpRequest(phone: phone, otp: otp),
      );
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<MessageResponse?> resendOtp({required String phone}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _authRepository.resendOtp(
        ResendOtpRequest(phone: phone),
      );
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  //  Forgot / Reset Password flow
  // ─────────────────────────────────────────────

  Future<MessageResponse?> forgotPassword({required String phone}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _authRepository.forgotPassword(
        ForgotPasswordRequest(phone: phone),
      );
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<MessageResponse?> verifyResetOtp({
    required String phone,
    required String otp,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _authRepository.verifyResetOtp(
        VerifyOtpRequest(phone: phone, otp: otp),
      );
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<MessageResponse?> resetPassword({
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String otp,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _authRepository.resetPassword(
        ResetPasswordRequest(
          phone: phone,
          password: password,
          passwordConfirmation: passwordConfirmation,
          otp: otp,
        ),
      );
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  //  Update Profile
  // ─────────────────────────────────────────────

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? avatarFilePath,
    String? childName,
    int? childAge,
    String? childMedicalCondition,
    String? childPhotoUrl,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _errorMessage = null;

    try {
      final updatedUser = await _profileRepository.updateProfile(
        userId: _currentUser!.id,
        name: name,
        phone: phone,
        bio: bio,
        avatarFilePath: avatarFilePath,
        childName: childName,
        childAge: childAge,
        childMedicalCondition: childMedicalCondition,
        childPhotoUrl: childPhotoUrl,
      );
      _currentUser = updatedUser;
      // Persist the fresh user data so the cache stays consistent
      await _localDataSource.saveCurrentUser(updatedUser.toJson());
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  //  Logout
  // ─────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (_) {
      // Ensure local state is cleared even if the API call fails
    }
    _currentUser = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Retrieves the FCM token from Firebase Messaging.
  /// Returns a dummy token on unsupported platforms (Linux/Windows).
  Future<String?> _getFcmToken() async {
    // Check for web first
    if (kIsWeb) {
      try {
        return await FirebaseMessaging.instance.getToken();
      } catch (e) {
        debugPrint('Failed to get FCM token (Web): $e');
        return null;
      }
    }

    // Check for desktop platforms that don't support Firebase Messaging
    if (Platform.isLinux || Platform.isWindows) {
      debugPrint('FCM is not supported on this platform. Using dummy token.');
      return 'dummy_token_for_desktop';
    }

    // Supported mobile/macOS platforms
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }
}
