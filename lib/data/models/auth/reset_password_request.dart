class ResetPasswordRequest {
  final String phone;
  final String password;
  final String passwordConfirmation;
  final String otp;

  const ResetPasswordRequest({
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'otp': otp,
    };
  }
}
