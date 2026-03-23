import 'package:shared_preferences/shared_preferences.dart';

import '../datasources/remote/auth_remote_data_source.dart';
import '../models/auth/auth_models.dart';

/// Repository that orchestrates authentication operations.
///
/// Responsibilities:
/// - Delegates all HTTP work to [AuthRemoteDataSource].
/// - Persists the auth token in [SharedPreferences] on login / register.
/// - Clears the token on logout.
class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';

  AuthRepository(this._remoteDataSource, this._prefs);

  // ─────────────────────────────────────────────
  //  Login
  // ─────────────────────────────────────────────

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _remoteDataSource.login(request);
    await _persistToken(response.token);
    return response;
  }

  // ─────────────────────────────────────────────
  //  Register
  // ─────────────────────────────────────────────

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _remoteDataSource.register(request);
    await _persistToken(response.token);
    return response;
  }

  // ─────────────────────────────────────────────
  //  OTP — Registration Flow
  // ─────────────────────────────────────────────

  Future<MessageResponse> verifyOtp(VerifyOtpRequest request) async {
    return _remoteDataSource.verifyOtp(request);
  }

  Future<MessageResponse> resendOtp(ResendOtpRequest request) async {
    return _remoteDataSource.resendOtp(request);
  }

  // ─────────────────────────────────────────────
  //  Forgot / Reset Password Flow
  // ─────────────────────────────────────────────

  Future<MessageResponse> forgotPassword(ForgotPasswordRequest request) async {
    return _remoteDataSource.forgotPassword(request);
  }

  Future<MessageResponse> verifyResetOtp(VerifyOtpRequest request) async {
    return _remoteDataSource.verifyResetOtp(request);
  }

  Future<MessageResponse> resetPassword(ResetPasswordRequest request) async {
    return _remoteDataSource.resetPassword(request);
  }

  // ─────────────────────────────────────────────
  //  Change Password
  // ─────────────────────────────────────────────

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  // ─────────────────────────────────────────────
  //  Logout
  // ─────────────────────────────────────────────

  Future<MessageResponse?> logout() async {
    try {
      final response = await _remoteDataSource.logout();
      return response;
    } catch (e) {
      return null;
    } finally {
      await _clearToken();
    }
  }

  // ─────────────────────────────────────────────
  //  Token Helpers
  // ─────────────────────────────────────────────

  /// Returns the currently stored auth token, if any.
  String? get token => _prefs.getString(_tokenKey);

  /// `true` when a valid token is persisted.
  bool get isLoggedIn => token != null;

  Future<void> _persistToken(String? token) async {
    if (token != null && token.isNotEmpty) {
      await _prefs.setString(_tokenKey, token);
    }
  }

  Future<void> _clearToken() async {
    await _prefs.remove(_tokenKey);
  }
}
