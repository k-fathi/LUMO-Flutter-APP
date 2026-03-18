class LoginRequest {
  final String phone;
  final String password;
  final String? fcmToken;

  const LoginRequest({
    required this.phone,
    required this.password,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'phone': phone,
      'password': password,
    };
    if (fcmToken != null) {
      map['fcm_token'] = fcmToken;
    }
    return map;
  }
}
