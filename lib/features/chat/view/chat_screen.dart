import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/doctor_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input_bar.dart';

/// Mock Message model
class _MockMessage {
  final String id;
  final String text;
  final String time;
  final bool isMine;

  const _MockMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.isMine,
  });
}

/// Mock Conversation data passed to this screen
class ChatConversation {
  final String id;
  final String userName;
  final String? avatarUrl;
  final bool isOnline;
  final bool isAI;

  const ChatConversation({
    required this.id,
    required this.userName,
    this.avatarUrl,
    this.isOnline = false,
    this.isAI = false,
  });
}

/// ChatScreen (Screen 10) - Figma Spec
///
/// Header: AppBar with User Avatar, Name, "Active now" status. Actions: Call/Video.
/// Body: ListView (reversed: true) starting from the bottom.
/// Footer: ChatInputBar (fixed bottom).
///
/// Pushed via Navigator.push so it covers the main layout (hides bottom nav).
class ChatScreen extends StatefulWidget {
  final ChatConversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<_MockMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = _generateMockMessages(widget.conversation);
  }

  void _sendMessage(String text) {
    setState(() {
      _messages.insert(
        0,
        _MockMessage(
          id: 'new-${_messages.length}',
          text: text,
          time: 'الآن',
          isMine: true,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            // Avatar with online dot
            GestureDetector(
              onTap: () {
                if (!conv.isAI) {
                  final mockUser = DoctorModel(
                    id: conv.id,
                    email: 'doctor@demo.com',
                    name: conv.userName,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    specialization: 'طب نفسي أطفال',
                    licenseNumber: '12345',
                    yearsOfExperience: 5,
                  );
                  Navigator.pushNamed(
                    context,
                    '/profile',
                    arguments: {'user': mockUser},
                  );
                }
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        conv.isAI ? AppColors.primary : AppColors.secondary,
                    child: conv.isAI
                        ? const Icon(Icons.smart_toy_rounded,
                            color: Colors.white, size: 20)
                        : Text(
                            conv.userName.isNotEmpty ? conv.userName[0] : '?',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  if (conv.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.online,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Name + status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  conv.userName,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  conv.isOnline ? 'متصل الآن' : 'غير متصل',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: conv.isOnline
                        ? AppColors.online
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Divider
          Divider(height: 1, thickness: 1, color: theme.dividerColor),

          // Messages list (reversed = newest at bottom)
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return MessageBubble(
                  text: msg.text,
                  time: msg.time,
                  isMine: msg.isMine,
                );
              },
            ),
          ),

          // Input Bar (fixed bottom)
          ChatInputBar(onSend: _sendMessage),
        ],
      ),
    );
  }
}

// ── Mock Messages Generator ────────────────────────────────────
List<_MockMessage> _generateMockMessages(ChatConversation conv) {
  if (conv.isAI) {
    return [
      const _MockMessage(
        id: 'ai-1',
        text: 'مرحباً! أنا مساعد LUMO الذكي 🤖\nكيف يمكنني مساعدتك اليوم؟',
        time: '10:00 ص',
        isMine: false,
      ),
      const _MockMessage(
        id: 'ai-2',
        text: 'مرحباً، ابني عمره 3 سنوات ولاحظت تأخر في النطق. ما النصيحة؟',
        time: '10:01 ص',
        isMine: true,
      ),
      const _MockMessage(
        id: 'ai-3',
        text:
            'التأخر في النطق في سن 3 سنوات يمكن أن يكون طبيعياً في بعض الحالات. إليك بعض النصائح:\n\n'
            '1. تحدث مع طفلك كثيراً واقرأ له قصصاً\n'
            '2. استخدم جمل بسيطة وواضحة\n'
            '3. شجع محاولاته للكلام\n'
            '4. استشر أخصائي نطق وتخاطب\n\n'
            'هل تريد المزيد من التفاصيل؟',
        time: '10:02 ص',
        isMine: false,
      ),
    ].reversed.toList();
  }

  return [
    const _MockMessage(
      id: 'm-1',
      text: 'السلام عليكم دكتور',
      time: '9:30 ص',
      isMine: true,
    ),
    const _MockMessage(
      id: 'm-2',
      text: 'وعليكم السلام، أهلاً بك كيف حالك؟',
      time: '9:31 ص',
      isMine: false,
    ),
    const _MockMessage(
      id: 'm-3',
      text: 'الحمد لله، حبيت أسأل عن نتائج التحليل الأخير',
      time: '9:32 ص',
      isMine: true,
    ),
    const _MockMessage(
      id: 'm-4',
      text:
          'النتائج ممتازة الحمد لله. كل القيم في النطاق الطبيعي. يمكنك الاطمئنان.',
      time: '9:33 ص',
      isMine: false,
    ),
    const _MockMessage(
      id: 'm-5',
      text: 'الحمد لله شكراً لك دكتور 🙏',
      time: '9:34 ص',
      isMine: true,
    ),
    const _MockMessage(
      id: 'm-6',
      text: 'العفو، لا تتردد في التواصل في أي وقت',
      time: '9:35 ص',
      isMine: false,
    ),
  ].reversed.toList();
}
