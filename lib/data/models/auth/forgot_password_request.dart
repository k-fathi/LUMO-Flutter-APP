class ForgotPasswordRequest {
  final String phone;

  const ForgotPasswordRequest({
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
    };
  }
}
