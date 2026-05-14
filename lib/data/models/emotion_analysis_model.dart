/// Response model for Carol's Emotion & Gaze Analysis API (:8001/analyze_image).
///
/// The backend returns a flat JSON object — any unknown keys are preserved
/// in the [raw] map so future fields don't break the app.
class EmotionAnalysisModel {
  /// Detected primary emotion label (e.g. "happy", "sad", "neutral").
  final String? emotion;

  /// Confidence score for the detected emotion (0.0 – 1.0).
  final double? emotionConfidence;

  /// Gaze direction label (e.g. "center", "left", "right", "up", "down").
  final String? gazeDirection;

  /// Gaze confidence score (0.0 – 1.0).
  final double? gazeConfidence;

  /// Whether eye contact was detected.
  final bool? eyeContact;

  /// Additional raw fields returned by the model (for forward-compatibility).
  final Map<String, dynamic> raw;

  const EmotionAnalysisModel({
    this.emotion,
    this.emotionConfidence,
    this.gazeDirection,
    this.gazeConfidence,
    this.eyeContact,
    required this.raw,
  });

  // ─── Factory ──────────────────────────────────────────────────────────────

  factory EmotionAnalysisModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) return value.toLowerCase() == 'true';
      return null;
    }

    return EmotionAnalysisModel(
      emotion: json['emotion'] as String? ??
          json['predicted_emotion'] as String? ??
          json['label'] as String?,
      emotionConfidence: parseDouble(
        json['emotion_confidence'] ?? json['confidence'] ?? json['score'],
      ),
      gazeDirection: json['gaze_direction'] as String? ??
          json['gaze'] as String? ??
          json['gaze_label'] as String?,
      gazeConfidence: parseDouble(
        json['gaze_confidence'] ?? json['gaze_score'],
      ),
      eyeContact: parseBool(
        json['eye_contact'] ?? json['is_looking'] ?? json['contact'],
      ),
      raw: json,
    );
  }

  // ─── Presentation helpers ─────────────────────────────────────────────────

  /// Human-friendly Arabic emotion label.
  String get emotionAr {
    switch ((emotion ?? '').toLowerCase()) {
      case 'happy':
        return 'سعيد 😊';
      case 'sad':
        return 'حزين 😢';
      case 'angry':
        return 'غاضب 😠';
      case 'surprised':
        return 'مندهش 😮';
      case 'fearful':
      case 'fear':
        return 'خائف 😨';
      case 'disgusted':
      case 'disgust':
        return 'مشمئز 🤢';
      case 'neutral':
        return 'محايد 😐';
      default:
        return emotion ?? 'غير محدد';
    }
  }

  /// Human-friendly Arabic gaze direction label.
  String get gazeAr {
    switch ((gazeDirection ?? '').toLowerCase()) {
      case 'center':
        return 'تواصل بصري ✅';
      case 'left':
        return 'يميل لليسار ←';
      case 'right':
        return 'يميل لليمين →';
      case 'up':
        return 'يميل للأعلى ↑';
      case 'down':
        return 'يميل للأسفل ↓';
      default:
        return gazeDirection ?? 'غير محدد';
    }
  }

  bool get hasEyeContact => eyeContact ?? false;

  /// Returns the emotion confidence as a percentage string.
  String get confidencePercent => emotionConfidence != null
      ? '${(emotionConfidence! * 100).toStringAsFixed(1)}%'
      : '—';

  @override
  String toString() =>
      'EmotionAnalysisModel(emotion: $emotion, gaze: $gazeDirection)';
}
