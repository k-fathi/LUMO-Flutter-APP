import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../datasources/local_data_source.dart';
import '../models/ai_message_model.dart';

/// Handles the AI chat flow.
///
/// Sends questions to the Autism Chatbot API (v4.1.0) running at
/// http://172.189.165.242:8080 and persists the conversation locally
/// for offline history access.
class AIRepository {
  final LocalDataSource _localDataSource;

  /// Dedicated Dio instance pointing at the chatbot micro-service.
  late final Dio _chatbotDio;

  /// Base URL for the chatbot API.
  static const String _chatbotBaseUrl = 'http://172.189.165.242:8080';

  /// Tracks per-user/per-patient started sessions instead of a single global flag.
  final Set<String> _startedSessions = {};
  bool get isSessionStarted {
    final currentUserId = _localDataSource.getCurrentUserId();
    if (currentUserId == null || currentUserId.isEmpty) {
      return _startedSessions.isNotEmpty;
    }
    return _startedSessions.any((key) => key == currentUserId || key.startsWith('${currentUserId}_'));
  }

  AIRepository(this._localDataSource) {
    _chatbotDio = Dio(BaseOptions(
      baseUrl: _chatbotBaseUrl,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
      followRedirects: true,
      validateStatus: (status) => true,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  // ==================== RESPONSE VALIDATION ====================

  /// Inspects every chatbot response **before** JSON parsing.
  ///
  /// Catches two real-world edge-cases on Egyptian ISPs:
  /// 1. The ISP (WE / tedata) intercepts unencrypted HTTP and returns a
  ///    `307 → text/html` redirect page when the user's data quota is
  ///    exhausted.  Dio happily follows the redirect and hands us HTML
  ///    instead of JSON, causing a parse crash.
  /// 2. The FastAPI backend returns 500 when the HuggingFace LLM times
  ///    out or the API token is revoked.
  void _validateResponse(Response response) {
    // ── ISP HTML interception ──────────────────────────────────────────
    final contentType = response.headers.value('content-type') ?? '';
    if (contentType.contains('text/html')) {
      throw Exception(
        'يرجى التحقق من باقة الإنترنت. الشبكة تقوم بتحويل مسار الاتصال.',
      );
    }
    final body = response.data;
    if (body is String && body.trimLeft().startsWith('<')) {
      throw Exception(
        'يرجى التحقق من باقة الإنترنت. الشبكة تقوم بتحويل مسار الاتصال.',
      );
    }

    // ── Backend 500 (LLM timeout / token failure) ──────────────────────
    if (response.statusCode == 500) {
      throw Exception(
        'عذراً، حدث خطأ في الخادم (500). يرجى المحاولة بعد قليل.',
      );
    }

    // ── Any other HTTP error ──────────────────────────────────────────
    if (response.statusCode != null && response.statusCode! >= 400) {
      throw Exception(
        'حدث خطأ (${response.statusCode}). يرجى المحاولة مرة أخرى.',
      );
    }
  }

  // ==================== SESSION START ====================

  String _sessionKey({
    required String userId,
    required String userRole,
    String? patientId,
    String? childName,
  }) {
    if (userRole == 'doctor' && patientId != null && patientId.trim().isNotEmpty) {
      return '${userId}_${patientId.trim()}';
    }
    final suffix = (childName ?? '').trim();
    return suffix.isNotEmpty ? '${userId}_$suffix' : userId.toString();
  }

  Map<String, dynamic> _resolveSessionContext({
    required String userId,
    String? childName,
    String? userRole,
    String? patientId,
  }) {
    final currentUser = _localDataSource.getCurrentUser();
    final resolvedRole = (userRole ?? currentUser?['role']?.toString() ?? 'parent').toString();
    final resolvedChildName = (childName ?? currentUser?['child_name']?.toString() ?? '').toString();
    final resolvedPatientId = (patientId ?? currentUser?['patient_id']?.toString()).toString();

    return {
      'user_id': userId.toString(),
      'user_role': resolvedRole.isNotEmpty ? resolvedRole : 'parent',
      'child_name': resolvedChildName,
      'patient_id': resolvedPatientId == 'null' || resolvedPatientId.trim().isEmpty ? null : resolvedPatientId,
    };
  }

  /// Initialises the chatbot session with the child's name.
  /// Must be called once before the first /chat request.
  Future<void> startSession(
    String childName, {
    int? userId,
    String userRole = 'parent',
    String? patientId,
  }) async {
    final currentUser = _localDataSource.getCurrentUser();
    final resolvedUserId = (userId ?? int.tryParse(_localDataSource.getCurrentUserId() ?? '') ?? currentUser?['id'] ?? 0).toString();
    final key = _sessionKey(
      userId: resolvedUserId,
      userRole: userRole,
      patientId: patientId,
      childName: childName,
    );
    if (_startedSessions.contains(key)) return;

    final payload = _resolveSessionContext(
      userId: resolvedUserId,
      childName: childName,
      userRole: userRole,
      patientId: patientId,
    );

    try {
      await _chatbotDio.post('/session/start', data: payload);
      _startedSessions.add(key);
      debugPrint('✅ Chatbot session started for child: $childName');
    } catch (e) {
      debugPrint('⚠️ Chatbot /session/start failed: $e');
      // Don't block the user — they can still chat; the API will handle
      // a missing session gracefully (or we retry on next send).
    }
  }

  // ==================== AI CHAT ====================

  /// Sends [content] to the chatbot API and persists both sides of the
  /// conversation to local storage. Returns the AI [AIMessageModel].
  Future<AIMessageModel> sendMessage(
    int userId,
    String content, {
    String? childName,
    String? userRole,
    String? patientId,
  }) async {
    final userMessage = AIMessageModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final currentUser = _localDataSource.getCurrentUser();
    final resolvedRole = (userRole ?? currentUser?['role']?.toString() ?? 'parent').toString();
    final resolvedChildName = childName?.trim().isNotEmpty == true
        ? childName!.trim()
        : (currentUser?['child_name']?.toString() ?? currentUser?['data']?['child_name']?.toString() ?? '').toString();
    final resolvedPatientId = patientId ?? currentUser?['patient_id']?.toString();

    // ── Try /session/start if not yet done ──
    if (resolvedRole != 'doctor' || (resolvedPatientId != null && resolvedPatientId.trim().isNotEmpty)) {
      await startSession(
        resolvedChildName.isNotEmpty ? resolvedChildName : 'الطفل',
        userId: userId,
        userRole: resolvedRole,
        patientId: resolvedPatientId,
      );
    }

    // ── Real API call ────────────────────────────────────────────────────
    String aiResponse = "عذراً، حدث خطأ في معالجة طلبك.";
    String? categoryLabel;
    String? urgency;
    bool needsClarification = false;
    String? clarificationQuestion;

    try {
      String savedChildName = resolvedChildName;
      if (savedChildName.isEmpty) {
        savedChildName = currentUser?['child_name']?.toString() ?? '';
        if (savedChildName.isEmpty) {
          savedChildName = currentUser?['data']?['child_name']?.toString() ?? '';
        }
      }

      Future<Response<dynamic>> postChat() {
        return _chatbotDio.post('/chat', data: {
          "question": content,
          "user_id": userId.toString(),
          "user_role": resolvedRole,
          if (savedChildName.trim().isNotEmpty) "child_name": savedChildName.trim(),
          if (resolvedRole == 'doctor' && (resolvedPatientId != null && resolvedPatientId.trim().isNotEmpty))
            "patient_id": resolvedPatientId.trim(),
        });
      }

      Response<dynamic> response = await postChat();
      if (response.statusCode == 404) {
        final detail = response.data is Map ? response.data['detail']?.toString().toLowerCase() ?? '' : response.data?.toString().toLowerCase() ?? '';
        final looksLikeMissingSession = detail.contains('session') || detail.contains('لم تبدأ') || detail.contains('no session');
        if (looksLikeMissingSession) {
          await startSession(
            savedChildName.isNotEmpty ? savedChildName : 'الطفل',
            userId: userId,
            userRole: resolvedRole,
            patientId: resolvedRole == 'doctor' ? resolvedPatientId : null,
          );
          response = await postChat();
        }
      }

      _validateResponse(response);

      final data = response.data;
      debugPrint('🤖 RAW BACKEND RESPONSE: $data');

      // ✅ Guard: empty or null response
      if (data == null || (data is String && data.trim().isEmpty)) {
        throw Exception(
          'الخادم لم يُرجع استجابة. تأكد أن النموذج تم تحميله وأن الجلسة بدأت.',
        );
      }

      if (data is Map<String, dynamic>) {
        // Guard the 'answer' field specifically
        final answer = data['answer']?.toString() ?? '';
        if (answer.trim().isEmpty) {
          throw Exception('الاستجابة فارغة من الخادم. حاول مرة أخرى.');
        }
        aiResponse = answer;
        categoryLabel = data['category_label']?.toString();
        urgency = data['urgency']?.toString();
        needsClarification = data['needs_clarification'] == true;
        clarificationQuestion = data['clarification_question']?.toString();
        debugPrint('🤖 EXTRACTED aiResponse: $aiResponse');
      } else {
        // If backend returned non-map (string) but non-empty, use it
        final text = data?.toString() ?? '';
        if (text.trim().isEmpty) {
          throw Exception('الاستجابة فارغة من الخادم. حاول مرة أخرى.');
        }
        aiResponse = text;
        debugPrint('🤖 EXTRACTED (from string) aiResponse: $aiResponse');
      }
    } on DioException catch (e) {
      debugPrint('❌ Chatbot /chat DioException: $e');
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          aiResponse =
              'عذراً، السيرفر يستغرق وقتاً طويلاً. يرجى المحاولة مرة أخرى.';
          break;
        case DioExceptionType.connectionError:
          aiResponse = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.';
          break;
        default:
          aiResponse = 'عذراً، لم نتمكن من الوصول إلى المساعد الذكي حالياً.';
      }
    } catch (e) {
      debugPrint('❌ Chatbot /chat error: $e');
      aiResponse = e.toString().replaceFirst('Exception: ', '');
    }
    // ─────────────────────────────────────────────────────────────────────

    final aiMessage = AIMessageModel(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      content: aiResponse,
      isUser: false,
      timestamp: DateTime.now(),
      categoryLabel: categoryLabel,
      urgency: urgency,
      needsClarification: needsClarification,
      clarificationQuestion: clarificationQuestion,
    );

    // Persist both messages to local cache.
    final history = await getChatHistory(userId);
    history.add(userMessage);
    history.add(aiMessage);
    await _localDataSource.saveAiHistory(
      userId.toString(),
      history.map((e) => e.toJson()).toList(),
    );

    return aiMessage;
  }

  // ==================== PROFILE (SESSION SUMMARY) ====================

  /// Fetches the session summary / child profile from the chatbot API.
  Future<Map<String, dynamic>?> getProfile({
    required int userId,
    String userRole = 'parent',
    String? patientId,
  }) async {
    try {
      final response = await _chatbotDio.get('/profile', queryParameters: {
        'user_id': userId.toString(),
        'user_role': userRole,
        if (patientId != null && patientId.trim().isNotEmpty) 'patient_id': patientId.trim(),
      });
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('⚠️ Chatbot /profile failed: $e');
    }
    return null;
  }

  // ==================== LOCAL HISTORY ====================

  /// Returns persisted chat history for [userId] from local cache.
  Future<List<AIMessageModel>> getChatHistory(int userId) async {
    final cachedData = _localDataSource.getAiHistory(userId.toString());
    if (cachedData != null) {
      return cachedData.map((data) => AIMessageModel.fromJson(data)).toList();
    }
    return [];
  }

  /// Clears all chat history for [userId] from local cache.
  Future<void> clearChatHistory(int userId) async {
    await _localDataSource.remove('ai_history_$userId');
    _startedSessions.removeWhere((key) => key.startsWith('${userId}_') || key == userId.toString());
  }

  Future<List<Map<String, dynamic>>> fetchPatients(int doctorId) async {
    final response = await _chatbotDio.get('/patients', queryParameters: {
      'user_id': doctorId.toString(),
    });
    _validateResponse(response);
    final data = response.data;
    if (data is Map && data['patients'] is List) {
      return List<Map<String, dynamic>>.from(data['patients']);
    }
    return [];
  }
}
