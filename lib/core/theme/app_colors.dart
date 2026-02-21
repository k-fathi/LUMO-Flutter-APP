import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF1A1F36);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF1A1F36);
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFE3F2FD);
  static const Color secondaryForeground = Color(0xFF2196F3);
  static const Color muted = Color(0xFFE3F2FD);
  static const Color mutedForeground = Color(0xFF64748B);
  static const Color accent = Color(0xFF1565C0);
  static const Color accentForeground = Color(0xFFFFFFFF);
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  static const Color border = Color(0x262196F3); // 0.15 opacity
  static const Color inputBackground = Color(0xFFE3F2FD);
  static const Color ring = Color(0xFF2196F3);

  // Healthcare specific colors from React globals.css
  static const Color healthcareBlue = Color(0xFF2196F3);
  static const Color healthcareLightBlue = Color(0xFF64B5F6);
  static const Color healthcareLighterBlue = Color(0xFF90CAF9);
  static const Color healthcareDarkBlue = Color(0xFF1565C0);
  static const Color healthcareGradientStart = Color(0xFFBBDEFB);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Additional colors for app features
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Status colors for child analysis
  static const Color statusCritical = Color(0xFFEF4444); // Red
  static const Color statusBad = Color(0xFFF59E0B); // Orange
  static const Color statusModerate = Color(0xFFFBBF24); // Yellow
  static const Color statusGood = Color(0xFF10B981); // Green
  static const Color statusExcellent = Color(0xFF059669); // Dark Green

  // Chat colors
  static const Color sentMessage = Color(0xFF2196F3);
  static const Color receivedMessage = Color(0xFFE3F2FD);

  // Online status
  static const Color online = Color(0xFF10B981);
  static const Color offline = Color(0xFF9CA3AF);
}