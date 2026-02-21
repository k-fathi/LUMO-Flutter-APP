import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

import 'shared/providers/theme_provider.dart';
import 'shared/providers/locale_provider.dart';

class LumoAIApp extends StatelessWidget {
  const LumoAIApp({super.key});

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
        );
      },
    );
  }
}
