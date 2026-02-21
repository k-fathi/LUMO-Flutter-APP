class ApiConstants {
  // Base URLs
  static const String baseUrl =
      'https://api.yourdomain.com/v1'; // TODO: Update to actual API URL when provided

  // Authentication Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';

  // Profile Endpoints
  static const String getProfile = '/users/profile';
  static const String updateProfile = '/users/profile';

  // Community Endpoints
  static const String getPosts = '/community/posts';
  static const String createPost = '/community/posts';
  static const String getPostComments = '/community/posts/{id}/comments';

  // Chat & AI Endpoints
  static const String getChatHistory = '/chat/history';
  static const String aiConsult = '/ai/consult';

  // Patients (For Doctors)
  static const String getPatients = '/doctor/patients';
  static const String getPatientInsights = '/doctor/patients/{id}/insights';
}
