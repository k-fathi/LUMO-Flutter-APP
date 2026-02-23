import 'dart:math';

import '../utils/mock_delay.dart';

class MockApiService {
  final Random _random = Random();

  // Simulate network delay
  Future<void> _simulateDelay() async {
    await MockDelay.short();
  }

  // Simulate random failure (10% chance)
  void _simulateRandomFailure() {
    if (_random.nextInt(10) == 0) {
      throw Exception('Network error');
    }
  }

  // ==================== AI CHAT ====================

  Future<String> sendAIMessage(String message) async {
    await _simulateDelay();
    _simulateRandomFailure();

    // Simple AI response logic based on keywords
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('مرحبا') || lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'مرحباً! أنا مساعد Lumo AI الذكي. كيف يمكنني مساعدتك اليوم؟';
    }

    if (lowerMessage.contains('أعراض') || lowerMessage.contains('symptoms')) {
      return 'يرجى وصف الأعراض التي يعاني منها طفلك بالتفصيل، وسأحاول مساعدتك. ملاحظة: هذه المعلومات للإرشاد فقط وليست بديلاً عن استشارة طبية.';
    }

    if (lowerMessage.contains('حمى') || lowerMessage.contains('fever') || lowerMessage.contains('حرارة')) {
      return 'الحمى هي ارتفاع في درجة حرارة الجسم فوق 38 درجة مئوية. للتعامل مع الحمى:\n\n1. أعطِ الطفل خافض حرارة مناسب لعمره\n2. احرص على إبقائه رطباً بشرب السوائل\n3. ألبسه ملابس خفيفة\n4. استشر طبيباً إذا استمرت الحمى أكثر من 3 أيام أو تجاوزت 39.5 درجة';
    }

    if (lowerMessage.contains('تطعيم') || lowerMessage.contains('vaccine') || lowerMessage.contains('vaccination')) {
      return 'التطعيمات مهمة جداً لحماية طفلك من الأمراض. تأكد من اتباع جدول التطعيمات الموصى به من وزارة الصحة. إذا كان لديك أسئلة محددة عن تطعيم معين، يرجى ذكره.';
    }

    if (lowerMessage.contains('تغذية') || lowerMessage.contains('nutrition') || lowerMessage.contains('طعام')) {
      return 'التغذية السليمة أساسية لنمو الطفل:\n\n1. احرص على تنوع الطعام\n2. قدم الخضروات والفواكه يومياً\n3. تجنب السكريات المصنعة قدر الإمكان\n4. تأكد من شرب كمية كافية من الماء\n\nإذا كان لديك سؤال محدد عن عمر معين، يسعدني مساعدتك!';
    }

    if (lowerMessage.contains('نوم') || lowerMessage.contains('sleep')) {
      return 'النوم الكافي ضروري لصحة الطفل:\n\n• الرضع (0-12 شهر): 14-17 ساعة\n• الأطفال (1-2 سنة): 11-14 ساعة\n• الأطفال (3-5 سنوات): 10-13 ساعة\n• الأطفال (6-13 سنة): 9-11 ساعة\n\nاحرص على روتين نوم ثابت وبيئة نوم هادئة.';
    }

    if (lowerMessage.contains('إسهال') || lowerMessage.contains('diarrhea')) {
      return 'للتعامل مع الإسهال:\n\n1. أعطِ محلول معالجة الجفاف الفموي\n2. استمر في الرضاعة الطبيعية\n3. تجنب العصائر والمشروبات الغازية\n4. قدم أطعمة خفيفة (موز، أرز، تفاح مهروس)\n5. استشر طبيباً إذا استمر أكثر من 24 ساعة للرضع أو 3 أيام للأطفال';
    }

    if (lowerMessage.contains('سعال') || lowerMessage.contains('cough') || lowerMessage.contains('كحة')) {
      return 'السعال قد يكون علامة على عدة حالات:\n\n1. احرص على إبقاء الطفل رطباً\n2. استخدم مرطب الهواء\n3. أبقِ رأس السرير مرتفعاً قليلاً\n4. تجنب التدخين حول الطفل\n5. استشر طبيباً إذا استمر أكثر من أسبوع أو صاحبه صعوبة في التنفس';
    }

    if (lowerMessage.contains('شكرا') || lowerMessage.contains('thank')) {
      return 'العفو! أنا هنا دائماً للمساعدة. لا تتردد في طرح المزيد من الأسئلة! 😊';
    }

    // Default response
    return 'شكراً لسؤالك. أنا هنا لمساعدتك بشأن صحة طفلك. يمكنك سؤالي عن:\n\n• الأعراض الشائعة (حمى، سعال، إسهال)\n• التغذية والنمو\n• جدول التطعيمات\n• النوم والروتين اليومي\n• أي استفسارات صحية أخرى\n\nملاحظة: هذه المعلومات للإرشاد فقط وليست بديلاً عن استشارة طبية متخصصة.';
  }

  // ==================== ANALYTICS ====================

  Future<Map<String, dynamic>> getAppAnalytics() async {
    await _simulateDelay();
    return {
      'total_users': _random.nextInt(10000) + 1000,
      'total_posts': _random.nextInt(5000) + 500,
      'total_doctors': _random.nextInt(500) + 50,
      'active_users_today': _random.nextInt(1000) + 100,
    };
  }

  // ==================== SEARCH ====================

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    await _simulateDelay();

    // Return mock search results
    return List.generate(
      _random.nextInt(5) + 1,
          (index) => {
        'id': 'user_$index',
        'name': 'مستخدم ${index + 1}',
        'avatar': null,
        'role': _random.nextBool() ? 'doctor' : 'parent',
      },
    );
  }

  Future<List<Map<String, dynamic>>> searchPosts(String query) async {
    await _simulateDelay();

    // Return mock search results
    return List.generate(
      _random.nextInt(10) + 1,
          (index) => {
        'id': 'post_$index',
        'content': 'منشور يحتوي على "$query"',
        'timestamp': DateTime.now().subtract(Duration(hours: index)),
      },
    );
  }

  // ==================== RECOMMENDATIONS ====================

  Future<List<String>> getRecommendedUserIds(String userId) async {
    await _simulateDelay();

    // Return mock recommended user IDs
    return List.generate(
      _random.nextInt(5) + 3,
          (index) => 'recommended_user_${userId}_$index',
    );
  }

  Future<List<String>> getTrendingPostIds() async {
    await _simulateDelay();

    // Return mock trending post IDs
    return List.generate(
      _random.nextInt(10) + 5,
          (index) => 'trending_post_$index',
    );
  }

  // ==================== VALIDATION ====================

  Future<bool> validateDoctorCode(String code) async {
    await _simulateDelay();

    // Mock validation - accept codes starting with 'DOC'
    return code.toUpperCase().startsWith('DOC') && code.length >= 6;
  }

  Future<bool> checkEmailAvailability(String email) async {
    await _simulateDelay();

    // Mock check - randomly return true/false
    return _random.nextBool();
  }

  Future<bool> checkUsernameAvailability(String username) async {
    await _simulateDelay();

    // Mock check - randomly return true/false
    return _random.nextBool();
  }

  // ==================== CONTENT MODERATION ====================

  Future<bool> moderateContent(String content) async {
    await _simulateDelay();

    // Simple content moderation - check for inappropriate words
    final inappropriateWords = ['spam', 'scam', 'inappropriate'];
    final lowerContent = content.toLowerCase();

    for (var word in inappropriateWords) {
      if (lowerContent.contains(word)) {
        return false; // Content flagged
      }
    }

    return true; // Content approved
  }

  // ==================== EXTERNAL SERVICES ====================

  Future<Map<String, dynamic>> getWeatherData(String location) async {
    await _simulateDelay();

    return {
      'location': location,
      'temperature': _random.nextInt(15) + 20, // 20-35°C
      'condition': ['sunny', 'cloudy', 'rainy'][_random.nextInt(3)],
      'humidity': _random.nextInt(40) + 30, // 30-70%
    };
  }

  // ==================== HELPER METHODS ====================

  String generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(20, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  int generateRandomTimestamp() {
    final now = DateTime.now();
    final pastTime = now.subtract(Duration(
      days: _random.nextInt(30),
      hours: _random.nextInt(24),
      minutes: _random.nextInt(60),
    ));
    return pastTime.millisecondsSinceEpoch;
  }
}