import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'l10n/app_localizations.dart';

import 'shared/providers/theme_provider.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/notification_provider.dart';

import 'core/di/dependency_injection.dart';
import 'shared/providers/auth_provider.dart';
import 'features/community/view_model/community_view_model.dart';
import 'features/profile/view_model/profile_view_model.dart';
import 'core/services/connectivity_service.dart';
import 'features/session/view/floating_timer_overlay.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

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
        getIt<CommunityViewModel>().resetState();
        getIt<ProfileViewModel>().resetState();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, _) {
        return MaterialApp(
          navigatorKey: globalNavigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Lumo AI',

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

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

          initialRoute: AppRoutes.initialRoute,
          onGenerateRoute: AppRoutes.onGenerateRoute,

          builder: (context, child) {
            return _OfflineBanner(
              child: Stack(
                children: [
                  if (child != null) child,
                  const FloatingTimerOverlay(),
                  // ── In-App Notification Pop-up Overlay ──
                  const InAppNotificationOverlay(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  In-App Notification Overlay
//  Shows an animated top-banner when a new notification arrives
//  while the user is inside the app (foreground).
// ─────────────────────────────────────────────────────────────
class InAppNotificationOverlay extends StatefulWidget {
  const InAppNotificationOverlay({super.key});

  @override
  State<InAppNotificationOverlay> createState() =>
      _InAppNotificationOverlayState();
}

class _InAppNotificationOverlayState extends State<InAppNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  InAppNotif? _current;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 280),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _show(InAppNotif notif) async {
    setState(() => _current = notif);
    _controller.forward(from: 0);
    await Future.delayed(const Duration(seconds: 4));
    if (mounted && _current == notif) _dismiss();
  }

  void _dismiss() async {
    await _controller.reverse();
    if (mounted) setState(() => _current = null);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final notif = provider.inAppNotification;
        if (notif != null && notif != _current) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _show(notif);
            provider.consumeInAppNotification();
          });
        }

        if (_current == null) return const SizedBox.shrink();

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final accentColor = _current?.color ?? AppColors.primary;

        return Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: _dismiss,
                  onVerticalDragEnd: (d) {
                    if (d.velocity.pixelsPerSecond.dy < -100) _dismiss();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 24,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // ── Icon badge ──
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _current?.icon ??
                                Icons.notifications_active_rounded,
                            color: accentColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // ── Text ──
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _current?.title ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if ((_current?.body ?? '').isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _current!.body,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.62),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // ── Close ──
                        GestureDetector(
                          onTap: _dismiss,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.38),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Payload for in-app notification banner
class InAppNotif {
  final String title;
  final String body;
  final IconData icon;
  final Color color;

  const InAppNotif({
    required this.title,
    required this.body,
    this.icon = Icons.notifications_active_rounded,
    this.color = AppColors.primary,
  });
}

// ─────────────────────────────────────────────────────────────
class _OfflineBanner extends StatelessWidget {
  final Widget child;
  const _OfflineBanner({required this.child});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityService>().isConnected;
    return Column(
      children: [
        Material(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isConnected ? 0 : 36,
            width: double.infinity,
            color: Colors.red.shade700,
            child: isConnected
                ? const SizedBox.shrink()
                : const Center(
                    child: Text(
                      'لا يوجد اتصال بالإنترنت',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
