import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/repositories/session_repository.dart';
import '../models/session_part.dart';

class SessionViewModel extends ChangeNotifier {
  final SessionRepository _sessionRepository;

  SessionViewModel(this._sessionRepository);

  bool _isActive = false;
  List<SessionPart> _parts = [];
  int _currentPartIndex = 0;
  int _secondsRemainingInPart = 0;
  Timer? _timer;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isActive => _isActive;
  List<SessionPart> get parts => _parts;
  int get currentPartIndex => _currentPartIndex;
  int get secondsRemainingInPart => _secondsRemainingInPart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SessionPart? get currentPart =>
      _parts.isNotEmpty && _currentPartIndex < _parts.length
          ? _parts[_currentPartIndex]
          : null;

  String get currentPartLabel => currentPart?.typeLabel ?? '';

  String get formattedTime {
    final minutes = (_secondsRemainingInPart ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemainingInPart % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void addPart(SessionPart part) {
    _parts.add(part);
    notifyListeners();
  }

  void removePart(int index) {
    if (index >= 0 && index < _parts.length) {
      _parts.removeAt(index);
      notifyListeners();
    }
  }

  void clearParts() {
    _parts.clear();
    notifyListeners();
  }

  Future<void> startSession({
    required int receiverId,
    required List<SessionPart> parts,
  }) async {
    if (parts.isEmpty) {
      _errorMessage = 'الرجاء إضافة جزء واحد على الأقل للجلسة';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _sessionRepository.startSession(
        receiverId: receiverId,
        parts: parts,
      );

      _parts = List.from(parts);
      _currentPartIndex = 0;
      _secondsRemainingInPart = _parts[0].durationMinutes * 60;

      _isActive = true;
      _startTimer();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> endSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _sessionRepository.endSession();
      _finalizeSession();
    } catch (e) {
      _errorMessage = e.toString();
      _finalizeSession();
    }
  }

  void _finalizeSession() {
    _isActive = false;
    _stopTimer();
    _isLoading = false;
    _parts = [];
    _currentPartIndex = 0;
    _secondsRemainingInPart = 0;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemainingInPart > 0) {
        _secondsRemainingInPart--;
        notifyListeners();
      } else {
        // Move to next part
        if (_currentPartIndex < _parts.length - 1) {
          _currentPartIndex++;
          _secondsRemainingInPart = _parts[_currentPartIndex].durationMinutes * 60;
          notifyListeners();
        } else {
          endSession(); // All parts completed
        }
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void resetState() {
    _stopTimer();
    _isActive = false;
    _parts = [];
    _currentPartIndex = 0;
    _secondsRemainingInPart = 0;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
