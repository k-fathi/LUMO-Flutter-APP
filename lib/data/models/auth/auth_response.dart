import '../user_model.dart';
import '../parent_model.dart';
import '../doctor_model.dart';
import '../../../core/enums/user_role.dart';

class AuthResponse {
  final bool status;
  final String message;
  final String? token;
  final UserModel? user;

  const AuthResponse({
    required this.status,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Robust status parsing (bool or int)
    final bool statusValue = json['status'] == true ||
        json['status'] == 1 ||
        json['status'] == '1' ||
        json['status'] == 'true';

    final data = json['data'] as Map<String, dynamic>?;
    final userMap = data?['user'] as Map<String, dynamic>?;

    UserModel? parsedUser;
    if (userMap != null) {
      final role =
          UserRole.fromString(userMap['role']?.toString() ?? 'patient');
      if (role == UserRole.parent) {
        parsedUser = ParentModel.fromJson(userMap);
      } else if (role == UserRole.doctor) {
        parsedUser = DoctorModel.fromJson(userMap);
      } else {
        parsedUser = UserModel.fromJson(userMap);
      }
    }

    return AuthResponse(
      status: statusValue,
      message: json['msg']?.toString() ?? json['message']?.toString() ?? '',
      token: data?['token']?.toString(),
      user: parsedUser,
    );
  }
}
