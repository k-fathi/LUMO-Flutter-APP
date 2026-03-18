import '../../core/services/local_storage_service.dart';

class LocalDataSource {
  final LocalStorageService _localStorage;

  LocalDataSource(this._localStorage);

  // ==================== USER OPERATIONS ====================

  Future<void> saveCurrentUser(Map<String, dynamic> userData) async {
    await _localStorage.saveUserData(userData);
    await _localStorage.saveUserId(userData['id'].toString());
  }

  Map<String, dynamic>? getCurrentUser() {
    return _localStorage.getUserData();
  }

  String? getCurrentUserId() {
    return _localStorage.getUserId();
  }

  Future<void> clearCurrentUser() async {
    await _localStorage.clearUserData();
  }

  bool isLoggedIn() {
    return _localStorage.isLoggedIn();
  }

  Future<void> setLoggedIn(bool value) async {
    await _localStorage.setLoggedIn(value);
  }

  // ==================== CACHE OPERATIONS ====================

  Future<void> cachePosts(List<Map<String, dynamic>> posts) async {
    await _localStorage.cacheData('posts', {'posts': posts});
  }

  List<Map<String, dynamic>>? getCachedPosts({Duration? maxAge}) {
    final cached = _localStorage.getCachedData('posts', maxAge: maxAge);
    if (cached != null) {
      return (cached['posts'] as List).cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> cacheUserPosts(
      String userId, List<Map<String, dynamic>> posts) async {
    await _localStorage.cacheData('user_posts_$userId', {'posts': posts});
  }

  List<Map<String, dynamic>>? getCachedUserPosts(String userId,
      {Duration? maxAge}) {
    final cached =
        _localStorage.getCachedData('user_posts_$userId', maxAge: maxAge);
    if (cached != null) {
      return (cached['posts'] as List).cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> cacheChats(List<Map<String, dynamic>> chats) async {
    await _localStorage.cacheData('chats', {'chats': chats});
  }

  List<Map<String, dynamic>>? getCachedChats({Duration? maxAge}) {
    final cached = _localStorage.getCachedData('chats', maxAge: maxAge);
    if (cached != null) {
      return (cached['chats'] as List).cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> cacheAnalyses(
      String parentId, List<Map<String, dynamic>> analyses) async {
    await _localStorage.cacheData('analyses_$parentId', {'analyses': analyses});
  }

  List<Map<String, dynamic>>? getCachedAnalyses(String parentId,
      {Duration? maxAge}) {
    final cached =
        _localStorage.getCachedData('analyses_$parentId', maxAge: maxAge);
    if (cached != null) {
      return (cached['analyses'] as List).cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> clearAllCache() async {
    await _localStorage.clearAllCache();
  }

  // ==================== PATIENTS & REQUESTS ====================

  Future<void> savePatients(List<Map<String, dynamic>> patients) async {
    await _localStorage.cacheData('patients', {'patients': patients});
  }

  List<Map<String, dynamic>>? getPatients() {
    final cached = _localStorage.getCachedData('patients');
    if (cached != null) {
      return (cached['patients'] as List).cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> saveJoinRequests(List<Map<String, dynamic>> requests) async {
    await _localStorage.cacheData('join_requests', {'requests': requests});
  }

  List<Map<String, dynamic>>? getJoinRequests() {
    final cached = _localStorage.getCachedData('join_requests');
    if (cached != null) {
      return (cached['requests'] as List).cast<Map<String, dynamic>>();
    }
    return null;
  }

  // ==================== ONBOARDING ====================

  Future<void> setOnboardingCompleted(bool value) async {
    await _localStorage.setOnboardingCompleted(value);
  }

  bool isOnboardingCompleted() {
    return _localStorage.isOnboardingCompleted();
  }

  // ==================== DRAFT OPERATIONS ====================

  Future<void> savePostDraft(String content) async {
    await _localStorage.saveDraft(content);
  }

  String? getPostDraft() {
    return _localStorage.getDraft();
  }

  Future<void> clearPostDraft() async {
    await _localStorage.clearDraft();
  }

  Future<void> saveChatDraft(String chatRoomId, String message) async {
    await _localStorage.saveChatDraft(chatRoomId, message);
  }

  String? getChatDraft(String chatRoomId) {
    return _localStorage.getChatDraft(chatRoomId);
  }

  Future<void> clearChatDraft(String chatRoomId) async {
    await _localStorage.clearChatDraft(chatRoomId);
  }

  // ==================== MESSAGE CACHE ====================

  Future<void> cacheMessages(
      String chatRoomId, List<Map<String, dynamic>> messages) async {
    await _localStorage.cacheMessages(chatRoomId, messages);
  }

  List<Map<String, dynamic>>? getCachedMessages(String chatRoomId) {
    return _localStorage.getCachedMessages(chatRoomId);
  }

  // ==================== AI HISTORY ====================

  Future<void> saveAiHistory(
      String userId, List<Map<String, dynamic>> history) async {
    await _localStorage.saveAiHistory(userId, history);
  }

  List<Map<String, dynamic>>? getAiHistory(String userId) {
    return _localStorage.getAiHistory(userId);
  }

  // ==================== DOCTOR CODE ====================

  Future<void> saveDoctorCode(String code) async {
    await _localStorage.saveDoctorCode(code);
  }

  String? getSavedDoctorCode() {
    return _localStorage.getDoctorCode();
  }

  Future<void> clearDoctorCode() async {
    await _localStorage.clearDoctorCode();
  }

  // ==================== SEARCH HISTORY ====================

  Future<void> saveRecentSearch(String query) async {
    await _localStorage.saveRecentSearch(query);
  }

  List<String> getRecentSearches() {
    return _localStorage.getRecentSearches();
  }

  Future<void> clearRecentSearches() async {
    await _localStorage.clearRecentSearches();
  }

  // ==================== NOTIFICATION SETTINGS ====================

  Future<void> saveNotificationSettings(Map<String, bool> settings) async {
    await _localStorage.saveNotificationSettings(settings);
  }

  Map<String, bool>? getNotificationSettings() {
    return _localStorage.getNotificationSettings();
  }

  // ==================== LANGUAGE ====================

  Future<void> saveLanguageCode(String languageCode) async {
    await _localStorage.saveLanguageCode(languageCode);
  }

  String? getLanguageCode() {
    return _localStorage.getLanguageCode();
  }

  // ==================== FIRST TIME FLAGS ====================

  Future<void> setFirstTimeFlag(String key, bool value) async {
    await _localStorage.setFirstTimeFlag(key, value);
  }

  bool getFirstTimeFlag(String key) {
    return _localStorage.getFirstTimeFlag(key);
  }

  // ==================== GENERIC OPERATIONS ====================

  Future<void> setString(String key, String value) async {
    await _localStorage.setString(key, value);
  }

  String? getString(String key) {
    return _localStorage.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _localStorage.setBool(key, value);
  }

  bool? getBool(String key) {
    return _localStorage.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _localStorage.setInt(key, value);
  }

  int? getInt(String key) {
    return _localStorage.getInt(key);
  }

  Future<void> remove(String key) async {
    await _localStorage.remove(key);
  }

  Future<void> clearAll() async {
    await _localStorage.clearAll();
  }
}
