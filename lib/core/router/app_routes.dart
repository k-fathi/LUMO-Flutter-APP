import 'package:flutter/material.dart';

import '../../features/splash/view/splash_screen.dart';
import '../../features/onboarding/view/onboarding_screen.dart';
import '../../features/loading/view/loading_screen.dart';
import '../../features/auth/view/role_selection_screen.dart';
import '../../features/auth/view/login_screen.dart';
import '../../features/auth/view/signup_screen.dart';
import '../../features/auth/view/forgot_password_screen.dart';
import '../../features/home/view/main_layout.dart';
import '../../features/community/view/create_post_screen.dart';
import '../../features/community/view/post_detail_screen.dart';
import '../../features/chat/view/chats_list_screen.dart';
import '../../features/chat/view/chat_room_screen.dart';
import '../../features/ai_helper/view/ai_chat_screen.dart';
import '../../features/analysis/view/parent_analysis_screen.dart';
import '../../features/analysis/view/doctor_patients_screen.dart';
import '../../features/analysis/view/doctor_patient_detail.dart';
import '../../features/profile/view/profile_screen.dart';
import '../../features/profile/view/edit_profile_screen.dart';
import '../../features/profile/view/followers_screen.dart';
import '../../features/profile/view/following_screen.dart';
import '../../features/profile/view/doctor_request_screen.dart';
import '../../features/profile/view/doctor_code_generator.dart';
import '../../features/settings/view/settings_screen.dart';
import 'route_names.dart';
import 'route_transitions.dart';

import 'package:provider/provider.dart';
import '../../core/di/dependency_injection.dart';
import '../../features/home/view_model/home_view_model.dart';

class AppRoutes {
  const AppRoutes._();

  // Initial route
  static String get initialRoute => RouteNames.splash;

  // Route generator
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ==================== SPLASH & ONBOARDING ====================
      case RouteNames.splash:
        return RouteTransitions.fade(const SplashScreen());

      case RouteNames.onboarding:
        return RouteTransitions.fade(const OnboardingScreen());

      case RouteNames.loading:
        return RouteTransitions.fade(const LoadingScreen());

      // ==================== AUTHENTICATION ====================
      case RouteNames.roleSelection:
        return RouteTransitions.slideRight(const RoleSelectionScreen());

      case RouteNames.login:
        return RouteTransitions.slideRight(const LoginScreen());

      case RouteNames.signup:
        final args = settings.arguments as Map<String, dynamic>?;
        return RouteTransitions.slideRight(
          SignupScreen(selectedRole: args?['role']),
        );

      case RouteNames.forgotPassword:
        return RouteTransitions.slideBottom(const ForgotPasswordScreen());

      // ==================== MAIN APP ====================
      case RouteNames.mainLayout:
        return RouteTransitions.fade(
          ChangeNotifierProvider(
            create: (_) => getIt<HomeViewModel>(),
            child: const MainLayout(),
          ),
        );

      // ==================== COMMUNITY ====================
      case RouteNames.createPost:
        return RouteTransitions.slideBottom(const CreatePostScreen());

      case RouteNames.editPost:
        final args = settings.arguments as Map<String, dynamic>?;
        return RouteTransitions.slideBottom(
            CreatePostScreen(initialPost: args));

      case RouteNames.postDetail:
        final postId = settings.arguments as String;
        return RouteTransitions.slideRight(PostDetailScreen(postId: postId));

      // ==================== CHAT ====================
      case RouteNames.chatsList:
        return RouteTransitions.slideRight(const ChatsListScreen());

      case RouteNames.chatRoom:
        final args = settings.arguments as Map<String, dynamic>;
        return RouteTransitions.slideRight(
          ChatRoomScreen(
            chatRoomId: args['chatRoomId'] as String,
            otherUserName: args['otherUserName'] as String,
            otherUserAvatar: args['otherUserAvatar'] as String?,
          ),
        );

      // ==================== AI HELPER ====================
      case RouteNames.aiChat:
        return RouteTransitions.slideRight(const AIChatScreen());

      // ==================== ANALYSIS ====================
      case RouteNames.parentAnalysis:
        return RouteTransitions.slideRight(const ParentAnalysisScreen());

      case RouteNames.doctorPatients:
        return RouteTransitions.slideRight(const DoctorPatientsScreen());

      case RouteNames.doctorPatientDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return RouteTransitions.slideRight(
          DoctorPatientDetail(
            parentId: args['parentId'] as String,
            parentName: args['parentName'] as String,
            childName: args['childName'] as String,
          ),
        );

      // ==================== PROFILE ====================
      case RouteNames.profile:
        return RouteTransitions.slideRight(const ProfileScreen());

      case RouteNames.editProfile:
        return RouteTransitions.slideRight(const EditProfileScreen());

      case RouteNames.followers:
        return RouteTransitions.slideRight(const FollowersScreen());

      case RouteNames.following:
        return RouteTransitions.slideRight(const FollowingScreen());

      case RouteNames.doctorRequest:
        return RouteTransitions.slideBottom(const DoctorRequestScreen());

      case RouteNames.doctorCodeGenerator:
        return RouteTransitions.slideRight(const DoctorCodeGeneratorScreen());

      // ==================== SETTINGS ====================
      case RouteNames.settings:
        return RouteTransitions.slideBottom(const SettingsScreen());

      // ==================== DEFAULT ====================
      default:
        return _errorRoute(settings.name);
    }
  }

  // Error route
  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: Center(
          child: Text('الصفحة غير موجودة: $routeName'),
        ),
      ),
    );
  }

  // Navigation helpers
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> navigateToReplacement<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, void>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> navigateToAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  static void popToFirst(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
