class AIMessageModel {
  final String id;
  final String userId;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;
  final String? error;

  const AIMessageModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
    this.error,
  });

  // Factory constructor from JSON
  factory AIMessageModel.fromJson(Map<String, dynamic> json) {
    return AIMessageModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      isUser: json['is_user'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isLoading: json['is_loading'] as bool? ?? false,
      error: json['error'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'is_user': isUser,
      'timestamp': timestamp.toIso8601String(),
      'is_loading': isLoading,
      'error': error,
    };
  }

  // CopyWith method
  AIMessageModel copyWith({
    String? id,
    String? userId,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    bool? isLoading,
    String? error,
  }) {
    return AIMessageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Helper methods
  bool get isAI => !isUser;
  bool get hasError => error != null && error!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIMessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AIMessageModel(id: $id, isUser: $isUser, content: ${content.length} chars)';
  }
}