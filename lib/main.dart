import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

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
import 'features/community/view_model/community_view_model.dart';
import 'features/session/view_model/session_view_model.dart';
import 'features/profile/view_model/profile_view_model.dart';
import 'features/ai_helper/view_model/ai_view_model.dart';
import 'features/chat/view_model/chat_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
        // ── Core Providers (Global — مطلوبين في كل الـ app) ──
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<UserProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<NotificationProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ThemeProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<LocaleProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<PatientProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<CommunityProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<CommunityViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<SessionViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<ProfileViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<AIViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<ChatViewModel>()),

      ],
      // ✅ شلنا Consumer<UserProvider> الزيادة — مكانش بيستخدم userProvider
      child: const LumoAIApp(),
    ),
  );
}
