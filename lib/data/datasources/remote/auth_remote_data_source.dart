import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/user_model.dart';
import '../../models/doctor_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginPatient(String email, String password);
  Future<DoctorModel> loginDoctor(String email, String password);
  Future<void> registerPatient(UserModel user, String password);
  Future<void> registerDoctor(DoctorModel doctor, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserModel> loginPatient(String email, String password) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password, 'role': 'patient'},
    );
    return UserModel.fromJson(response.data['user']);
  }

  @override
  Future<DoctorModel> loginDoctor(String email, String password) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password, 'role': 'doctor'},
    );
    return DoctorModel.fromJson(response.data['user']);
  }

  @override
  Future<void> registerPatient(UserModel user, String password) async {
    await _dioClient.post(
      ApiConstants.register,
      data: {
        'user': user.toJson(),
        'password': password,
        'role': 'patient',
      },
    );
  }

  @override
  Future<void> registerDoctor(DoctorModel doctor, String password) async {
    await _dioClient.post(
      ApiConstants.register,
      data: {
        'user': doctor.toJson(),
        'password': password,
        'role': 'doctor',
      },
    );
  }

  @override
  Future<void> logout() async {
    // Implement token invalidation API call if needed by backend
  }
}
