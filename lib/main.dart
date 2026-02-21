import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/di/dependency_injection.dart';
import 'core/utils/initializer.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/notification_provider.dart';
import 'shared/providers/user_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/patient_provider.dart';
import 'shared/providers/community_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Setup dependency injection
  await DependencyInjection.init();

  // Initialize app services
  await AppInitializer.initialize();

  // Setup timeago locales
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<UserProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<NotificationProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ThemeProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<LocaleProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<PatientProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<CommunityProvider>()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return const LumoAIApp();
        },
      ),
    ),
  );
}
