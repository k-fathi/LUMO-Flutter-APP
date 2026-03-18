import '../datasources/firebase_data_source.dart';
import '../datasources/local_data_source.dart';
import '../models/child_analysis_model.dart';
import '../../core/enums/child_state.dart';

class AnalysisRepository {
  final FirebaseDataSource _firebaseDataSource;
  final LocalDataSource _localDataSource;

  AnalysisRepository(this._firebaseDataSource, this._localDataSource);

  // ==================== ANALYSIS OPERATIONS ====================

  Future<ChildAnalysisModel> createAnalysis({
    required int parentId,
    required String parentName,
    required String childName,
    required int doctorId,
    required String doctorName,
    required DateTime date,
    String? notes,
    required ChildState currentState,
    List<AnalysisStateModel>? states,
    String? attachmentUrl,
  }) async {
    final now = DateTime.now();

    // Default states if not provided
    final defaultStates = states ??
        [
          const AnalysisStateModel(state: ChildState.critical, label: 'حرج'),
          const AnalysisStateModel(state: ChildState.bad, label: 'سيء'),
          const AnalysisStateModel(state: ChildState.moderate, label: 'متوسط'),
          const AnalysisStateModel(state: ChildState.good, label: 'جيد'),
          const AnalysisStateModel(state: ChildState.excellent, label: 'ممتاز'),
        ];

    // Mark the current state
    final updatedStates = defaultStates.map((state) {
      return state.copyWith(isCurrent: state.state == currentState);
    }).toList();

    final analysisData = {
      'parent_id': parentId.toString(),
      'parent_name': parentName,
      'child_name': childName,
      'doctor_id': doctorId.toString(),
      'doctor_name': doctorName,
      'date': date.toIso8601String(),
      'notes': notes,
      'current_state': currentState.name,
      'states': updatedStates.map((s) => s.toJson()).toList(),
      'attachment_url': attachmentUrl,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final analysisId = await _firebaseDataSource.createAnalysis(analysisData);
    analysisData['id'] = analysisId;

    return ChildAnalysisModel.fromJson(analysisData);
  }

  Future<void> updateAnalysis({
    required String analysisId,
    DateTime? date,
    String? notes,
    ChildState? currentState,
    String? attachmentUrl,
  }) async {
    final updateData = <String, dynamic>{};

    if (date != null) updateData['date'] = date.toIso8601String();
    if (notes != null) updateData['notes'] = notes;
    if (currentState != null) {
      updateData['current_state'] = currentState.name;
      // TODO: Update states array to mark new current state
    }
    if (attachmentUrl != null) updateData['attachment_url'] = attachmentUrl;

    await _firebaseDataSource.updateAnalysis(analysisId, updateData);
  }

  Future<List<ChildAnalysisModel>> getParentAnalyses(int parentId) async {
    // Check cache first
    final cached = _localDataSource.getCachedAnalyses(
      parentId.toString(),
      maxAge: const Duration(minutes: 10),
    );
    if (cached != null) {
      return cached
          .map((analysisData) => ChildAnalysisModel.fromJson(analysisData))
          .toList();
    }

    // Fetch from Firebase
    final analysesList =
        await _firebaseDataSource.getParentAnalyses(parentId.toString());

    // Cache the results
    await _localDataSource.cacheAnalyses(parentId.toString(), analysesList);

    return analysesList
        .map((analysisData) => ChildAnalysisModel.fromJson(analysisData))
        .toList();
  }

  Future<List<ChildAnalysisModel>> getDoctorPatientAnalyses(
      int doctorId) async {
    final analysesList =
        await _firebaseDataSource.getDoctorPatientAnalyses(doctorId.toString());
    return analysesList
        .map((analysisData) => ChildAnalysisModel.fromJson(analysisData))
        .toList();
  }

  Stream<List<ChildAnalysisModel>> streamParentAnalyses(int parentId) {
    return _firebaseDataSource.streamParentAnalyses(parentId.toString()).map(
          (analysesList) => analysesList
              .map((analysisData) => ChildAnalysisModel.fromJson(analysisData))
              .toList(),
        );
  }
}
