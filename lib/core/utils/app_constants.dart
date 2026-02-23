class AppConstants {
  const AppConstants._();

  // App Info
  static const String appName = 'Lumo AI';
  static const String appVersion = '1.0.0';
  static const String appPackage = 'com.lumoai.medical';

  // Pagination
  static const int postsPerPage = 10;
  static const int commentsPerPage = 20;
  static const int messagesPerPage = 50;
  static const int notificationsPerPage = 20;
  static const int searchResultsPerPage = 15;

  // Timeouts (in seconds)
  static const int apiTimeout = 30;
  static const int uploadTimeout = 120;
  static const int connectionTimeout = 15;

  // Cache durations
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration mediumCacheDuration = Duration(minutes: 30);
  static const Duration longCacheDuration = Duration(hours: 24);

  // File size limits (in bytes)
  static const int maxImageSize = 5 * 1024 * 1024; // 5 MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50 MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10 MB
  static const int maxAvatarSize = 2 * 1024 * 1024; // 2 MB

  // Text limits
  static const int maxPostLength = 1000;
  static const int maxCommentLength = 500;
  static const int maxMessageLength = 1000;
  static const int maxBioLength = 200;
  static const int maxNameLength = 50;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  // Doctor code
  static const int doctorCodeLength = 8;
  static const String doctorCodePrefix = 'DOC';
  static const Duration doctorCodeExpiry = Duration(days: 365);

  // Onboarding
  static const int onboardingPageCount = 3;
  static const Duration onboardingTransitionDuration = Duration(milliseconds: 300);

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Debounce durations
  static const Duration searchDebounceDuration = Duration(milliseconds: 500);
  static const Duration typingDebounceDuration = Duration(milliseconds: 300);

  // Refresh intervals
  static const Duration postRefreshInterval = Duration(minutes: 5);
  static const Duration messageRefreshInterval = Duration(seconds: 30);
  static const Duration notificationRefreshInterval = Duration(minutes: 1);

  // Notification IDs
  static const int newMessageNotificationId = 1;
  static const int newPostLikeNotificationId = 2;
  static const int newCommentNotificationId = 3;
  static const int newFollowerNotificationId = 4;
  static const int connectionRequestNotificationId = 5;
  static const int newAnalysisNotificationId = 6;

  // Supported languages
  static const List<String> supportedLanguages = ['ar', 'en'];
  static const String defaultLanguage = 'ar';

  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayTimeFormat = 'hh:mm a';
  static const String displayDateTimeFormat = 'dd/MM/yyyy hh:mm a';

  // Regex patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\+?[\d\s-]{10,}$';
  static const String urlPattern = r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)';

  // Image quality
  static const int imageQuality = 85;
  static const int thumbnailQuality = 70;
  static const int avatarQuality = 90;

  // Analysis states count
  static const int analysisStatesCount = 5;

  // Chat
  static const Duration typingIndicatorDuration = Duration(seconds: 5);
  static const Duration messageReadDelay = Duration(milliseconds: 500);

  // AI Chat
  static const String aiChatName = 'Lumo AI';
  static const String aiChatGreeting = 'مرحباً! أنا مساعد Lumo AI الذكي. كيف يمكنني مساعدتك اليوم؟';
  static const int maxAIMessageLength = 2000;

  // Loading screen
  static const Duration loadingScreenMinDuration = Duration(seconds: 2);
  static const Duration loadingScreenMaxDuration = Duration(seconds: 5);

  // Error messages
  static const String genericErrorMessage = 'حدث خطأ، يرجى المحاولة مرة أخرى';
  static const String networkErrorMessage = 'تحقق من اتصالك بالإنترنت';
  static const String authErrorMessage = 'فشل تسجيل الدخول، تحقق من بياناتك';

  // Success messages
  static const String postCreatedMessage = 'تم نشر المنشور بنجاح';
  static const String commentAddedMessage = 'تم إضافة التعليق بنجاح';
  static const String messageSentMessage = 'تم إرسال الرسالة';
  static const String profileUpdatedMessage = 'تم تحديث الملف الشخصي بنجاح';

  // Placeholders
  static const String defaultAvatarUrl = 'https://ui-avatars.com/api/?name=User&background=2196F3&color=fff&size=200';
  static const String defaultPostImage = 'assets/images/placeholder_post.png';
  static const String defaultErrorImage = 'assets/images/error_image.png';

  // Social
  static const int maxFollowersDisplay = 999; // Display 999+ if more
  static const int maxLikesDisplay = 999; // Display 999+ if more

  // Ratings
  static const int maxRating = 5;
  static const int minRating = 1;

  // Feature flags (for gradual rollout)
  static const bool enableAIChat = true;
  static const bool enableVideoUpload = false;
  static const bool enableVoiceMessages = false;
  static const bool enableStories = false;
}