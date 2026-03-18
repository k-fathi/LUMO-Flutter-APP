import '../../core/enums/post_status.dart';
import '../../core/utils/date_formatter.dart';

class PostModel {
  final int id;
  final int userId;
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
  final List<int> likedByUserIds;
  final List<String> tags;
  final bool isPinned;
  final bool isLiked;

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
    this.isLiked = false,
  });

  // Factory constructor from JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Robust parsing for user data (handles nested objects like 'user' or 'author')
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user']
        : (json['author'] is Map<String, dynamic>
            ? json['author']
            : (json['creator'] is Map<String, dynamic> ? json['creator'] : null));

    return PostModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ??
              json['author_id']?.toString() ??
              json['owner_id']?.toString() ??
              userMap?['id']?.toString() ??
              '0') ?? 0,
      userName: json['user_name']?.toString() ?? 
                userMap?['name']?.toString() ?? 
                'مستخدم',
      userAvatarUrl: json['user_avatar_url']?.toString() ?? 
                     userMap?['avatar_url']?.toString() ?? 
                     userMap?['profile_image']?.toString(),
      content: (json['content'] ?? json['body'] ?? json['text'])?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? json['image']?.toString(),
      status: PostStatus.fromString(json['status']?.toString() ?? 'published'),
      createdAt: DateFormatter.parseServerDateTime(json['created_at']?.toString()),
      updatedAt: DateFormatter.parseServerDateTime(json['updated_at']?.toString()),
      likesCount: json['likes_count'] is int
          ? json['likes_count']
          : int.tryParse(json['likes_count']?.toString() ?? '0') ?? 0,
      commentsCount: json['comments_count'] is int
          ? json['comments_count']
          : int.tryParse(json['comments_count']?.toString() ?? '0') ?? 0,
      sharesCount: json['shares_count'] is int
          ? json['shares_count']
          : int.tryParse(json['shares_count']?.toString() ?? '0') ?? 0,
      likedByUserIds: json['liked_by_user_ids'] is List
          ? (json['liked_by_user_ids'] as List)
              .map((e) => int.tryParse(e.toString()) ?? 0)
              .toList()
          : [],
      tags: json['tags'] is List
          ? (json['tags'] as List).map((e) => e.toString()).toList()
          : [],
      isPinned: json['is_pinned'] == true ||
          json['is_pinned'] == 1 ||
          json['is_pinned']?.toString() == 'true',
      isLiked: json['is_liked'] == true ||
          json['liked'] == true ||
          json['has_liked'] == true ||
          json['is_liked'] == 1 ||
          json['is_liked']?.toString() == 'true',
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
      'is_liked': isLiked,
    };
  }

  // CopyWith method
  PostModel copyWith({
    int? id,
    int? userId,
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
    List<int>? likedByUserIds,
    List<String>? tags,
    bool? isPinned,
    bool? isLiked,
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
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // Helper methods
  bool isLikedBy(int userId) => isLiked || likedByUserIds.contains(userId);
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
