import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/emotion_analysis_model.dart';
import '../../../data/repositories/lumo_api_repository.dart';
import '../../../core/services/lumo_api_service.dart';

/// State management for the Image Analysis feature.
///
/// Exposes:
///   - [pickImageFromCamera] / [pickImageFromGallery] — image capture
///   - [analyzeCurrentImage] — sends image to Carol's API (:8001/analyze_image)
///   - [clearResults] — resets to idle state
class ImageAnalysisViewModel extends ChangeNotifier {
  final LumoApiRepository _repository;
  final ImagePicker _picker;

  ImageAnalysisViewModel(this._repository)
      : _picker = ImagePicker();

  // ─── State ────────────────────────────────────────────────────────────────

  File? _selectedImage;
  EmotionAnalysisModel? _result;
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Getters ──────────────────────────────────────────────────────────────

  File? get selectedImage => _selectedImage;
  EmotionAnalysisModel? get result => _result;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasImage => _selectedImage != null;
  bool get hasResult => _result != null;

  // ─── Image Picker ─────────────────────────────────────────────────────────

  /// Opens the device camera to capture a new image.
  Future<void> pickImageFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front, // front camera for child analysis
    );
    _handlePickedFile(picked);
  }

  /// Opens the gallery to select an existing image.
  Future<void> pickImageFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    _handlePickedFile(picked);
  }

  void _handlePickedFile(XFile? file) {
    if (file == null) return;
    _selectedImage = File(file.path);
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Analysis ─────────────────────────────────────────────────────────────

  /// Sends [_selectedImage] to Carol's analysis API and stores the result.
  Future<void> analyzeCurrentImage() async {
    if (_selectedImage == null) {
      _errorMessage = 'الرجاء اختيار صورة أولاً';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _result = await _repository.analyzeImage(_selectedImage!);
      _isLoading = false;
      notifyListeners();
    } on LumoApiException catch (e) {
      _errorMessage = 'خطأ في التحليل (${e.statusCode}): ${e.message}';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع. تحقق من الاتصال بالإنترنت.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Reset ────────────────────────────────────────────────────────────────

  void clearResults() {
    _selectedImage = null;
    _result = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
