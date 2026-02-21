import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/user_model.dart';
import '../../models/doctor_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getPatientProfile();
  Future<DoctorModel> getDoctorProfile();
  Future<void> updatePatientProfile(UserModel user);
  Future<void> updateDoctorProfile(DoctorModel doctor);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;

  ProfileRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserModel> getPatientProfile() async {
    final response = await _dioClient.get(ApiConstants.getProfile);
    return UserModel.fromJson(response.data['user']);
  }

  @override
  Future<DoctorModel> getDoctorProfile() async {
    final response = await _dioClient.get(ApiConstants.getProfile);
    return DoctorModel.fromJson(response.data['doctor']);
  }

  @override
  Future<void> updatePatientProfile(UserModel user) async {
    await _dioClient.put(
      ApiConstants.updateProfile,
      data: user.toJson(),
    );
  }

  @override
  Future<void> updateDoctorProfile(DoctorModel doctor) async {
    await _dioClient.put(
      ApiConstants.updateProfile,
      data: doctor.toJson(),
    );
  }
}
