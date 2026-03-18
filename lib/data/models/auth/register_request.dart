class RegisterRequest {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;
  final String role;
  final String? childName;
  final int? childAge;
  final String? doctorNumber;
  final String? clinicLocation;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
    this.childName,
    this.childAge,
    this.doctorNumber,
    this.clinicLocation,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': role,
    };
    if (childName != null) map['child_name'] = childName;
    if (childAge != null) map['child_age'] = childAge;
    if (doctorNumber != null) map['doctor_number'] = doctorNumber;
    if (clinicLocation != null) map['clinic_location'] = clinicLocation;
    return map;
  }
}
