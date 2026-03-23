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
import '../view_model/chat_view_model.dart';
import 'chat_room_screen.dart';
import '../../ai_helper/view/ai_chat_screen.dart';
import '../../../shared/widgets/avatar_widget.dart';

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
      final activePatientIds =
          rooms.map((r) => r.getOtherParticipantId(currentUserIdStr)).toList();

      items.addAll(rooms);
      items.add('AI_BOT');

      for (final patient in patients) {
        if (!activePatientIds.contains(patient.id.toString())) {
          items.add(patient);
        }
      }
    } else {
      final parent = currentUser is ParentModel ? currentUser : null;
      final connectedDoctorIds = parent?.connectedDoctorIds ?? [];

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

      items.addAll(doctorRooms);
      items.insert(items.isNotEmpty ? 1 : 0, 'AI_BOT');
      items.addAll(otherRooms);
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

          if (items.isEmpty || (items.length == 1 && items[0] == 'AI_BOT' && chatViewModel.chatRooms.isEmpty)) {
             if (items.length == 1 && items[0] == 'AI_BOT') {
                return ListView(
                  children: [
                    _buildAiChatTile(context, theme, l10n),
                    const SizedBox(height: 100),
                    _buildEmptyState(l10n, theme),
                  ],
                );
             }
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
        style: TextStyle(
          fontWeight: room.getUnreadCount(currentUser.id.toString()) > 0 
              ? FontWeight.bold 
              : FontWeight.normal,
          color: room.getUnreadCount(currentUser.id.toString()) > 0 
              ? theme.textTheme.bodyLarge?.color 
              : theme.textTheme.bodySmall?.color,
        ),
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
      subtitle: const Text('إبدأ المحادثة الآن',
          maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              chatRoomId: 'new_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 64, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text(
            "لا توجد رسائل بعد",
            style: AppTextStyles.h3.copyWith(color: theme.disabledColor),
          ),
          const SizedBox(height: 8),
          Text(
            "ابدأ التواصل مع الأطباء أو المرضى الآن",
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  void _showNewChatBottomSheet(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "بدء محادثة جديدة",
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<PatientProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.patients.isEmpty) {
                    return const Center(child: Text("لا يوجد جهات اتصال متاحة"));
                  }
                  return ListView.builder(
                    itemCount: provider.patients.length,
                    itemBuilder: (context, index) {
                      final user = provider.patients[index];
                      return ListTile(
                        leading: AvatarWidget(
                          name: user.name,
                          imageUrl: user.avatarUrl,
                          size: 40,
                        ),
                        title: Text(user.name),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoomScreen(
                                chatRoomId: 'new_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
                                otherUserName: user.name,
                                otherUserAvatar: user.avatarUrl,
                                otherUserId: user.id.toString(),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
