import 'package:flutter/material.dart';

import '../../core/utils/validators.dart';

mixin FormValidationMixin {
  final formKey = GlobalKey<FormState>();

  // Validate form
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  // Email validation
  String? validateEmail(String? value) {
    return Validators.email(value);
  }

  // Password validation
  String? validatePassword(String? value) {
    return Validators.password(value);
  }

  // Name validation
  String? validateName(String? value) {
    return Validators.name(value);
  }

  // Phone validation
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    return Validators.phone(value);
  }

  // Confirm password validation
  String? validateConfirmPassword(String? value, String password) {
    return Validators.confirmPassword(value, password);
  }

  // Required field validation
  String? validateRequired(String? value, String fieldName) {
    return Validators.required(value, fieldName: fieldName);
  }

  // Child name validation
  String? validateChildName(String? value) {
    return Validators.childName(value);
  }

  // Age validation
  String? validateAge(String? value) {
    return Validators.age(value);
  }

  // Specialization validation
  String? validateSpecialization(String? value) {
    return Validators.specialization(value);
  }

  // License number validation
  String? validateLicenseNumber(String? value) {
    return Validators.licenseNumber(value);
  }

  // Doctor code validation
  String? validateDoctorCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'كود الطبيب مطلوب';
    }
    if (value.length < 6) {
      return 'كود الطبيب غير صحيح';
    }
    return null;
  }

  // Content validation (for posts/messages)
  String? validateContent(String? value, {int minLength = 1}) {
    if (value == null || value.trim().isEmpty) {
      return 'المحتوى مطلوب';
    }
    if (value.trim().length < minLength) {
      return 'المحتوى قصير جداً';
    }
    return null;
  }

  // Dispose form key
  void disposeForm() {
    // formKey is automatically disposed by the widget
  }
}
