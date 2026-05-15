import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';

abstract class SessionRemoteDataSource {
  /// POST /sessions — Create a new session with segments
  Future<Map<String, dynamic>> createSession({
    required int patientId,
    required String? notes,
    required List<Map<String, dynamic>> segments,
    DateTime? scheduledDate,
  });

  /// GET /sessions/{id} — Show session details (with emotion/gaze analysis)
  Future<Map<String, dynamic>> getSessionDetails(int sessionId);

  /// GET /sessions/list/{patientId} — List a patient's sessions (doctor view)
  Future<List<Map<String, dynamic>>> getPatientSessions(int patientId);

  /// GET /sessions/list — List my own sessions (patient view)
  Future<List<Map<String, dynamic>>> getMySessions();

  /// POST /sessions/{id}/start — Start a session
  Future<void> startSession({
    required int sessionId,
  });

  /// POST /sessions/{id}/end — End a session
  Future<void> endSession(int sessionId);

  /// PUT /sessions/{id} — Update session notes/segments
  Future<void> updateSession({
    required int sessionId,
    String? notes,
    List<Map<String, dynamic>>? segments,
  });

  /// DELETE /sessions/{id} — Delete a session
  Future<void> deleteSession(int sessionId);

  /// POST /segments/{id}/start — Start a segment
  Future<void> startSegment(int segmentId);

  /// POST /segments/{id}/complete — Complete a segment
  Future<void> completeSegment(int segmentId, {Map<String, dynamic>? data});
}

class SessionRemoteDataSourceImpl implements SessionRemoteDataSource {
  final DioClient _dioClient;

  SessionRemoteDataSourceImpl(this._dioClient);

  @override
  Future<Map<String, dynamic>> createSession({
    required int patientId,
    required String? notes,
    required List<Map<String, dynamic>> segments,
    DateTime? scheduledDate,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.createSession,
      data: {
        'patient_id': patientId,
        'started_at': (scheduledDate ?? DateTime.now()).toIso8601String().replaceFirst('T', ' ').split('.').first,
        if (notes != null) 'notes': notes,
        'segments': segments,
      },
    );
    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      return responseData['data'] ?? responseData['session'] ?? responseData;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> getSessionDetails(int sessionId) async {
    final response = await _dioClient.get(
      ApiConstants.sessionDetails.replaceAll('{id}', sessionId.toString()),
    );
    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      // Try common wrapper keys
      final result = responseData['data'] as Map<String, dynamic>? ?? responseData['session'] as Map<String, dynamic>? ?? responseData;
      debugPrint('🔍 [SessionAPI] Raw session $sessionId keys: ${result.keys.toList()}');
      debugPrint('🔍 [SessionAPI] average_focus: ${result['average_focus']}');
      if (result['analytic'] != null) {
        debugPrint('🔍 [SessionAPI] top-level analytic keys: ${(result['analytic'] as Map).keys.toList()}');
      }
      final segs = result['segments'];
      if (segs is List && segs.isNotEmpty) {
        debugPrint('🔍 [SessionAPI] ${segs.length} segments found');
        final firstSeg = segs.first;
        if (firstSeg is Map) {
          debugPrint('🔍 [SessionAPI] segment[0] keys: ${firstSeg.keys.toList()}');
          final segAn = firstSeg['analytic'] ?? firstSeg['analytics'];
          if (segAn is Map) {
            debugPrint('🔍 [SessionAPI] segment[0].analytic keys: ${segAn.keys.toList()}');
            debugPrint('🔍 [SessionAPI] segment[0].emotions: ${segAn['emotions']}');
            debugPrint('🔍 [SessionAPI] segment[0].gaze: ${segAn['gaze']}');
            debugPrint('🔍 [SessionAPI] segment[0].focus_score: ${segAn['focus_score']}');
            debugPrint('🔍 [SessionAPI] segment[0].speech_text: "${segAn['speech_text']}"');
            debugPrint('🔍 [SessionAPI] segment[0].story_trait: "${segAn['story_trait']}"');
            debugPrint('🔍 [SessionAPI] segment[0].is_correct: ${segAn['is_correct']}');
          } else {
            debugPrint('🔍 [SessionAPI] segment[0] has NO analytic field');
          }
        }
      }
      return result;
    }
    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> getPatientSessions(int patientId) async {
    final response = await _dioClient.get(
      ApiConstants.patientSessions.replaceAll('{id}', patientId.toString()),
    );
    return _extractSessionsList(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getMySessions() async {
    final response = await _dioClient.get(ApiConstants.mySessions);
    return _extractSessionsList(response.data);
  }

  @override
  Future<void> startSession({
    required int sessionId,
  }) async {
    await _dioClient.post(
      ApiConstants.startSession.replaceAll('{id}', sessionId.toString()),
    );
  }

  @override
  Future<void> endSession(int sessionId) async {
    await _dioClient.post(
      ApiConstants.endSession.replaceAll('{id}', sessionId.toString()),
    );
  }

  @override
  Future<void> updateSession({
    required int sessionId,
    String? notes,
    List<Map<String, dynamic>>? segments,
  }) async {
    await _dioClient.post(
      '${ApiConstants.updateSession.replaceAll('{id}', sessionId.toString())}?_method=PUT',
      data: {
        if (notes != null) 'notes': notes,
        if (segments != null) 'segments': segments,
      },
    );
  }

  @override
  Future<void> deleteSession(int sessionId) async {
    await _dioClient.post(
      '${ApiConstants.deleteSession.replaceAll('{id}', sessionId.toString())}?_method=DELETE',
    );
  }

  @override
  Future<void> startSegment(int segmentId) async {
    await _dioClient.post(
      ApiConstants.startSegment.replaceAll('{id}', segmentId.toString()),
    );
  }

  @override
  Future<void> completeSegment(int segmentId, {Map<String, dynamic>? data}) async {
    await _dioClient.post(
      ApiConstants.completeSegment.replaceAll('{id}', segmentId.toString()),
      data: data,
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _extractSessionsList(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final list = responseData['data'] ??
          responseData['sessions'] ??
          responseData;
      if (list is List) {
        if (list.isNotEmpty && list.first is Map) {
          debugPrint('🔍 [SessionListAPI] First session keys: ${(list.first as Map).keys.toList()}');
          if ((list.first as Map).containsKey('analytic')) {
            debugPrint('🔍 [SessionListAPI] First session analytic keys: ${(list.first['analytic'] as Map).keys.toList()}');
          }
          debugPrint('🔍 [SessionListAPI] raw: ${list.first}');
        }
        return list.cast<Map<String, dynamic>>();
      }
    }
    if (responseData is List) {
      return responseData.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
