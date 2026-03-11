import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../data/models/doctor_model.dart';
import '../../../core/utils/mock_accounts.dart';
import '../../../l10n/app_localizations.dart';
import 'chat_screen.dart';

/// Mock conversation thread for the list
class _MockConversationThread {
  final ChatConversation conversation;
  final String lastMessage;
  final String time;
  final int unreadCount;

  const _MockConversationThread({
    required this.conversation,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
  });
}

/// ChatsListScreen (Tab 3) - Figma Screen 9
///
/// ListView of conversation threads.
/// Each item: Avatar (Green Dot online), Name, Last Message, Time, Unread Badge.
/// FAB: (+) to start new conversation.
/// Tapping pushes ChatScreen (covers main layout, hides bottom nav).
class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          l10n.chatTitle,
          style: AppTextStyles.h1.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.textTheme.headlineMedium?.color,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: theme.dividerColor,
          ),
        ),
      ),
      body: _mockThreads.isEmpty
          ? _buildEmptyState(l10n, theme)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _mockThreads.length,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 72),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.dividerColor,
                ),
              ),
              itemBuilder: (context, index) {
                final thread = _mockThreads[index];
                return _ChatListTile(
                  thread: thread,
                  onTap: () {
                    // Push ChatScreen — covers main layout (hides bottom nav)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          conversation: thread.conversation,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      // FAB: Start new conversation (RTL: bottom-left)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewChatBottomSheet(context, theme, l10n);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: theme.disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noChatsYet,
            style: AppTextStyles.h3.copyWith(
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startNewChat,
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showNewChatBottomSheet(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final mockContacts = [
          MockAccounts.getDoctorAccount(),
          MockAccounts.getParentAccount(),
        ];

        return SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium UI Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Text(
                    'بدء محادثة جديدة',
                    style:
                        AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Divider(height: 1, color: theme.dividerColor),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: mockContacts.length,
                    itemBuilder: (context, index) {
                      final contact = mockContacts[index];
                      return _buildDoctorContactTile(
                        ctx,
                        contact,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDoctorContactTile(
      BuildContext context, Map<String, dynamic> contact) {
    final theme = Theme.of(context);
    final name = contact['name'] ?? 'مستخدم';
    final role = contact['role'] == 'doctor' ? 'طبيب' : 'ولي أمر';
    final isOnline = true; // Hardcoded mock
    final id = contact['id'];

    void navigateToProfile() {
      Navigator.pop(context); // Close BottomSheet
      Navigator.pushNamed(
        context,
        '/profile',
        arguments: {'userId': id},
      );
    }

    return Directionality(
        textDirection: TextDirection.rtl,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          leading: GestureDetector(
            onTap: navigateToProfile,
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.secondary,
                  child: Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.online,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: theme.scaffoldBackgroundColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          title: GestureDetector(
            onTap: navigateToProfile,
            child: Text(name,
                style:
                    AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          ),
          subtitle:
              Text(role, style: AppTextStyles.caption.copyWith(fontSize: 12)),
          onTap: () {
            Navigator.pop(context); // Close sheet
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('جاري فتح محادثة مع $name...')),
            );
          },
        ));
  }
}

/// Individual Chat List Tile
class _ChatListTile extends StatelessWidget {
  final _MockConversationThread thread;
  final VoidCallback onTap;

  const _ChatListTile({
    required this.thread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final conv = thread.conversation;
    final hasUnread = thread.unreadCount > 0;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // ── Avatar + Online Dot ─────────────────────────
            GestureDetector(
              onTap: () {
                if (!conv.isAI) {
                  final mockUser = DoctorModel(
                    id: conv.id,
                    email: 'doctor@demo.com',
                    name: conv.userName,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    specialization: 'استشاري النفسية',
                    licenseNumber: '12345',
                    yearsOfExperience: 5,
                  );
                  Navigator.pushNamed(
                    context,
                    RouteNames.profile,
                    arguments: {'user': mockUser},
                  );
                }
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        conv.isAI ? AppColors.primary : AppColors.secondary,
                    child: conv.isAI
                        ? const Icon(Icons.smart_toy_rounded,
                            color: Colors.white, size: 26)
                        : Text(
                            conv.userName.isNotEmpty ? conv.userName[0] : '?',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  // Green dot online indicator
                  if (conv.isOnline)
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.online,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: theme.scaffoldBackgroundColor, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // ── Content ─────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Time row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          conv.userName,
                          style: AppTextStyles.label.copyWith(
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        thread.time,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: hasUnread
                              ? AppColors.primary
                              : theme.textTheme.bodySmall?.color,
                          fontWeight:
                              hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Last message + Unread badge row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: hasUnread
                                ? theme.textTheme.bodyMedium?.color
                                : theme.textTheme.bodySmall?.color,
                            fontWeight:
                                hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                      // Unread Badge
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${thread.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mock Data ─────────────────────────────────────────────────
// 4 conversations including LUMO AI Assistant
final List<_MockConversationThread> _mockThreads = [
  // LUMO AI Assistant (always first)
  const _MockConversationThread(
    conversation: ChatConversation(
      id: 'ai-lumo',
      userName: 'مساعد LUMO الذكي',
      isOnline: true,
      isAI: true,
    ),
    lastMessage: 'كيف يمكنني مساعدتك اليوم؟ 🤖',
    time: '10:02 ص',
    unreadCount: 1,
  ),

  // Doctor conversation
  const _MockConversationThread(
    conversation: ChatConversation(
      id: 'conv-1',
      userName: 'د. أحمد محمد',
      isOnline: true,
    ),
    lastMessage: 'العفو، لا تتردد في التواصل في أي وقت',
    time: '9:35 ص',
    unreadCount: 2,
  ),

  // Parent conversation
  const _MockConversationThread(
    conversation: ChatConversation(
      id: 'conv-2',
      userName: 'سارة أحمد',
      isOnline: false,
    ),
    lastMessage: 'شكراً لك على المعلومات المفيدة!',
    time: 'أمس',
    unreadCount: 0,
  ),

  // Another doctor
  const _MockConversationThread(
    conversation: ChatConversation(
      id: 'conv-3',
      userName: 'د. فاطمة علي',
      isOnline: false,
    ),
    lastMessage: 'موعدك القادم يوم الثلاثاء الساعة 10 صباحاً',
    time: 'الثلاثاء',
    unreadCount: 0,
  ),
];
