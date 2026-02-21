import 'package:flutter/material.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/onboarding_model.dart';
import '../../../data/datasources/local_data_source.dart';
import '../../../core/di/dependency_injection.dart';
import 'onboarding_page.dart';

/// Onboarding Screen - Pixel-perfect match to React OnboardingScreen
///
/// React layout:
/// - min-h-screen w-full bg-white flex flex-col
/// - Skip button top-left (RTL: top-right)
/// - Image: w-full max-w-sm aspect-square rounded-3xl shadow-lg object-cover
/// - Title: text-2xl text-[#1a1a2e] mb-4
/// - Subtitle: text-[#64748b]
/// - Dots: h-2 rounded-full, active: w-8 bg-[#2196F3], inactive: w-2 bg-[#cbd5e1]
/// - Button: w-full max-w-sm h-14 rounded-2xl bg-[#2196F3]
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingModel> _screens = OnboardingModel.screens;
  bool _isNavigating = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _completeOnboarding() async {
    if (_isNavigating) return;

    setState(() => _isNavigating = true);

    try {
      final localDataSource = getIt<LocalDataSource>();
      await localDataSource.setOnboardingCompleted(true);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, RouteNames.roleSelection);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isNavigating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: AppColors.destructive,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _screens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mutedForeground,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'تخطي',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                itemCount: _screens.length,
                itemBuilder: (context, index) {
                  final screen = _screens[index];
                  return OnboardingPage(
                    title: screen.title,
                    description: screen.description,
                    imagePath: screen.imagePath,
                    currentPage: index,
                    totalPages: _screens.length,
                  );
                },
              ),
            ),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                children: [
                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _screens.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next Button
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 384),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isNavigating ? null : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isNavigating
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentPage == _screens.length - 1
                                        ? 'ابدأ الآن'
                                        : 'التالي',
                                    style: AppTextStyles.button,
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right, size: 20),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = _currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : AppColors.secondary, // Figma: #2196F3 vs #E3F2FD
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
