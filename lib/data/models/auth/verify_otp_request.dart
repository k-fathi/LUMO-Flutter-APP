class VerifyOtpRequest {
  final String phone;
  final String otp;

  const VerifyOtpRequest({
    required this.phone,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
    };
  }
}
