import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/providers/auth_provider.dart';
import '../view_model/ai_view_model.dart';
import 'ai_message_bubble.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late AIViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<AIViewModel>();
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadChatHistory(userId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _handleSend() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? '';

    _messageController.clear();

    await _viewModel.sendMessage(userId, message);
    _scrollToBottom();
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'المساعد الطبي الذكي',
        showBackButton: false,
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
          if (viewModel.messages.isEmpty) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // LUMO Robot - real asset image
                        Image.asset(
                          'assets/images/ai_avatar.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 24),
                        // CONNECT - React: text-4xl font-bold text-[#2196F3]
                        const Text(
                          'CONNECT',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // React: text-[#2196F3] opacity-80
                        Text(
                          'Your AI Assistant.',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF2196F3).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildInputArea(viewModel, theme),
              ],
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: viewModel.messages.length,
                  itemBuilder: (context, index) {
                    return AIMessageBubble(
                      message: viewModel.messages[index],
                    );
                  },
                ),
              ),
              _buildInputArea(viewModel, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputArea(AIViewModel viewModel, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                child: AppTextField(
                  controller: _messageController,
                  hint: 'اسأل عن أي شيء',
                  maxLines: null,
                  enabled: !viewModel.isSending,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: viewModel.isSending ? null : _handleSend,
                icon: viewModel.isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
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
              final userId = authProvider.currentUser?.id ?? '';
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
