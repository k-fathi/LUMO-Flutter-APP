import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get _baseStyle => GoogleFonts.cairo();

  static TextStyle get h1 => _baseStyle.copyWith(
        fontSize: 24.0,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get h2 => _baseStyle.copyWith(
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get h3 => _baseStyle.copyWith(
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get body => _baseStyle.copyWith(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get caption => _baseStyle.copyWith(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedForeground,
        height: 1.5,
      );

  static TextStyle get button => _baseStyle.copyWith(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryForeground,
        height: 1.5,
      );

  static TextStyle get label => _baseStyle.copyWith(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get subtitle => _baseStyle.copyWith(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedForeground,
        height: 1.5,
      );
}
