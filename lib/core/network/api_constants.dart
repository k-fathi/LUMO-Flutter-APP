class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://clickexpress.delivery/api';

  // Authentication Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String verifyResetOtp = '/auth/verify-reset-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';

  // Profile Endpoints
  static const String getProfile = '/profile';
  static const String updateProfile = '/profile'; // Note: uses POST with _method=PUT

  // Community & Posts
  static const String homeFeed = '/home';
  static const String myPosts = '/posts';
  static const String createPost = '/posts/create';
  static const String showPost = '/posts/{id}/show';
  static const String updatePost = '/posts/{id}/update'; // Note: uses POST with _method=PUT
  static const String deletePost = '/posts/{id}/delete'; // Note: uses POST with _method=DELETE

  // Post Interactions
  static const String toggleLike = '/posts/{id}/like';
  static const String postLikes = '/posts/{id}/likes';
  static const String postComments = '/posts/{id}/comments';
  static const String deleteComment = '/posts/comments/{id}'; // Note: uses POST with _method=DELETE

  // Social & Search
  static const String toggleFollow = '/user/{id}/follow';
  static const String getFollowers = '/user/followers';
  static const String getFollowing = '/user/followings';
  static const String searchUsers = '/search/users';

  // Notifications
  static const String getNotifications = '/notifications';
  static const String readNotifications = '/notifications/read';
  static const String deleteNotifications = '/notifications/destroy';

  // Chat & AI
  static const String firebaseToken = '/firebase/token';
  static const String myChats = '/chat/my-chats';
  static const String startChat = '/chat/start';
  static const String updateLastMessage = '/chat/update-last-message';
  static const String getChatHistory = '/chat/history';
  static const String aiConsult = '/ai/consult';

  // Sessions
  static const String startSession = '/session/start';
  static const String endSession = '/session/end';

  // Doctor-Patient Request System
  static const String getPatients = '/doctor/patients';
  static const String getPatientInsights = '/doctor/patients/{id}/insights';
  static const String patientRequest = '/doctor/patient-request';
  static const String getPendingRequests = '/doctor/patient/requests';
  static const String acceptRequest = '/doctor/patient/request/{id}/accept';
  static const String rejectRequest = '/doctor/patient/request/{id}/reject';
  static const String disconnectPatient = '/doctor/patients/{id}/disconnect';
}
