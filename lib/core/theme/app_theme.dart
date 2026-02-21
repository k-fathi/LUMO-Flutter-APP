import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseLight = ThemeData.light();
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.cairoTextTheme(baseLight.textTheme).apply(
        bodyColor: AppColors.foreground,
        displayColor: AppColors.foreground,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryForeground,
        error: AppColors.destructive,
        onError: AppColors.destructiveForeground,
        background: AppColors.background,
        onBackground: AppColors.foreground,
        surface: AppColors.card,
        onSurface: AppColors.cardForeground,
        outline: AppColors.border,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h2.copyWith(color: AppColors.foreground),
        iconTheme: const IconThemeData(color: AppColors.foreground),
      ),

      // TabBar theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.mutedForeground,
        indicatorColor: AppColors.primary,
        labelStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppTextStyles.label,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground, // Figma: #E3F2FD
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // Figma: rounded-2xl
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.destructive, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.destructive, width: 2),
        ),
        hintStyle:
            AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          textStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)), // Figma: rounded-2xl
          elevation:
              0, // Figma often uses flat or minimal shadow, adjusting to match modern flat look
          shadowColor: AppColors.primary.withOpacity(0.3),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation:
            0, // Reset to 0, use custom shadows where needed or slight elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Figma: rounded-2xl
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.foreground,
        size: 24,
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedForeground,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.secondary,
        disabledColor: AppColors.muted,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: AppTextStyles.label,
        secondaryLabelStyle:
            AppTextStyles.label.copyWith(color: AppColors.primaryForeground),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.background,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: AppTextStyles.h2,
        contentTextStyle: AppTextStyles.body,
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.foreground,
        contentTextStyle:
            AppTextStyles.body.copyWith(color: AppColors.background),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.mutedForeground;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withOpacity(0.5);
          }
          return AppColors.muted;
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    const Color background = Color(0xFF0F172A); // Slate-900
    const Color surface = Color(0xFF1E293B); // Slate-800
    const Color onBackground = Color(0xFFF8FAFC); // Slate-50
    const Color onSurface = Color(0xFFF8FAFC);
    const Color muted = Color(0xFF334155); // Slate-700
    const Color mutedForeground = Color(0xFF94A3B8); // Slate-400

    final baseDark = ThemeData.dark();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.cairoTextTheme(baseDark.textTheme).apply(
        bodyColor: onBackground,
        displayColor: onBackground,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: const Color(0xFF1E293B), // Slate-800 as secondary
        onSecondary: AppColors.primary,
        error: AppColors.destructive,
        onError: Colors.white,
        surface: surface,
        onSurface: onSurface,
        outline: AppColors.border.withValues(alpha: 0.2),
      ).copyWith(
        surfaceContainerHighest: const Color(0xFF334155), // Slate-700
        onSurfaceVariant: const Color(0xFF94A3B8), // Slate-400
      ),
      scaffoldBackgroundColor: background,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: onBackground, fontSize: 20, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: onBackground),
      ),

      // TabBar theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: const Color(0xFF94A3B8), // Slate-400
        indicatorColor: AppColors.primary,
        labelStyle: AppTextStyles.label.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: AppTextStyles.label.copyWith(
          fontSize: 14,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side:
              BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: muted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppColors.border.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppColors.border.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: AppTextStyles.body.copyWith(
          color: const Color(0xFF94A3B8), // Slate-400
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          textStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: muted,
        disabledColor: muted.withValues(alpha: 0.5),
        selectedColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: AppTextStyles.label.copyWith(color: onSurface),
        secondaryLabelStyle:
            AppTextStyles.label.copyWith(color: AppColors.primaryForeground),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: mutedForeground,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: onSurface,
        size: 24,
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.border.withValues(alpha: 0.1),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
