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
        return 'ألعاب (Games)';
      case 'stories':
        return 'قصص (Story)';
      case 'education':
        return 'تعلم (Learn)';
      case 'drawing':
        return 'رسم (Drawing)';
      default:
        // Safe fallback for unknown types
        return type.isEmpty ? 'غير محدد' : type;
    }
  }
}
