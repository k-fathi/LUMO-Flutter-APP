import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

import 'shared/providers/theme_provider.dart';
import 'shared/providers/locale_provider.dart';

import 'core/di/dependency_injection.dart';
import 'shared/providers/auth_provider.dart';
import 'features/community/view_model/community_view_model.dart';
import 'features/profile/view_model/profile_view_model.dart';
import 'features/profile/view_model/profile_view_model.dart';
import 'features/session/view/floating_timer_overlay.dart';

class LumoAIApp extends StatefulWidget {
  const LumoAIApp({super.key});

  @override
  State<LumoAIApp> createState() => _LumoAIAppState();
}

class _LumoAIAppState extends State<LumoAIApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      authProvider.setSessionChangeCallback(() {
        // Clear all session-specific data when user changes (login/logout)
        getIt<CommunityViewModel>().resetState();
        getIt<ProfileViewModel>().resetState();
        // Add others if necessary
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lumo AI',

          // Theme — bound to provider
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          // Localization — bound to provider
          locale: localeProvider.locale,
          supportedLocales: const [
            Locale('ar', ''),
            Locale('en', ''),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Routing — Splash handles onboarding/auth checks
          initialRoute: AppRoutes.initialRoute,
          onGenerateRoute: AppRoutes.onGenerateRoute,

          builder: (context, child) {
            return Stack(
              children: [
                if (child != null) child,
                const FloatingTimerOverlay(),
              ],
            );
          },
        );
      },
    );
  }
}
