import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../ai_helper/view_model/ai_view_model.dart';
import '../../ai_helper/view/ai_message_bubble.dart';
import '../widgets/chat_input_bar.dart';

// AI Chatbot theme colors (now driven by theme)
LinearGradient _kAiGradient(BuildContext context) {
  final theme = Theme.of(context);
  return LinearGradient(
    colors: [
      theme.colorScheme.primary,
      theme.colorScheme.primary.withValues(alpha: 0.8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AIViewModel _viewModel;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  // Staggered animations for chips
  late List<Animation<double>> _chipAnimations;
  late AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<AIViewModel>();

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadChatHistory(userId);
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final chipCount = _suggestions.length;
    _chipAnimations = List.generate(
      chipCount,
      (index) {
        final start = 0.2 + (index * 0.1);
        final end = start + 0.3;
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
                curve: Curves.easeOutBack),
          ),
        );
      },
    );

    // Start entry animations
    _entryController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? 0;

    _viewModel.sendMessage(userId, text);
    _scrollToBottom();
  }

  void _sendSuggestion(String text) {
    _sendMessage(text);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar:
          true, // Allow content to flow under transparent appbar
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Let BackdropFilter handle background
        foregroundColor: theme.textTheme.titleLarge?.color,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset('assets/images_from_web/web_bot.png',
                  width: 22, height: 22, fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appName,
                  style: AppTextStyles.label.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.aiAlwaysOnline,
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.75),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'clear') {
                _showClearDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded),
                    SizedBox(width: 8),
                    Text('مسح المحادثة'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AIViewModel>(
        builder: (context, viewModel, child) {
          // Check if we only have the welcome message (and it's not currently sending)
          // Actually if history is just the welcome message, we count it as empty-ish for the UI
          final isActuallyEmpty =
              viewModel.messages.length <= 1 && !viewModel.isSending;

          return Column(
            children: [
              Expanded(
                child: isActuallyEmpty
                    ? _buildEmptyState(l10n)
                    : _buildActiveChat(viewModel),
              ),
              ChatInputBar(
                onSend: _sendMessage,
                accentColor: theme.colorScheme.primary,
                accentGradient: _kAiGradient(context),
                disabled: viewModel.isSending,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 80, 24, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary
                            .withValues(alpha: _glowAnimation.value * 0.5),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: const Color(0xFF3B82F6)
                            .withValues(alpha: _glowAnimation.value * 0.3),
                        blurRadius: 120,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              const Color(0xFF2563EB),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                            radius: 0.8,
                            center: const Alignment(-0.3, -0.3),
                          ),
                        ),
                      ),
                      Image.asset('assets/images_from_web/web_bot.png',
                          width: 64, height: 64, fit: BoxFit.contain),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                    parent: _entryController,
                    curve: const Interval(0.0, 0.4, curve: Curves.easeIn))),
            child: Column(
              children: [
                Text(
                  l10n.aiWelcomeTitle,
                  style: AppTextStyles.h1.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.aiWelcomeSubtitle,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.mutedForeground,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(_suggestions.length, (index) {
              final s = _suggestions[index];
              return ScaleTransition(
                scale: _chipAnimations[index],
                child: FadeTransition(
                  opacity: _chipAnimations[index],
                  child: ActionChip(
                    onPressed: () => _sendSuggestion(s.text),
                    avatar: Text(s.emoji, style: const TextStyle(fontSize: 16)),
                    label: Text(
                      s.text,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: theme.brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white,
                    side: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                    elevation: theme.brightness == Brightness.light ? 2 : 0,
                    shadowColor: Colors.black.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChat(AIViewModel viewModel) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: viewModel.messages.length,
      itemBuilder: (context, index) {
        return AIMessageBubble(
          message: viewModel.messages[index],
        );
      },
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('مسح المحادثة'),
        content: const Text('هل أنت متأكد من مسح جميع الرسائل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              final userId = authProvider.currentUser?.id ?? 0;
              _viewModel.clearChatHistory(userId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.destructive,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }
}

class _Suggestion {
  final String emoji;
  final String text;
  const _Suggestion(this.emoji, this.text);
}

const List<_Suggestion> _suggestions = [
  _Suggestion('🔍', 'علامات التوحد المبكرة'),
  _Suggestion('🥗', 'نصائح التغذية'),
  _Suggestion('😤', 'التعامل مع نوبات الغضب'),
  _Suggestion('📊', 'تتبع تطور الطفل'),
  _Suggestion('💬', 'تمارين النطق'),
  _Suggestion('🛌', 'تحسين النوم'),
];
