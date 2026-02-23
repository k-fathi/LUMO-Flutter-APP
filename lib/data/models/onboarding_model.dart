class OnboardingModel {
  final String title;
  final String description;
  final String imagePath;
  final int index;

  const OnboardingModel({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.index,
  });

  // Factory constructor from JSON
  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      title: json['title'] as String,
      description: json['description'] as String,
      imagePath: json['image_path'] as String,
      index: json['index'] as int,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image_path': imagePath,
      'index': index,
    };
  }

  // Static list of onboarding screens
  static List<OnboardingModel> get screens => [
        const OnboardingModel(
          title: 'تتبع صحتك',
          description:
              'راقب مؤشراتك الصحية وابقَ على اطلاع دائم برحلة صحتك مع التتبع والرؤى في الوقت الفعلي.',
          imagePath: 'assets/images_from_web/web_onboarding1.png',
          index: 0,
        ),
        const OnboardingModel(
          title: 'استشارات طبية بالذكاء الاصطناعي',
          description:
              'احصل على إرشادات طبية فورية من روبوت الدردشة المدعوم بالذكاء الاصطناعي، متاح على مدار الساعة للإجابة على أسئلتك الصحية.',
          imagePath: 'assets/images_from_web/web_onboarding2.png',
          index: 1,
        ),
        const OnboardingModel(
          title: 'مجموعة داعمة من الآباء والأطباء',
          description:
              'ابنِ علاقات هادفة مع المتخصصين في الرعاية الصحية واحصل على الرعاية الشخصية عندما تحتاج إليها.',
          imagePath: 'assets/images_from_web/web_onboarding3.png',
          index: 2,
        ),
      ];

  @override
  String toString() {
    return 'OnboardingModel(title: $title, index: $index)';
  }
}
