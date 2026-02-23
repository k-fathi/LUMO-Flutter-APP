import '../../core/enums/post_status.dart';

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;
  final String? imageUrl;
  final PostStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final List<String> likedByUserIds;
  final List<String> tags;
  final bool isPinned;

  const PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    this.imageUrl,
    this.status = PostStatus.published,
    required this.createdAt,
    required this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.likedByUserIds = const [],
    this.tags = const [],
    this.isPinned = false,
  });

  // Factory constructor from JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatarUrl: json['user_avatar_url'] as String?,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      status: PostStatus.fromString(json['status'] as String? ?? 'published'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      likedByUserIds: (json['liked_by_user_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isPinned: json['is_pinned'] as bool? ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar_url': userAvatarUrl,
      'content': content,
      'image_url': imageUrl,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'liked_by_user_ids': likedByUserIds,
      'tags': tags,
      'is_pinned': isPinned,
    };
  }

  // CopyWith method
  PostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? content,
    String? imageUrl,
    PostStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    List<String>? likedByUserIds,
    List<String>? tags,
    bool? isPinned,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  // Helper methods
  bool isLikedBy(String userId) => likedByUserIds.contains(userId);
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasTags => tags.isNotEmpty;
  bool get isPublished => status.isPublished;
  bool get isDraft => status.isDraft;

  // Engagement rate (for analytics)
  double get engagementRate {
    if (likesCount + commentsCount + sharesCount == 0) return 0.0;
    return (likesCount + commentsCount * 2 + sharesCount * 3) / 100.0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PostModel(id: $id, userId: $userId, content: ${content.length} chars, likes: $likesCount)';
  }
}