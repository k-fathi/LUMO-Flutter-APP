import 'dart:io';

import '../../core/services/lumo_api_service.dart';
import '../models/emotion_analysis_model.dart';
import '../models/story_audio_model.dart';

/// Repository that consolidates all three LUMO microservice calls behind a
/// single clean interface consumed by ViewModels.
class LumoApiRepository {
  final LumoApiService _apiService;

  LumoApiRepository(this._apiService);

  // ── Chatbot ───────────────────────────────────────────────────────────────

  /// Asks Asmaa's medical chatbot [question] and returns the Arabic answer.
  Future<String> askChatbot(String question) async {
    return _apiService.askChatbot(question);
  }

  // ── Image Analysis ────────────────────────────────────────────────────────

  /// Uploads [imageFile] to Carol's model and returns parsed analysis results.
  Future<EmotionAnalysisModel> analyzeImage(File imageFile) async {
    final rawJson = await _apiService.analyzeImage(imageFile);
    return EmotionAnalysisModel.fromJson(rawJson);
  }

  // ── Story & Audio ─────────────────────────────────────────────────────────

  /// Fetches generated story MP3 and URL-decoded metadata from the audio API.
  Future<StoryAudioModel> getStoryAudio() async {
    final response = await _apiService.getStoryAudio();
    return StoryAudioModel.fromApiResponse(response);
  }
}
