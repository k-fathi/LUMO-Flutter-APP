import 'package:flutter/material.dart';

import '../../features/splash/view/splash_screen.dart';
import '../../features/onboarding/view/onboarding_screen.dart';
import '../../data/models/user_model.dart';
import '../../data/models/post_model.dart';
import '../../features/loading/view/loading_screen.dart';
import '../../features/auth/view/role_selection_screen.dart';
import '../../features/auth/view/login_screen.dart';
import '../../features/auth/view/signup_screen.dart';
import '../../features/auth/view/forgot_password_screen.dart';
import '../../features/auth/view/otp_verification_screen.dart';
import '../../features/auth/view/reset_password_screen.dart';
import '../../features/home/view/main_layout.dart';
import '../../features/community/view/create_post_screen.dart';
import '../../features/community/view/edit_post_screen.dart';
import '../../features/community/view/post_detail_screen.dart';
import '../../features/chat/view/chats_list_screen.dart';
import '../../features/chat/view/chat_room_screen.dart';
import '../../features/ai_helper/view/ai_chat_screen.dart';
import '../../features/analysis/view/parent_analysis_screen.dart';
import '../../features/analysis/view/doctor_patients_screen.dart';
import '../../features/analysis/view/doctor_patient_detail.dart';
import '../../features/analysis/view/session_detail_placeholder_screen.dart';
import '../../features/profile/view/profile_screen.dart';
import '../../features/profile/view/edit_profile_screen.dart';
import '../../features/profile/view/followers_screen.dart';
import '../../features/profile/view/following_screen.dart';
import '../../features/profile/view/change_password_screen.dart';
import '../../features/profile/view/child_profile_screen.dart';
import '../../features/profile/view/edit_child_profile_screen.dart';
import '../../features/settings/view/settings_screen.dart';
import 'route_names.dart';
import 'route_transitions.dart';

import '../../core/di/dependency_injection.dart';
import '../../features/home/view_model/home_view_model.dart';
import '../../features/chat/view_model/chat_view_model.dart';
import '../../features/ai_helper/view_model/ai_view_model.dart';
import '../../features/analysis/view_model/analysis_view_model.dart';
import '../../features/profile/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  const AppRoutes._();

  static String get initialRoute => RouteNames.splash;

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

      case RouteNames.otpVerification:
        final args = settings.arguments as Map<String, dynamic>;
        return RouteTransitions.slideRight(
          OtpVerificationScreen(
            phone: args['phone'] as String,
            isPasswordReset: args['isPasswordReset'] as bool? ?? false,
          ),
        );

      case RouteNames.resetPassword:
        final args = settings.arguments as Map<String, dynamic>;
        return RouteTransitions.slideRight(
          ResetPasswordScreen(
            phone: args['phone'] as String,
            otp: args['otp'] as String,
          ),
        );

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

      // ✅ إصلاح: editPost يفتح EditPostScreen مش CreatePostScreen
      case RouteNames.editPost:
        final post = settings.arguments as PostModel;
        return RouteTransitions.slideBottom(
          EditPostScreen(post: post),
        );

      case RouteNames.postDetail:
        final args = settings.arguments;
        if (args is PostModel) {
          return RouteTransitions.slideRight(
              PostDetailScreen(postId: args.id, initialPost: args));
        } else {
          final postId = args as int;
          return RouteTransitions.slideRight(PostDetailScreen(postId: postId));
        }

      // ==================== CHAT ====================
      case RouteNames.chatsList:
        return RouteTransitions.slideRight(const ChatsListScreen());

      case RouteNames.chatRoom:
        final args =
            (settings.arguments as Map?)?.cast<String, dynamic>() ?? {};
        return RouteTransitions.slideRight(
          ChangeNotifierProvider(
            create: (_) => getIt<ChatViewModel>(),
            child: ChatRoomScreen(
              chatRoomId:
                  (args['chatRoomId'] ?? args['chatId'] ?? 'unknown_room')
                      .toString(),
              otherUserName:
                  (args['otherUserName'] ?? args['contactName'] ?? 'مستخدم')
                      .toString(),
              otherUserAvatar: args['otherUserAvatar'] as String?,
              otherUserId:
                  (args['otherUserId'] ?? args['contactId'])?.toString(),
            ),
          ),
        );

      // ==================== AI HELPER ====================
      case RouteNames.aiChat:
        return RouteTransitions.slideRight(
          ChangeNotifierProvider(
            create: (_) => getIt<AIViewModel>(),
            child: const AIChatScreen(),
          ),
        );

      // ==================== ANALYSIS ====================
      case RouteNames.parentAnalysis:
        return RouteTransitions.slideRight(
          ChangeNotifierProvider(
            create: (_) => getIt<AnalysisViewModel>(),
            child: const ParentAnalysisScreen(),
          ),
        );

      // ✅ إصلاح: DoctorPatientsScreen بياخد AnalysisViewModel
      case RouteNames.doctorPatients:
        return RouteTransitions.slideRight(
          ChangeNotifierProvider(
            create: (_) => getIt<AnalysisViewModel>(),
            child: const DoctorPatientsScreen(),
          ),
        );

      case RouteNames.doctorPatientDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return RouteTransitions.slideRight(
          ChangeNotifierProvider(
            create: (_) => getIt<AnalysisViewModel>(),
            child: DoctorPatientDetail(
              parentId: int.tryParse(args['parentId'].toString()) ?? 0,
              parentName: args['parentName'] as String,
              childName: args['childName'] as String,
            ),
          ),
        );

      case RouteNames.sessionDetailPlaceholder:
        return RouteTransitions.slideRight(
            const SessionDetailPlaceholderScreen());

      // ==================== PROFILE ====================
      case RouteNames.profile:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return RouteTransitions.slideRight(
          ChangeNotifierProvider(
            create: (_) => getIt<ProfileViewModel>(),
            child: ProfileScreen(
              userId: args['userId'] != null
                  ? int.tryParse(args['userId'].toString())
                  : null,
              user: args['user'] as UserModel?,
            ),
          ),
        );

      case RouteNames.editProfile:
        return RouteTransitions.slideRight(
          ChangeNotifierProvider(
            create: (_) => getIt<ProfileViewModel>(),
            child: const EditProfileScreen(),
          ),
        );

      case RouteNames.followers:
        final userId = settings.arguments as int?;
        return RouteTransitions.slideRight(
          ChangeNotifierProvider(
            create: (_) => getIt<ProfileViewModel>(),
            child: FollowersScreen(userId: userId),
          ),
        );

      case RouteNames.following:
        final userId = settings.arguments as int?;
        return RouteTransitions.slideRight(
          ChangeNotifierProvider(
            create: (_) => getIt<ProfileViewModel>(),
            child: FollowingScreen(userId: userId),
          ),
        );

      case RouteNames.changePassword:
        return RouteTransitions.fade(const ChangePasswordScreen());

      case RouteNames.childProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        return RouteTransitions.slideRight(
          ChangeNotifierProvider(
            create: (_) => getIt<ProfileViewModel>(),
            child: ChildProfileScreen(
              childData: args?['childData'],
            ),
          ),
        );

      case RouteNames.editChildProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        return RouteTransitions.slideRight(
          ChangeNotifierProvider(
            create: (_) => getIt<ProfileViewModel>(),
            child: EditChildProfileScreen(
              childData: args?['childData'],
            ),
          ),
        );

      // ==================== SETTINGS ====================
      case RouteNames.settings:
        return RouteTransitions.slideBottom(const SettingsScreen());

      // ==================== DEFAULT ====================
      default:
        return _errorRoute(settings.name);
    }
  }

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
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> navigateToReplacement<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, void>(context, routeName,
        arguments: arguments);
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
