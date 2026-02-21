import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/user_model.dart'; // Using UserModel as Patient model for now

abstract class PatientRemoteDataSource {
  Future<List<UserModel>> getDoctorPatients();
  Future<Map<String, dynamic>> getPatientInsights(String patientId);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final DioClient _dioClient;

  PatientRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<UserModel>> getDoctorPatients() async {
    final response = await _dioClient.get(ApiConstants.getPatients);
    final List<dynamic> data = response.data['patients'];
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> getPatientInsights(String patientId) async {
    final response = await _dioClient.get(
      ApiConstants.getPatientInsights.replaceAll('{id}', patientId),
    );
    return response.data['insights'];
  }
}
