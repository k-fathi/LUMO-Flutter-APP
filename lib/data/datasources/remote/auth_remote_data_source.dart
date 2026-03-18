import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../models/auth/auth_models.dart';

// ─────────────────────────────────────────────
//  Abstract contract
// ─────────────────────────────────────────────

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<MessageResponse> verifyOtp(VerifyOtpRequest request);
  Future<MessageResponse> resendOtp(ResendOtpRequest request);
  Future<MessageResponse> forgotPassword(ForgotPasswordRequest request);
  Future<MessageResponse> verifyResetOtp(VerifyOtpRequest request);
  Future<MessageResponse> resetPassword(ResetPasswordRequest request);
  Future<MessageResponse> logout();
}

// ─────────────────────────────────────────────
//  Implementation
// ─────────────────────────────────────────────

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  // ── Login ──────────────────────────────────
  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Register ───────────────────────────────
  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.register,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Verify OTP (registration) ──────────────
  @override
  Future<MessageResponse> verifyOtp(VerifyOtpRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.verifyOtp,
      data: request.toJson(),
    );
    return MessageResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Resend OTP ─────────────────────────────
  @override
  Future<MessageResponse> resendOtp(ResendOtpRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.resendOtp,
      data: request.toJson(),
    );
    return MessageResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Forgot Password ───────────────────────
  @override
  Future<MessageResponse> forgotPassword(ForgotPasswordRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.forgotPassword,
      data: request.toJson(),
    );
    return MessageResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Verify Reset OTP ──────────────────────
  @override
  Future<MessageResponse> verifyResetOtp(VerifyOtpRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.verifyResetOtp,
      data: request.toJson(),
    );
    return MessageResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Reset Password ────────────────────────
  @override
  Future<MessageResponse> resetPassword(ResetPasswordRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.resetPassword,
      data: request.toJson(),
    );
    return MessageResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Logout ────────────────────────────────
  @override
  Future<MessageResponse> logout() async {
    final response = await _dioClient.post(ApiConstants.logout);
    return MessageResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
