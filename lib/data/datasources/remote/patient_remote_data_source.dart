import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/enums/user_role.dart';
import '../../models/user_model.dart';
import '../../models/parent_model.dart';
import '../../models/doctor_model.dart';
import '../../models/connection_request_model.dart';

abstract class PatientRemoteDataSource {
  Future<List<UserModel>> getDoctorPatients();
  Future<Map<String, dynamic>> getPatientInsights(String patientId);
  Future<void> sendPatientRequest(int patientId);
  Future<void> disconnectPatient(int patientId);
  Future<void> acceptRequest(int requestId);
  Future<void> rejectRequest(int requestId);
  Future<List<ConnectionRequestModel>> getPendingRequests();
  Future<List<UserModel>> searchUsers(String query);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final DioClient _dioClient;

  PatientRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<UserModel>> getDoctorPatients() async {
    final response = await _dioClient.get(ApiConstants.getPatients);
    final responseData = response.data;
    List<dynamic> data = [];

    if (responseData is Map<String, dynamic>) {
      data = responseData['patients'] ?? responseData['data'] ?? [];
    } else if (responseData is List) {
      data = responseData;
    }

    return data.map((json) => _parseUser(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> getPatientInsights(String patientId) async {
    final response = await _dioClient.get(
      ApiConstants.getPatientInsights.replaceAll('{id}', patientId),
    );
    return response.data['insights'] ?? {};
  }

  @override
  Future<void> sendPatientRequest(int patientId) async {
    await _dioClient.post(
      ApiConstants.patientRequest,
      data: {'patient_id': patientId},
    );
  }

  @override
  Future<void> disconnectPatient(int patientId) async {
    await _dioClient.post(
      '${ApiConstants.disconnectPatient.replaceAll('{id}', patientId.toString())}?_method=DELETE',
    );
  }

  @override
  Future<void> acceptRequest(int requestId) async {
    await _dioClient.post(
      ApiConstants.acceptRequest.replaceAll('{id}', requestId.toString()),
    );
  }

  @override
  Future<void> rejectRequest(int requestId) async {
    await _dioClient.post(
      ApiConstants.rejectRequest.replaceAll('{id}', requestId.toString()),
    );
  }

  @override
  Future<List<ConnectionRequestModel>> getPendingRequests() async {
    final response = await _dioClient.get(ApiConstants.getPendingRequests);
    final responseData = response.data;
    List<dynamic> data = [];

    if (responseData is Map<String, dynamic>) {
      data = responseData['requests'] ?? responseData['data'] ?? [];
    } else if (responseData is List) {
      data = responseData;
    }

    return data.map((json) => ConnectionRequestModel.fromJson(json)).toList();
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    final trimmedQuery = query.trim();
    final List<dynamic> combinedRaw = [];

    // Helper to perform search and add results safely
    Future<void> performSearch(Map<String, dynamic> params) async {
      try {
        final response = await _dioClient.get(
          ApiConstants.searchUsers,
          queryParameters: params,
        );
        combinedRaw.addAll(_extractListFromResponse(response.data));
      } catch (e) {
        // Swallow role-based errors but keep going
        if (kDebugMode) print('Search variation $params failed: $e');
      }
    }

    // Try variations in parallel for performance, but catch individual errors
    await Future.wait([
      performSearch({'query': trimmedQuery}), // Broad search often works best
      performSearch({'query': trimmedQuery, 'role': 'patient'}),
      performSearch({'query': trimmedQuery, 'role': 'parent'}),
    ]);

    // If still empty, try one more time without anything else
    if (combinedRaw.isEmpty) {
      await performSearch({'query': trimmedQuery});
    }

    // Deduplicate and parse safely
    final List<UserModel> results = [];
    final Set<int> seenIds = {};

    for (var item in combinedRaw) {
      if (item is Map<String, dynamic>) {
        try {
          final user = _parseUser(item);
          // Only add valid users we haven't seen yet
          if (user.id != 0 && !seenIds.contains(user.id)) {
            results.add(user);
            seenIds.add(user.id);
          }
        } catch (e) {
          if (kDebugMode) print('Error parsing search user item: $e');
        }
      }
    }

    return results;
  }

  List<dynamic> _extractListFromResponse(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) {
      if (responseData is List) return responseData;
      return [];
    }

    // Prioritize standard keys
    final list = responseData['data'] ??
        responseData['results'] ??
        responseData['users'] ??
        responseData['patients'];

    if (list is List) return list;

    // Deep search in 'data' map if present
    if (responseData['data'] is Map<String, dynamic>) {
      final dataMap = responseData['data'] as Map<String, dynamic>;
      final innerList = dataMap['users'] ?? dataMap['patients'] ?? dataMap['results'] ?? dataMap['data'];
      if (innerList is List) return innerList;
    }

    // Last resort: find any list that isn't empty
    for (var entry in responseData.entries) {
      if (entry.value is List && (entry.value as List).isNotEmpty) {
        // Skip metadata-like lists if possible
        if (entry.key == 'links' || entry.key == 'meta') continue;
        return entry.value;
      }
    }

    return [];
  }

  UserModel _parseUser(Map<String, dynamic> json) {
    final role = UserRole.fromString(json['role']?.toString() ?? 'patient');
    if (role == UserRole.parent) {
      return ParentModel.fromJson(json);
    } else if (role == UserRole.doctor) {
      return DoctorModel.fromJson(json);
    }
    return UserModel.fromJson(json);
  }
}
