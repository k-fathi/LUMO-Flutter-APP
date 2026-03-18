class SessionPart {
  final String type; // 'games', 'stories', 'education'
  final int durationMinutes;

  SessionPart({required this.type, required this.durationMinutes});

  Map<String, dynamic> toJson() => {
        'type': type,
        'duration_minutes': durationMinutes,
      };

  String get typeLabel {
    switch (type) {
      case 'games':
        return 'ألعاب';
      case 'stories':
        return 'قصص';
      case 'education':
        return 'تعليم';
      default:
        return type;
    }
  }
}
