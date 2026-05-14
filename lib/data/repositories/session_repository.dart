import '../../data/models/session_analysis_model.dart';
import '../datasources/remote/session_remote_data_source.dart';

class SessionRepository {
  final SessionRemoteDataSource _sessionRemoteDataSource;

  SessionRepository(this._sessionRemoteDataSource);

  // ── Create ──────────────────────────────────────────────────────────────

  /// Creates a new session with segments for a patient.
  Future<SessionAnalysisModel> createSession({
    required int patientId,
    String? notes,
    required List<Map<String, dynamic>> segments,
  }) async {
    final json = await _sessionRemoteDataSource.createSession(
      patientId: patientId,
      notes: notes,
      segments: segments,
    );
    return SessionAnalysisModel.fromApiJson(json);
  }

  // ── Read ────────────────────────────────────────────────────────────────

  /// Fetches full session details (including emotion_distribution & gaze_distribution).
  Future<SessionAnalysisModel> getSessionDetails(int sessionId) async {
    final json = await _sessionRemoteDataSource.getSessionDetails(sessionId);
    return SessionAnalysisModel.fromApiJson(json);
  }

  /// Fetches all sessions for a specific patient (doctor's view).
  Future<List<SessionAnalysisModel>> getPatientSessions(int patientId) async {
    final list = await _sessionRemoteDataSource.getPatientSessions(patientId);
    return list.map((json) => SessionAnalysisModel.fromApiJson(json)).toList();
  }

  /// Fetches the logged-in patient's own sessions.
  Future<List<SessionAnalysisModel>> getMySessions() async {
    final list = await _sessionRemoteDataSource.getMySessions();
    return list.map((json) => SessionAnalysisModel.fromApiJson(json)).toList();
  }

  // ── Session Lifecycle ──────────────────────────────────────────────────

  Future<void> startSession(int sessionId) async {
    await _sessionRemoteDataSource.startSession(sessionId: sessionId);
  }

  Future<void> endSession(int sessionId) async {
    await _sessionRemoteDataSource.endSession(sessionId);
  }

  // ── Update / Delete ────────────────────────────────────────────────────

  Future<void> updateSession({
    required int sessionId,
    String? notes,
    List<Map<String, dynamic>>? segments,
  }) async {
    await _sessionRemoteDataSource.updateSession(
      sessionId: sessionId,
      notes: notes,
      segments: segments,
    );
  }

  Future<void> deleteSession(int sessionId) async {
    await _sessionRemoteDataSource.deleteSession(sessionId);
  }

  // ── Segments ───────────────────────────────────────────────────────────

  Future<void> startSegment(int segmentId) async {
    await _sessionRemoteDataSource.startSegment(segmentId);
  }

  Future<void> completeSegment(int segmentId, {Map<String, dynamic>? data}) async {
    await _sessionRemoteDataSource.completeSegment(segmentId, data: data);
  }
}
