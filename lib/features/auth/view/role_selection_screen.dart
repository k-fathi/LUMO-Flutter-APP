import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/enums/user_role.dart';

/// Role Selection Screen - Pixel-perfect match to React RoleSelectionScreen
///
/// React: bg-gradient-to-b from-[#2196F3] to-[#1565C0], white text, white buttons
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient, // Use shared gradient
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // LUMO Robot Image
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images_from_web/web_splash.png',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'LUMO',
                                  style: GoogleFonts.pacifico(
                                    fontSize: 36,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Welcome Text
                          Text(
                            'مرحباً بك في لومو',
                            style: AppTextStyles.h1.copyWith(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // Subtitle
                          Text(
                            'يرجى اختيار دورك للمتابعة',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 56),

                          // Role Selection Buttons
                          _RoleButton(
                            icon: Icons.person_outline,
                            label: 'أنا مستخدم',
                            onTap: () =>
                                _navigateToSignup(context, UserRole.parent),
                          ),
                          const SizedBox(height: 20),
                          _RoleButton(
                            icon: Icons.medical_services_outlined,
                            label: 'أنا طبيب',
                            onTap: () =>
                                _navigateToSignup(context, UserRole.doctor),
                          ),

                          const Spacer(),

                          // Footer Text
                          Text(
                            'صحتك، أولويتنا.',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToSignup(BuildContext context, UserRole role) {
    Navigator.pushNamed(
      context,
      RouteNames.signup,
      arguments: {'role': role},
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16), // Rounded-2xl
      elevation: 4, // Moderate shadow
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 64, // Taller button
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: AppColors.primary,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
