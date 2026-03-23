import 'package:flutter/material.dart';
import '../../data/datasources/local_data_source.dart';
import '../../data/repositories/patient_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/connection_request_model.dart';

class PatientProvider with ChangeNotifier {
  final LocalDataSource _localDataSource;
  final PatientRepository _patientRepository;
  final ProfileRepository _profileRepository;

  List<UserModel> _patients = [];
  List<UserModel> _doctors = [];
  List<ConnectionRequestModel> _joinRequests = [];
  bool _isLoading = false;
  String? _error;

  PatientProvider(
    this._localDataSource,
    this._patientRepository,
    this._profileRepository,
  ) {
    _loadLocalData();
  }

  // Getters
  List<UserModel> get patients => _patients;
  List<UserModel> get doctors => _doctors;
  List<ConnectionRequestModel> get joinRequests => _joinRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalPatients => _patients.length;
  int get pendingRequestsCount => _joinRequests.length;
  double get patientsTrend => 0.0; // Simplified for now

  void _loadLocalData() {
    final cachedPatients = _localDataSource.getPatients();
    if (cachedPatients != null) {
      _patients = cachedPatients.map((e) => UserModel.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> fetchDoctors(List<String> doctorIds) async {
    if (doctorIds.isEmpty) {
      _doctors = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<UserModel> fetchedDoctors = [];
      for (final idStr in doctorIds) {
        final id = int.tryParse(idStr);
        if (id != null) {
          final doctor = await _profileRepository.getUserProfile(id);
          if (doctor != null) {
            fetchedDoctors.add(doctor);
          }
        }
      }
      _doctors = fetchedDoctors;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPatients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _patients = await _patientRepository.getDoctorPatients();
      await _localDataSource.savePatients(_patients.map((p) => p.toJson()).toList());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRequests() async {
    _setLoading(true);
    try {
      final requests = await _patientRepository.getPendingRequests();
      _joinRequests = requests;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPatientRequest(int patientId) async {
    _setLoading(true);
    try {
      await _patientRepository.sendPatientRequest(patientId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> disconnectPatient(int patientId) async {
    _setLoading(true);
    try {
      await _patientRepository.disconnectPatient(patientId);
      // Immediately remove the disconnected patient from local cache
      _patients.removeWhere((p) => p.id == patientId);
      notifyListeners();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> acceptPatientRequest(ConnectionRequestModel request) async {
    _setLoading(true);
    try {
      await _patientRepository.acceptRequest(int.parse(request.id));

      // Local updates for immediate UI feedback
      _joinRequests.removeWhere((r) => r.id == request.id);

      // Re-fetch patients to update the list
      await fetchPatients();

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> rejectPatientRequest(ConnectionRequestModel request) async {
    _setLoading(true);
    try {
      await _patientRepository.rejectRequest(int.parse(request.id));

      // Local update
      _joinRequests.removeWhere((r) => r.id == request.id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void resetState() {
    _patients = [];
    _joinRequests = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<List<UserModel>> searchPatients(String query) async {
    _setLoading(true);
    try {
      final results = await _patientRepository.searchUsers(query);
      _error = null;
      return results;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
