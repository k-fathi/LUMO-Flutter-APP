import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/datasources/local_data_source.dart';

class PatientProvider with ChangeNotifier {
  final LocalDataSource _localDataSource;

  List<MockPatient> _patients = [];
  List<JoinRequest> _joinRequests = [];
  int _previousPatientsCount = 2; // Baseline for trend calculation

  PatientProvider(this._localDataSource) {
    _loadState();
  }

  void _loadState() {
    final cachedPatients = _localDataSource.getPatients();
    if (cachedPatients != null) {
      _patients = cachedPatients.map((e) => MockPatient.fromJson(e)).toList();
    } else {
      _patients = _getMockPatients();
    }

    final cachedRequests = _localDataSource.getJoinRequests();
    if (cachedRequests != null) {
      _joinRequests =
          cachedRequests.map((e) => JoinRequest.fromJson(e)).toList();
    } else {
      _joinRequests = [
        const JoinRequest(id: '1', name: 'Sarah Ali', childName: 'Omar'),
        const JoinRequest(id: '2', name: 'Mohamed Hassan', childName: 'Kareem'),
      ];
    }
    _previousPatientsCount =
        _patients.isEmpty ? 0 : 2; // Keep mock baseline logic simple
    notifyListeners();
  }

  Future<void> _saveState() async {
    await _localDataSource
        .savePatients(_patients.map((e) => e.toJson()).toList());
    await _localDataSource
        .saveJoinRequests(_joinRequests.map((e) => e.toJson()).toList());
  }

  List<MockPatient> _getMockPatients() {
    return [
      const MockPatient(
        id: '1',
        childName: 'أحمد محمد',
        age: '٥ سنوات',
        parentName: 'محمد أحمد',
        lastUpdate: 'منذ ساعتين',
        avatarColor: AppColors.primary,
        sessionsCompleted: 12,
        previousSessions: 10,
        engagementRate: 0.75,
        previousEngagementRate: 0.70,
      ),
      const MockPatient(
        id: '2',
        childName: 'ليلى خالد',
        age: '٤ سنوات',
        parentName: 'خالد عبدالله',
        lastUpdate: 'منذ يوم',
        avatarColor: Color(0xFF8B5CF6), // Purple
        sessionsCompleted: 24,
        previousSessions: 21,
        engagementRate: 0.85,
        previousEngagementRate: 0.80,
      ),
      const MockPatient(
        id: '3',
        childName: 'يوسف سعيد',
        age: '٦ سنوات',
        parentName: 'سعيد يوسف',
        lastUpdate: 'منذ 3 أيام',
        avatarColor: Color(0xFF22C55E), // Green
        sessionsCompleted: 8,
        previousSessions: 9, // Down trend
        engagementRate: 0.60,
        previousEngagementRate: 0.65, // Down trend
      ),
    ];
  }

  List<MockPatient> get patients => _patients;
  List<JoinRequest> get joinRequests => _joinRequests;

  int get totalPatients => _patients.length;
  int get pendingRequestsCount => _joinRequests.length;

  double get patientsTrend {
    if (_previousPatientsCount == 0) return 0.0;
    return ((_patients.length - _previousPatientsCount) /
            _previousPatientsCount) *
        100;
  }

  void acceptRequest(JoinRequest request) {
    _joinRequests.removeWhere((r) => r.id == request.id);
    _patients.insert(
      0,
      MockPatient(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        childName: request.childName,
        age: '٥ سنوات', // Mock placeholder
        parentName: request.name,
        lastUpdate: 'الآن',
        avatarColor: AppColors.primary,
        childPhotoUrl: request.childPhotoUrl, // Transfer photo if any
        sessionsCompleted: 0,
        previousSessions: 0,
        engagementRate: 0.0,
        previousEngagementRate: 0.0,
      ),
    );
    _saveState();
    notifyListeners();
  }

  void rejectRequest(JoinRequest request) {
    _joinRequests.removeWhere((r) => r.id == request.id);
    _saveState();
    notifyListeners();
  }

  void removePatient(String patientId) {
    _patients.removeWhere((p) => p.id == patientId);
    _saveState();
    notifyListeners();
  }

  void clearState() {
    _patients = [];
    _joinRequests = [];
    _previousPatientsCount = 0;
    notifyListeners();
  }
}

class JoinRequest {
  final String id;
  final String name;
  final String childName;
  final String? childPhotoUrl; // Added

  const JoinRequest({
    required this.id,
    required this.name,
    required this.childName,
    this.childPhotoUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'childName': childName,
        'childPhotoUrl': childPhotoUrl,
      };

  factory JoinRequest.fromJson(Map<String, dynamic> json) => JoinRequest(
        id: json['id'] as String,
        name: json['name'] as String,
        childName: json['childName'] as String,
        childPhotoUrl: json['childPhotoUrl'] as String?,
      );
}

class MockPatient {
  final String id;
  final String childName;
  final String age;
  final String parentName;
  final String lastUpdate;
  final Color avatarColor;
  final String? childPhotoUrl;
  final int sessionsCompleted;
  final int previousSessions;
  final double engagementRate;
  final double previousEngagementRate;

  const MockPatient({
    required this.id,
    required this.childName,
    required this.age,
    required this.parentName,
    required this.lastUpdate,
    required this.avatarColor,
    this.childPhotoUrl,
    this.sessionsCompleted = 0,
    this.previousSessions = 0,
    this.engagementRate = 0.0,
    this.previousEngagementRate = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'childName': childName,
        'age': age,
        'parentName': parentName,
        'lastUpdate': lastUpdate,
        'avatarColor': avatarColor.value,
        'childPhotoUrl': childPhotoUrl,
        'sessionsCompleted': sessionsCompleted,
        'previousSessions': previousSessions,
        'engagementRate': engagementRate,
        'previousEngagementRate': previousEngagementRate,
      };

  factory MockPatient.fromJson(Map<String, dynamic> json) => MockPatient(
        id: json['id'] as String,
        childName: json['childName'] as String,
        age: json['age'] as String,
        parentName: json['parentName'] as String,
        lastUpdate: json['lastUpdate'] as String,
        avatarColor: Color(json['avatarColor'] as int),
        childPhotoUrl: json['childPhotoUrl'] as String?,
        sessionsCompleted: json['sessionsCompleted'] as int? ?? 0,
        previousSessions: json['previousSessions'] as int? ?? 0,
        engagementRate: json['engagementRate'] as double? ?? 0.0,
        previousEngagementRate:
            json['previousEngagementRate'] as double? ?? 0.0,
      );
}
