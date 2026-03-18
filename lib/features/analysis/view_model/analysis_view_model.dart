import 'package:flutter/material.dart';

import '../../../data/repositories/analysis_repository.dart';
import '../../../data/models/child_analysis_model.dart';
import '../../../core/enums/child_state.dart';

class AnalysisViewModel extends ChangeNotifier {
  final AnalysisRepository _analysisRepository;

  AnalysisViewModel(this._analysisRepository);

  bool _isLoading = false;
  String? _errorMessage;
  List<ChildAnalysisModel> _analyses = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ChildAnalysisModel> get analyses => _analyses;

  // Load parent analyses
  Future<void> loadParentAnalyses(int parentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _analyses = await _analysisRepository.getParentAnalyses(parentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load doctor patients analyses
  Future<void> loadDoctorPatientsAnalyses(int doctorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _analyses = await _analysisRepository.getDoctorPatientAnalyses(doctorId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create analysis
  Future<bool> createAnalysis({
    required int parentId,
    required String parentName,
    required String childName,
    required int doctorId,
    required String doctorName,
    required ChildState currentState,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final analysis = await _analysisRepository.createAnalysis(
        parentId: parentId,
        parentName: parentName,
        childName: childName,
        doctorId: doctorId,
        doctorName: doctorName,
        date: DateTime.now(),
        currentState: currentState,
        notes: notes,
      );

      _analyses.insert(0, analysis);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update analysis
  Future<bool> updateAnalysis({
    required String analysisId,
    required ChildState currentState,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _analysisRepository.updateAnalysis(
        analysisId: analysisId,
        date: DateTime.now(),
        currentState: currentState,
        notes: notes,
      );

      final index = _analyses.indexWhere((a) => a.id == analysisId);
      if (index != -1) {
        _analyses[index] = _analyses[index].copyWith(
          currentState: currentState,
          notes: notes,
          updatedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete analysis (if needed)
  Future<bool> deleteAnalysis(String analysisId) async {
    _errorMessage = null;

    try {
      // TODO: Implement in repository
      _analyses.removeWhere((a) => a.id == analysisId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
