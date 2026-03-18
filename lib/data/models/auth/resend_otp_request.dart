class ResendOtpRequest {
  final String phone;

  const ResendOtpRequest({
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
    };
  }
}
