import '../datasources/remote/patient_remote_data_source.dart';
import '../models/user_model.dart';
import '../models/connection_request_model.dart';

class PatientRepository {
  final PatientRemoteDataSource _remoteDataSource;

  PatientRepository(this._remoteDataSource);

  Future<List<UserModel>> getDoctorPatients() async {
    try {
      return await _remoteDataSource.getDoctorPatients();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPatientRequest(int patientId) async {
    try {
      await _remoteDataSource.sendPatientRequest(patientId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> disconnectPatient(int patientId) async {
    try {
      await _remoteDataSource.disconnectPatient(patientId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptRequest(int requestId) async {
    try {
      await _remoteDataSource.acceptRequest(requestId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectRequest(int requestId) async {
    try {
      await _remoteDataSource.rejectRequest(requestId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ConnectionRequestModel>> getPendingRequests() async {
    try {
      return await _remoteDataSource.getPendingRequests();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPatientInsights(String patientId) async {
    try {
      return await _remoteDataSource.getPatientInsights(patientId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      return await _remoteDataSource.searchUsers(query);
    } catch (e) {
      rethrow;
    }
  }
}
