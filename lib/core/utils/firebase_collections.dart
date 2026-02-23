/// Firebase Firestore collection names
class FirebaseCollections {
  const FirebaseCollections._();

  // Main collections
  static const String users = 'users';
  static const String posts = 'posts';
  static const String chats = 'chats';
  static const String messages = 'messages';
  static const String analyses = 'analyses';
  static const String notifications = 'notifications';
  static const String doctorCodes = 'doctor_codes';
  static const String connectionRequests = 'connection_requests';
  static const String aiChats = 'ai_chats';

  // Subcollections
  static const String comments = 'comments';
  static const String likes = 'likes';
  static const String followers = 'followers';
  static const String following = 'following';
  static const String patients = 'patients';
  static const String doctors = 'doctors';

  // User data subcollections
  static const String userPosts = 'user_posts';
  static const String userChats = 'user_chats';
  static const String userNotifications = 'user_notifications';

  // Helper methods
  static String userCollection(String userId) => '$users/$userId';
  static String postCollection(String postId) => '$posts/$postId';
  static String chatCollection(String chatId) => '$chats/$chatId';

  static String postComments(String postId) => '$posts/$postId/$comments';
  static String postLikes(String postId) => '$posts/$postId/$likes';

  static String userFollowers(String userId) => '$users/$userId/$followers';
  static String userFollowing(String userId) => '$users/$userId/$following';

  static String doctorPatients(String doctorId) => '$users/$doctorId/$patients';
  static String parentDoctors(String parentId) => '$users/$parentId/$doctors';

  static String chatMessages(String chatId) => '$chats/$chatId/$messages';
}

/// Firebase Storage paths
class FirebaseStoragePaths {
  const FirebaseStoragePaths._();

  static const String users = 'users';
  static const String posts = 'posts';
  static const String chats = 'chats';
  static const String avatars = 'avatars';
  static const String images = 'images';
  static const String documents = 'documents';
  static const String analyses = 'analyses';

  // User paths
  static String userAvatar(String userId) => '$users/$userId/$avatars';
  static String userDocuments(String userId) => '$users/$userId/$documents';

  // Post paths
  static String postImages(String userId, String postId) => '$posts/$userId/$postId';

  // Chat paths
  static String chatImages(String chatId) => '$chats/$chatId/$images';
  static String chatDocuments(String chatId) => '$chats/$chatId/$documents';

  // Analysis paths
  static String analysisDocuments(String doctorId, String patientId) {
    return '$analyses/$doctorId/$patientId';
  }
}