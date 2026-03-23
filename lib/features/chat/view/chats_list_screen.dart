import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/enums/user_role.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../data/models/chat_room_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/patient_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../view_model/chat_view_model.dart';
import 'chat_room_screen.dart';
import '../../ai_helper/view/ai_chat_screen.dart';
import '../../../shared/widgets/avatar_widget.dart';

///
/// ListView of conversation threads.
/// Each item: Avatar (Green Dot online), Name, Last Message, Time, Unread Badge.
/// FAB: (+) to start new conversation.
/// Tapping pushes ChatRoomScreen.
class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      context.read<ChatViewModel>().loadChatRooms(userId);
      final auth = context.read<AuthProvider>();
      if (auth.currentUser?.role == UserRole.doctor) {
        context.read<PatientProvider>().fetchPatients();
      }
    });
  }

  List<dynamic> _buildDisplayItems(
    List<ChatRoomModel> rooms,
    UserModel currentUser,
    List<UserModel> patients,
  ) {
    final List<dynamic> items = [];
    final currentUserIdStr = currentUser.id.toString();

    if (currentUser.role == UserRole.doctor) {
      // For Doctors: Show active chats, but also show connected patients who haven't started a chat yet
      final activePatientIds =
          rooms.map((r) => r.getOtherParticipantId(currentUserIdStr)).toList();

      // 1. Active Chats
      items.addAll(rooms);

      // 2. Add AI Bot (optional but good for consistency)
      items.add('AI_BOT');

      // 3. Connected patients not yet in active chats
      for (final patient in patients) {
        if (!activePatientIds.contains(patient.id.toString())) {
          items.add(patient);
        }
      }
    } else {
      // For Parents: Primary Doctor -> AI Bot -> Others
      final parent = currentUser is ParentModel ? currentUser : null;
      final connectedDoctorIds = parent?.connectedDoctorIds ?? [];

      // Separate doctor rooms from others
      final doctorRooms = <ChatRoomModel>[];
      final otherRooms = <ChatRoomModel>[];

      for (final room in rooms) {
        final otherId = room.getOtherParticipantId(currentUserIdStr);
        if (connectedDoctorIds.contains(otherId)) {
          doctorRooms.add(room);
        } else {
          otherRooms.add(room);
        }
      }

      // 1. Doctor Chats
      items.addAll(doctorRooms);

      // 2. AI Bot (Always second or first if no doctor chat)
      items.insert(items.isNotEmpty ? 1 : 0, 'AI_BOT');

      // 3. Other Chats
      items.addAll(otherRooms);

      // 4. Also show connected doctors who haven't chatted yet (if any)
      // Note: We don't have full doctor models here typically,
      // but if we did, we would add them.
    }

    return items;
  }

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
      body: Consumer3<ChatViewModel, AuthProvider, PatientProvider>(
        builder: (context, chatViewModel, authProvider, patientProvider, child) {
          final currentUser = authProvider.currentUser;
          if (currentUser == null) return const SizedBox.shrink();

          if (chatViewModel.isLoading && chatViewModel.chatRooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = _buildDisplayItems(
            chatViewModel.chatRooms,
            currentUser,
            patientProvider.patients,
          );

          if (items.isEmpty) {
            return _buildEmptyState(l10n, theme);
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 72),
              child: Divider(
                height: 1,
                thickness: 1,
                color: theme.dividerColor,
              ),
            ),
            itemBuilder: (context, index) {
              final item = items[index];

              if (item is String && item == 'AI_BOT') {
                return _buildAiChatTile(context, theme, l10n);
              }

              if (item is ChatRoomModel) {
                return _buildChatRoomTile(context, item, currentUser, theme);
              }

              if (item is UserModel) {
                return _buildUserContactTile(context, item, currentUser, theme);
              }

              return const SizedBox.shrink();
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

  Widget _buildAiChatTile(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          'assets/images_from_web/web_bot.png',
          width: 24,
          height: 24,
        ),
      ),
      title: Text(l10n.aiHelper, style: AppTextStyles.label),
      subtitle: const Text('مساعدك الذكي دائم الاستعداد',
          maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AIChatScreen()),
        );
      },
    );
  }

  Widget _buildChatRoomTile(BuildContext context, ChatRoomModel room,
      UserModel currentUser, ThemeData theme) {
    final otherName = room.getOtherParticipantName(currentUser.id.toString());
    final otherAvatar =
        room.getOtherParticipantAvatar(currentUser.id.toString());

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: AvatarWidget(
        name: otherName,
        imageUrl: otherAvatar,
        size: 50,
      ),
      title: Text(otherName, style: AppTextStyles.label),
      subtitle: Text(
        room.lastMessage ?? 'إبدأ المحادثة الآن',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (room.lastMessageTimestamp != null)
            Text(
              "${room.lastMessageTimestamp!.hour}:${room.lastMessageTimestamp!.minute.toString().padLeft(2, '0')}",
              style: AppTextStyles.caption,
            ),
          if (room.getUnreadCount(currentUser.id.toString()) > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                room.getUnreadCount(currentUser.id.toString()).toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              chatRoomId: room.id,
              otherUserName: otherName,
              otherUserAvatar: otherAvatar,
              otherUserId:
                  room.getOtherParticipantId(currentUser.id.toString()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserContactTile(BuildContext context, UserModel user,
      UserModel currentUser, ThemeData theme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: AvatarWidget(
        name: user.name,
        imageUrl: user.profileImage ?? user.avatarUrl,
        size: 50,
      ),
      title: Text(user.name, style: AppTextStyles.label),
      subtitle: const Text('بدء محادثة جديدة',
          style: TextStyle(fontStyle: FontStyle.italic)),
      onTap: () {
        // Deterministic chat ID
        final List<String> ids = [
          currentUser.id.toString(),
          user.id.toString()
        ];
        ids.sort();
        final String chatRoomId = ids.join('_');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              chatRoomId: chatRoomId,
              otherUserName: user.name,
              otherUserAvatar: user.profileImage ?? user.avatarUrl,
              otherUserId: user.id.toString(),
            ),
          ),
        );
      },
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
          // BUG FIX #11: Show "لا توجد رسائل بعد" when no chats exist
          Text(
            l10n.noMessages,
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
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final isDoctor = currentUser?.role == UserRole.doctor;

    // Load data if needed
    if (currentUser != null) {
      if (isDoctor) {
        if (context.read<PatientProvider>().patients.isEmpty) {
          context.read<PatientProvider>().fetchPatients();
        }
      } else {
        if (currentUser is ParentModel && currentUser.connectedDoctorIds.isNotEmpty) {
           context.read<PatientProvider>().fetchDoctors(currentUser.connectedDoctorIds);
        }
      }
      
      // Load following if empty
      if (context.read<ProfileViewModel>().followingList.isEmpty) {
        context.read<ProfileViewModel>().loadFollowing(currentUser.id);
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Consumer3<PatientProvider, ProfileViewModel, ChatViewModel>(
              builder: (context, patients, profile, chats, child) {
                // Aggregate and Deduplicate
                final Map<int, UserModel> connectedMap = {};
                final Map<int, UserModel> followingMap = {};
                final Map<int, UserModel> recentMap = {};

                // 1. Connected
                final List<UserModel> connectedList = isDoctor ? patients.patients : patients.doctors;
                for (var u in connectedList) { connectedMap[u.id] = u; }

                // 2. Following
                for (var u in profile.followingList) { 
                  if (!connectedMap.containsKey(u.id)) {
                    followingMap[u.id] = u;
                  }
                }

                // 3. Recent (from chat rooms)
                for (var room in chats.chatRooms) {
                  final otherIdStr = room.getOtherParticipantId(currentUser!.id.toString());
                  final otherId = int.tryParse(otherIdStr) ?? 0;

                  if (otherId != 0 &&
                      !connectedMap.containsKey(otherId) &&
                      !followingMap.containsKey(otherId)) {
                    final otherName = room.getOtherParticipantName(currentUser.id.toString());
                    final otherAvatar = room.getOtherParticipantAvatar(currentUser.id.toString());

                    recentMap[otherId] = UserModel(
                      id: otherId,
                      name: otherName,
                      avatarUrl: otherAvatar,
                      email: '',
                      role: UserRole.parent, // Fallback
                    );
                  }
                }

                final hasAny = connectedMap.isNotEmpty || followingMap.isNotEmpty || recentMap.isNotEmpty;

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
                              color: Colors.grey.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          child: Text(
                            'بدء محادثة جديدة',
                            style: AppTextStyles.h2
                                .copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Divider(height: 1, color: theme.dividerColor),
                        
                        Expanded(
                          child: !hasAny && (patients.isLoading || profile.isListLoading)
                              ? const Center(child: CircularProgressIndicator())
                              : !hasAny
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(32.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.person_search_rounded, size: 64, color: theme.disabledColor),
                                            const SizedBox(height: 16),
                                            Text(
                                              'لا توجد جهات اتصال بعد.',
                                              textAlign: TextAlign.center,
                                              style: AppTextStyles.body,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : ListView(
                                      controller: scrollController,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      children: [
                                        if (connectedMap.isNotEmpty) ...[
                                          _buildSectionHeader(isDoctor ? 'مرضاي' : 'أطبائي المتصلون'),
                                          ...connectedMap.values.map((u) => _buildContactTile(ctx, u, currentUser!.id.toString())),
                                        ],
                                        if (followingMap.isNotEmpty) ...[
                                          _buildSectionHeader('أتابعهم'),
                                          ...followingMap.values.map((u) => _buildContactTile(ctx, u, currentUser!.id.toString())),
                                        ],
                                        if (recentMap.isNotEmpty) ...[
                                          _buildSectionHeader('تواصلت معهم مؤخراً'),
                                          ...recentMap.values.map((u) => _buildContactTile(ctx, u, currentUser!.id.toString())),
                                        ],
                                        const SizedBox(height: 24),
                                      ],
                                    ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildContactTile(
      BuildContext context, UserModel contact, String currentUserId) {
    final name = contact.name;
    final role = contact.role == UserRole.doctor ? 'طبيب' : 'ولي أمر';
    final id = contact.id.toString();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: AvatarWidget(
        name: name,
        imageUrl: contact.avatarUrl,
        size: 48,
      ),
      title: Text(name,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      subtitle:
          Text(role, style: AppTextStyles.caption.copyWith(fontSize: 12)),
      onTap: () {
        Navigator.pop(context); // Close sheet

        // Generate a deterministic chat ID based on user IDs
        final List<String> ids = [currentUserId, id];
        ids.sort();
        final String chatRoomId = ids.join('_');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              chatRoomId: chatRoomId,
              otherUserName: name,
              otherUserAvatar: contact.avatarUrl,
              otherUserId: id,
            ),
          ),
        );
      },
    );
  }

}
