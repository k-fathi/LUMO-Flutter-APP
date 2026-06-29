class Validators {
  const Validators._();

  // Email validation
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final trimmedValue = value.trim();

    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'البريد الإلكتروني غير صالح';
    }

    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 8) {
      return 'كلمة المرور يجب أن لا تقل عن 8 أحرف';
    }

    if (value.length > 128) {
      return 'كلمة المرور طويلة جداً';
    }

    // Check for at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف واحد على الأقل';
    }

    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }

    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (value != password) {
      return 'كلمتا المرور غير متطابقتين';
    }

    return null;
  }

  // Name validation
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم مطلوب';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return 'الاسم قصير جداً';
    }

    if (trimmed.length > 50) {
      return 'الاسم طويل جداً';
    }

    return null;
  }

  // Phone validation
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    final trimmed = value.trim();

    // Check Egyptian mobile regex
    final phoneRegex = RegExp(r'^01[0125][0-9]{8}$');

    if (!phoneRegex.hasMatch(trimmed)) {
      return 'رقم الهاتف غير صالح، يجب أن يكون رقم موبايل مصري صحيح (مثال: 01012345678)';
    }

    return null;
  }

  // Required field validation
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }
    return null;
  }

  // Post content validation
  static String? postContent(String? value) {
    if (value == null || value.isEmpty) {
      return 'المحتوى مطلوب';
    }

    if (value.length > 1000) {
      return 'المحتوى طويل جداً (الحد الأقصى 1000 حرف)';
    }

    return null;
  }

  // Comment validation
  static String? comment(String? value) {
    if (value == null || value.isEmpty) {
      return 'التعليق مطلوب';
    }

    if (value.length > 500) {
      return 'التعليق طويل جداً (الحد الأقصى 500 حرف)';
    }

    return null;
  }

  // Message validation
  static String? message(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرسالة مطلوبة';
    }

    if (value.length > 1000) {
      return 'الرسالة طويلة جداً (الحد الأقصى 1000 حرف)';
    }

    return null;
  }

  // Bio validation
  static String? bio(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Bio is optional
    }

    if (value.length > 200) {
      return 'النبذة طويلة جداً (الحد الأقصى 200 حرف)';
    }

    return null;
  }

  // Doctor code validation
  static String? doctorCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'كود الطبيب مطلوب';
    }

    final trimmed = value.trim();

    if (trimmed.length < 6) {
      return 'كود الطبيب غير صالح';
    }

    if (!trimmed.toUpperCase().startsWith('DOC')) {
      return 'كود الطبيب غير صالح';
    }

    return null;
  }

  // Child name validation
  static String? childName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اسم الطفل مطلوب';
    }

    final trimmed = value.trim();

    if (trimmed.contains(' ')) {
      return 'اسم الطفل يجب أن يكون كلمة واحدة فقط';
    }

    if (trimmed.length < 2) {
      return 'اسم الطفل قصير جداً';
    }

    if (trimmed.length > 50) {
      return 'اسم الطفل طويل جداً';
    }

    return null;
  }

  // Age validation
  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'العمر مطلوب';
    }

    final trimmed = value.trim();
    final age = int.tryParse(trimmed);
    if (age == null) {
      return 'العمر يجب أن يكون رقماً';
    }

    if (age < 0 || age > 150) {
      return 'العمر غير صالح';
    }

    return null;
  }

  // Specialization validation (for doctors)
  static String? specialization(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'التخصص مطلوب';
    }

    final trimmed = value.trim();

    if (trimmed.length < 3) {
      return 'التخصص قصير جداً';
    }

    return null;
  }

  // License number validation (for doctors)
  static String? licenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الترخيص مطلوب';
    }

    final trimmed = value.trim();

    if (trimmed.length < 5) {
      return 'رقم الترخيص غير صالح';
    }

    return null;
  }

  // URL validation
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'الرابط غير صالح';
    }

    return null;
  }

  // Min length validation
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }

    if (value.length < min) {
      return '${fieldName ?? 'هذا الحقل'} قصير جداً (الحد الأدنى $min حرف)';
    }

    return null;
  }

  // Max length validation
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > max) {
      return '${fieldName ?? 'هذا الحقل'} طويل جداً (الحد الأقصى $max حرف)';
    }

    return null;
  }

  // Number validation
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }

    if (int.tryParse(value) == null && double.tryParse(value) == null) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون رقماً';
    }

    return null;
  }

  // Integer validation
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }

    if (int.tryParse(value) == null) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون رقماً صحيحاً';
    }

    return null;
  }

  // Positive number validation
  static String? positiveNumber(String? value, {String? fieldName}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;

    final num = double.parse(value!);
    if (num <= 0) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون رقماً موجباً';
    }

    return null;
  }

  // Compose multiple validators
  static String? compose(List<String? Function(String?)> validators, String? value) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}