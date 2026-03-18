import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconly/iconly.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../community/view/community_screen.dart';
import '../../chat/view/chats_list_screen.dart';
import '../../chat/view/chatbot_screen.dart';
import '../../analysis/view/parent_analysis_screen.dart';
import '../../analysis/view/doctor_patients_screen.dart';
import '../../profile/view/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final userRole = currentUser.role;

    final List<Widget> screens = [
      const CommunityScreen(), // 0: Home
      userRole.isDoctor // 1: Analysis / Patients
          ? const DoctorPatientsScreen()
          : const ParentAnalysisScreen(),
      const ChatbotScreen(), // 2: AI Assistant (center)
      const ChatsListScreen(), // 3: Chat
      const ProfileScreen(), // 4: Profile
    ];

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Provider<ProfileRepository>.value(
      value: getIt<ProfileRepository>(),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          backgroundColor: theme.bottomAppBarTheme.color ?? theme.cardColor,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(IconlyLight.home),
              selectedIcon:
                  const Icon(IconlyBold.home, color: AppColors.primary),
              label: l10n.home,
            ),
            NavigationDestination(
              icon: const Icon(IconlyLight.chart),
              selectedIcon:
                  const Icon(IconlyBold.chart, color: AppColors.primary),
              label: userRole.isDoctor ? l10n.myPatients : l10n.analysis,
            ),
            NavigationDestination(
              icon: const Icon(IconlyLight.discovery),
              selectedIcon:
                  const Icon(IconlyBold.discovery, color: AppColors.primary),
              label: l10n.aiHelper,
            ),
            NavigationDestination(
              icon: const Icon(IconlyLight.chat),
              selectedIcon:
                  const Icon(IconlyBold.chat, color: AppColors.primary),
              label: l10n.chats,
            ),
            NavigationDestination(
              icon: const Icon(IconlyLight.profile),
              selectedIcon:
                  const Icon(IconlyBold.profile, color: AppColors.primary),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}
