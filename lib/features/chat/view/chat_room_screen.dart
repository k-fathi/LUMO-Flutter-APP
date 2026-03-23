import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/providers/auth_provider.dart';
import '../view_model/chat_view_model.dart';
import '../../session/view_model/session_view_model.dart';
import '../../analysis/view/session_config_bottom_sheet.dart';
import 'message_bubble.dart';
import 'chat_input_widget.dart';
import '../../../core/router/route_names.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? otherUserId;

  const ChatRoomScreen({
    super.key,
    required this.chatRoomId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.otherUserId,
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
      _viewModel.authenticateFirebase();
      _viewModel.loadMessages(widget.chatRoomId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ إصلاح: mounted check قبل الـ animate
  void _scrollToBottom() {
    if (!mounted) return;
    if (!_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleSend() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    _messageController.clear();

    _viewModel.sendMessage(
      chatRoomId: widget.chatRoomId,
      senderId: currentUser.id,
      senderName: currentUser.name,
      senderAvatarUrl: currentUser.avatarUrl,
      content: content,
    );

    _scrollToBottom();
  }

  void _navigateToProfile() {
    if (widget.otherUserId != null) {
      Navigator.pushNamed(
        context,
        RouteNames.profile,
        arguments: {'userId': int.tryParse(widget.otherUserId!)},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id.toString() ?? '';

    // ✅ إصلاح: لون الـ messages area من الـ theme بدل hardcoded
    final messagesBackground = theme.brightness == Brightness.light
        ? const Color(0xFFE3F2FD)
        : theme.colorScheme.surfaceContainerLow;

    return Scaffold(
      body: Column(
        children: [
          // Header
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
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back,
                      size: 24, color: Colors.white),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _navigateToProfile,
                  child: Container(
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _navigateToProfile,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.otherUserName,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Consumer2<SessionViewModel, ChatViewModel>(
                          builder: (context, sessionVM, chatVM, child) {
                            if (sessionVM.isActive) {
                              return Text(
                                'جلسة نشطة: ${sessionVM.formattedTime}',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }

                            final room = chatVM.currentChatRoom;
                            final isTyping =
                                room?.isOtherParticipantTyping(currentUserId) ??
                                    false;

                            if (isTyping) {
                              return Text(
                                'يكتب الآن...',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Consumer<SessionViewModel>(
                  builder: (context, sessionVM, child) {
                    if (sessionVM.isActive) {
                      return IconButton(
                        icon: const Icon(Icons.stop_circle_rounded,
                            color: Colors.redAccent, size: 32),
                        onPressed: () => sessionVM.endSession(),
                        tooltip: 'إنهاء الجلسة',
                      );
                    }
                    return IconButton(
                      icon: const Icon(Icons.play_circle_fill_rounded,
                          color: Colors.white, size: 32),
                      onPressed: () {
                        SessionConfigBottomSheet.show(
                          context,
                          receiverId:
                              int.tryParse(widget.otherUserId ?? '') ?? 0,
                        );
                      },
                      tooltip: 'بدء جلسة',
                    );
                  },
                ),
              ],
            ),
          ),

          // Messages Area
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.messages.isEmpty) {
                  return ColoredBox(
                    color: messagesBackground, // ✅ theme-aware
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (viewModel.messages.isEmpty) {
                  return ColoredBox(
                    color: messagesBackground,
                    child: const EmptyState(
                      icon: Icons.chat_outlined,
                      title: 'لا توجد رسائل بعد',
                      message: 'ابدأ المحادثة الآن',
                    ),
                  );
                }

                return ColoredBox(
                  color: messagesBackground,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    itemCount: viewModel.messages.length,
                    itemBuilder: (context, index) {
                      final message = viewModel.messages[index];
                      final isMe = message.senderId.toString() == currentUserId;
                      return MessageBubble(message: message, isMe: isMe);
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
                onAttach: null,
                isLoading: viewModel.isSending,
              );
            },
          ),
        ],
      ),
    );
  }
}
