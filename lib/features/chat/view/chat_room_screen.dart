import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/providers/auth_provider.dart';
import '../view_model/chat_view_model.dart';
import 'message_bubble.dart';
import 'chat_input_widget.dart';

/// ChatRoomScreen - Pixel-perfect match to React ChatScreen
///
/// React layout:
/// - Header: gradient with back + avatar+name inline + phone + more menu
/// - Messages area: bg-[#E3F2FD]
/// - Input: white bg with paperclip + rounded-full E3F2FD input + gradient send
class ChatRoomScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherUserName;
  final String? otherUserAvatar;

  const ChatRoomScreen({
    super.key,
    required this.chatRoomId,
    required this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late ChatViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ChatViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadMessages(widget.chatRoomId);
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
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    _messageController.clear();

    await _viewModel.sendMessage(
      chatRoomId: widget.chatRoomId,
      senderId: currentUser.id,
      senderName: currentUser.name,
      senderAvatarUrl: currentUser.avatarUrl,
      content: content,
    );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      body: Column(
        children: [
          // Gradient Header - React: bg-gradient-to-r from-[#2196F3] to-[#1565C0] px-6 py-4
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Row(
              children: [
                // Back button - React: text-white
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back,
                      size: 24, color: Colors.white),
                ),
                const SizedBox(width: 16),
                // Avatar - React: w-10 h-10 border-2 border-white
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: AvatarWidget(
                    imageUrl: widget.otherUserAvatar,
                    name: widget.otherUserName,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 12),
                // Name + Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // React: text-white
                      Text(
                        widget.otherUserName,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // React: text-white/80 text-sm
                      Text(
                        'نشط الآن',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages Area - React: flex-1 overflow-y-auto px-6 py-6 space-y-4 bg-[#E3F2FD]
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.messages.isEmpty) {
                  return Container(
                    color: const Color(0xFFE3F2FD),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (viewModel.messages.isEmpty) {
                  return Container(
                    color: const Color(0xFFE3F2FD),
                    child: const EmptyState(
                      icon: Icons.chat_outlined,
                      title: 'لا توجد رسائل بعد',
                      message: 'ابدأ المحادثة الآن',
                    ),
                  );
                }

                return Container(
                  color: const Color(0xFFE3F2FD),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    itemCount: viewModel.messages.length,
                    itemBuilder: (context, index) {
                      final message = viewModel.messages[index];
                      final isMe = message.senderId == currentUserId;

                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Chat Input
          Consumer<ChatViewModel>(
            builder: (context, viewModel, child) {
              return ChatInputWidget(
                controller: _messageController,
                onSend: _handleSend,
                onAttach: () {
                  // TODO: Attach file
                },
                isLoading: viewModel.isSending,
              );
            },
          ),
        ],
      ),
    );
  }
}
