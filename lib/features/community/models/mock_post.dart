class MockPost {
  final String id;
  final String authorName;
  final String authorRole; // 'doctor' or 'parent'
  final String timeAgo; // Deprecated, use timestamp
  final DateTime timestamp;
  final String content;
  final int likesCount;
  final int commentsCount;
  final String? authorAvatar;
  final String? imageUrl;
  final bool isLiked;

  const MockPost({
    required this.id,
    required this.authorName,
    required this.authorRole,
    this.authorAvatar,
    required this.timeAgo,
    required this.timestamp,
    required this.content,
    this.imageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  MockPost copyWith({
    String? id,
    String? authorName,
    String? authorRole,
    String? timeAgo,
    DateTime? timestamp,
    String? content,
    String? imageUrl,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return MockPost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      timeAgo: timeAgo ?? this.timeAgo,
      timestamp: timestamp ?? this.timestamp,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
