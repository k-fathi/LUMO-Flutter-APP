import '../../core/services/lumo_api_service.dart';

/// Repository that wraps [StoryAudioResponse] with convenience parsing.
///
/// This is a simple value-object — heavy audio playback is handled in
/// the ViewModel layer.
class StoryAudioModel {
  final List<int> audioBytes;
  final String story;
  final String question;
  final String answer;
  final String emotion;

  const StoryAudioModel({
    required this.audioBytes,
    required this.story,
    required this.question,
    required this.answer,
    required this.emotion,
  });

  factory StoryAudioModel.fromApiResponse(StoryAudioResponse response) {
    return StoryAudioModel(
      audioBytes: response.audioBytes,
      story: response.story,
      question: response.question,
      answer: response.answer,
      emotion: response.emotion,
    );
  }

  bool get hasStory => story.isNotEmpty;
  bool get hasAudio => audioBytes.isNotEmpty;

  @override
  String toString() =>
      'StoryAudioModel(emotion: $emotion, storyLength: ${story.length})';
}
