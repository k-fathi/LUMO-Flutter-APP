import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../data/models/auth/auth_models.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/datasources/local_data_source.dart';
import '../../core/network/api_exception.dart';

// ✅ شلنا imports الـ ViewModels — مش المفروض AuthProvider يعتمد عليهم

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  final LocalDataSource _localDataSource;

  AuthProvider(
      this._authRepository, this._profileRepository, this._localDataSource);

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // ✅ Callback لـ session change — بيتسجل من بره بدل الـ circular coupling
  VoidCallback? _onSessionChangeCallback;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authRepository.isLoggedIn;

  /// يتسجل من main.dart أو app.dart عشان يعمل reset للـ ViewModels عند الـ logout أو الـ login
  /// بدل ما AuthProvider يعتمد على الـ ViewModels مباشرة
  void setSessionChangeCallback(VoidCallback callback) {
    _onSessionChangeCallback = callback;
  }

  // ─────────────────────────────────────────────
  //  Initialize — restore session from stored token
  // ─────────────────────────────────────────────

  Future<void> init() async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    if (!_authRepository.isLoggedIn) {
      _setLoading(false);
      return;
    }

    // ── Priority 1: Restore from local cache ──
    final cachedUserJson = _localDataSource.getCurrentUser();
    if (cachedUserJson != null) {
      try {
        _currentUser = UserModel.fromJson(cachedUserJson);
      } catch (e) {
        debugPrint('Cached user corrupt: $e');
        await logout();
        await _localDataSource.clearAll();
        _setLoading(false);
        notifyListeners();
        return;
      }
    }

    // ── Priority 2: Refresh from API ──
    final userIdStr = _localDataSource.getCurrentUserId();
    // ✅ حتى لو مفيش userId بس فيه token (زي بعد الـ OTP)، نحاول نجيب الـ profile
    if (userIdStr != null || _authRepository.isLoggedIn) {
      final userId = int.tryParse(userIdStr ?? '0') ?? 0;
      try {
        final refreshed = await _profileRepository
            .getUserProfile(userId)
            .timeout(const Duration(seconds: 10));
        if (refreshed != null) {
          _currentUser = refreshed;
          await _localDataSource.saveCurrentUser(refreshed.toJson());
          notifyListeners(); // Force UI update with fresh counts
        }
      } catch (e) {
        // ✅ بدل string matching — بنتحقق من نوع الـ exception
        final isUnauthenticated = _isUnauthenticatedError(e);
        if (isUnauthenticated) {
          debugPrint('Token expired. Forcing logout.');
          await logout();
          await _localDataSource.clearAll();
          _setLoading(false);
          notifyListeners();
          return;
        }
        debugPrint('Profile refresh failed (keeping cache): $e');
      }
    }

    // ── Priority 3: Last resort ──
    if (_currentUser == null) {
      await logout();
    }

    _setLoading(false);
    notifyListeners();
  }

  /// ✅ تحقق من الـ 401 بطريقة صح بدل string matching
  bool _isUnauthenticatedError(Object e) {
    if (e is ApiException) {
      return e.statusCode == 401;
    }
    // Fallback للـ DioException أو غيره
    final msg = e.toString().toLowerCase();
    return msg.contains('401') || msg.contains('unauthenticated');
  }

  /// ✅ تحويل الخطأ لرسالة عربية مفهومة للمستخدم
  String _mapErrorToMessage(Object e) {
    if (e is ApiException) {
      if (e.statusCode == 401) {
        return 'رقم الهاتف أو كلمة المرور غير صحيحة';
      }
      if (e.statusCode == 422) {
        // إذا كان هناك رسالة من الباك اند نستخدمها، وإلا رسالة افتراضية
        return e.message.isNotEmpty ? e.message : 'البيانات المدخلة غير صحيحة أو مستخدمة مسبقاً';
      }
      return e.message.isNotEmpty ? e.message : 'حدث خطأ في الاتصال بالسيرفر';
    }
    
    final msg = e.toString().toLowerCase();
    if (msg.contains('401') || msg.contains('unauthenticated')) {
      return 'رقم الهاتف أو كلمة المرور غير صحيحة';
    }
    if (msg.contains('422')) {
      return 'البيانات المدخلة غير صحيحة أو مستخدمة مسبقاً';
    }
    if (msg.contains('network') || msg.contains('socket') || msg.contains('timeout')) {
      return 'فشل الاتصال بالإنترنت، يرجى المحاولة لاحقاً';
    }
    
    return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً';
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
      final fcmToken = await _getFcmToken();

      final request = LoginRequest(
        phone: phone,
        password: password,
        fcmToken: fcmToken,
      );

      final AuthResponse response = await _authRepository.login(request);

      if (!response.status) {
        _errorMessage = response.message;
        return false;
      }

      if (response.user != null) {
        _currentUser = response.user;
        await _localDataSource.saveCurrentUser(_currentUser!.toJson());
        notifyListeners();
        if (onSuccess != null) onSuccess();
      }

      // Final safety: wipe error message before returning true
      _errorMessage = null;
      return true;
    } catch (e) {
      // Use the mapped message, but also store the literal exception for diagnostics if it's unexpected
      final mapped = _mapErrorToMessage(e);
      _errorMessage = (mapped == 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً')
          ? 'Error: ${e.toString()}'
          : mapped;
      
      debugPrint('Login error: $e');
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
    String? userImageUrl,
    String? childImageUrl,
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
        avatarFilePath: userImageUrl,
        childPhotoPath: childImageUrl,
      );

      final AuthResponse response = await _authRepository.register(request);

      if (!response.status) {
        _errorMessage = response.message;
        return false;
      }

      if (response.user != null) {
        _currentUser = response.user;
        await _localDataSource.saveCurrentUser(_currentUser!.toJson());
        notifyListeners();
        if (onSuccess != null) onSuccess();
      }
      return true;
    } catch (e) {
      _errorMessage = _mapErrorToMessage(e);
      debugPrint('Register error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  //  OTP
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
      
      // ✅ لو نجح الـ OTP، نحاول نجيب بيانات المستخدم فوراً
      if (response.status) {
        await init();
      }
      
      return response;
    } catch (e) {
      _errorMessage = _mapErrorToMessage(e);
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
      _errorMessage = _mapErrorToMessage(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  //  Forgot / Reset Password
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
      _errorMessage = _mapErrorToMessage(e);
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
      _errorMessage = _mapErrorToMessage(e);
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
      _errorMessage = _mapErrorToMessage(e);
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
      await _localDataSource.saveCurrentUser(updatedUser.toJson());
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _mapErrorToMessage(e);
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

    // ✅ بننادي الـ callback اللي اتسجل من بره لتصفير الـ ViewModels
    try {
      _onSessionChangeCallback?.call();
    } catch (e) {
      debugPrint('Session change callback error (logout): $e');
    }

    _currentUser = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────

  /// Update current user locally in memory and cache
  void updateCurrentUserLocally(UserModel updatedUser) {
    _currentUser = updatedUser;
    _localDataSource.saveCurrentUser(updatedUser.toJson());
    notifyListeners();
  }

  void updateFollowingCount(bool increment) {
    if (_currentUser != null) {
      final currentCount = _currentUser!.followingCount ?? 0;
      final newCount = increment ? currentCount + 1 : (currentCount > 0 ? currentCount - 1 : 0);
      _currentUser = _currentUser!.copyWith(followingCount: newCount);
      _localDataSource.saveCurrentUser(_currentUser!.toJson());
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    clearError();

    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (e) {
      _errorMessage = _mapErrorToMessage(e);
      debugPrint('Change password error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String?> _getFcmToken() async {
    if (kIsWeb) {
      try {
        return await FirebaseMessaging.instance
            .getToken()
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Failed to get FCM token (Web): $e');
        return null;
      }
    }

    // ✅ Desktop platforms — بنرجع null بدل dummy token
    if (Platform.isLinux || Platform.isWindows) {
      debugPrint('FCM not supported on desktop. Skipping token.');
      return null;
    }

    try {
      return await FirebaseMessaging.instance
          .getToken()
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }
}
