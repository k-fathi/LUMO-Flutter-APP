import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/patient_provider.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../data/models/connection_request_model.dart';
import '../../../shared/providers/notification_provider.dart';
import '../../../core/enums/connection_status.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchRequests();
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  Future<void> _handleAccept(ConnectionRequestModel request) async {
    final scaffoldContext = ScaffoldMessenger.of(context);
    final patientProvider = context.read<PatientProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    try {
      await patientProvider.acceptPatientRequest(request);
      if (!mounted) return;

      notificationProvider.sendConnectionAcceptedNotification(
        doctorId: int.tryParse(request.doctorId.toString()) ?? 0,
        patientName: request.childName,
      );

      scaffoldContext.showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.requestAccepted(request.doctorName)),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldContext.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  Future<void> _handleReject(ConnectionRequestModel request) async {
    final scaffoldContext = ScaffoldMessenger.of(context);
    final patientProvider = context.read<PatientProvider>();

    try {
      await patientProvider.rejectPatientRequest(request);
      if (!mounted) return;
      scaffoldContext.showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.requestRejected(request.doctorName)),
          backgroundColor: AppColors.destructive,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldContext.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final patientProvider = context.watch<PatientProvider>();

    final currentUser = authProvider.currentUser;
    final isDoctor = currentUser?.role.isDoctor ?? false;
    final requests = patientProvider.joinRequests;
    final generalNotifications =
        context.watch<NotificationProvider>().notifications;
    final isLoading = patientProvider.isLoading ||
        context.watch<NotificationProvider>().isLoading;

    final connectionNotifications = generalNotifications
        .where((n) =>
            _getNotifType(n) == 'connectionRequest' ||
            _getNotifType(n) == 'connectionAccepted' ||
            _getNotifType(n) == 'connection_request' ||
            _getNotifType(n) == 'connection_accepted')
        .toList();
    
    // Filter out like and comment notifications from regular users, but keep them if from doctors
    final otherNotifications = generalNotifications
        .where((n) {
          final t = _getNotifType(n).toLowerCase();
          
          final isSocial = t.contains('like') || t.contains('comment');
          if (isSocial) {
            final creatorMap = n['creator'] is Map ? n['creator'] : (n['sender'] is Map ? n['sender'] : null);
            final role = creatorMap?['role']?.toString().toLowerCase() ?? '';
            final name = creatorMap?['name']?.toString().toLowerCase() ?? '';
            final title = n['title']?.toString().toLowerCase() ?? '';
            final isDoctor = role == 'doctor' || role == 'therapist' || name.contains('د.') || title.contains('د.') || name.startsWith('dr');
            if (!isDoctor) {
              return false; // Hide regular user likes/comments
            }
          }
          
          final isConnection = t.contains('connectionrequest') ||
                 t.contains('connectionaccepted') ||
                 t.contains('connection_request') ||
                 t.contains('connection_accepted');
                 
          return !isConnection;
        })
        .toList();

    final hasContent = requests.isNotEmpty || connectionNotifications.isNotEmpty || otherNotifications.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.notifications),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'تحديد الكل كمقروء',
            onPressed: () {
              context.read<NotificationProvider>().markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديد الكل كمقروء')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final patProv = context.read<PatientProvider>();
          final notifProv = context.read<NotificationProvider>();
          await patProv.fetchRequests();
          await notifProv.fetchNotifications();
        },
        child: isLoading && !hasContent
            ? const Center(child: CircularProgressIndicator())
            : !hasContent
                ? _buildEmptyState(l10n, theme)
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ── 1. طلبات الاتصال (pending) ──
                      if (requests.isNotEmpty) ...[
                        _buildSectionHeader(
                          icon: Icons.person_add_rounded,
                          label: isDoctor
                              ? 'طلبات الإضافة'
                              : 'طلبات الأطباء',
                          color: AppColors.primary,
                          theme: theme,
                        ),
                        const SizedBox(height: 8),
                        ...requests.map(
                          (req) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildConnectionRequestCard(
                                context, l10n, theme, isDoctor, req),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],



                      // ── 4. إشعارات الاتصال (من الباك اند) ──
                      if (connectionNotifications.isNotEmpty) ...[
                        _buildSectionHeader(
                          icon: Icons.link_rounded,
                          label: 'الاتصالات',
                          color: const Color(0xFF10B981),
                          theme: theme,
                        ),
                        const SizedBox(height: 8),
                        ...connectionNotifications.map(
                          (n) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildConnectionNotificationCard(
                                context, theme, n, isDoctor),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── 5. إشعارات أخرى ──
                      if (otherNotifications.isNotEmpty) ...[
                        _buildSectionHeader(
                          icon: Icons.notifications_active_rounded,
                          label: 'إشعارات أخرى',
                          color: AppColors.primary,
                          theme: theme,
                        ),
                        const SizedBox(height: 8),
                        ...otherNotifications.map(
                          (n) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildDynamicNotificationCard(context, theme, n),
                          ),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }

  String _getNotifType(dynamic n) {
    if (n is Map) {
      return (n['type'] ?? '').toString();
    }
    return '';
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 72,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشعارات جديدة',
            style: AppTextStyles.body.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card: Connection Request (pending – with accept/reject) ──
  Widget _buildConnectionRequestCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDoctor,
    ConnectionRequestModel request,
  ) {
    final isPending = request.status == ConnectionStatus.pending;
    final isAccepted = request.status == ConnectionStatus.accepted;
    final isRejected = request.status == ConnectionStatus.rejected;

    Color statusColor = AppColors.primary;
    String statusLabel = '';
    IconData statusIcon = Icons.hourglass_empty_rounded;
    if (isAccepted) {
      statusColor = const Color(0xFF10B981);
      statusLabel = 'تم القبول';
      statusIcon = Icons.check_circle_rounded;
    } else if (isRejected) {
      statusColor = AppColors.destructive;
      statusLabel = 'تم الرفض';
      statusIcon = Icons.cancel_rounded;
    } else {
      statusLabel = 'في الانتظار';
      statusIcon = Icons.hourglass_empty_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPending
              ? AppColors.primary.withValues(alpha: 0.3)
              : statusColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.light
                ? Colors.black.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  final userId = isDoctor ? request.parentId : request.doctorId;
                  final uid = int.tryParse(userId.toString());
                  if (uid != null && uid != 0) {
                    Navigator.pushNamed(context, RouteNames.profile,
                        arguments: {'userId': uid});
                  }
                },
                child: AvatarWidget(
                  imageUrl: isDoctor
                      ? request.parentAvatarUrl
                      : request.doctorAvatarUrl,
                  // Pass empty name for doctor to prevent DiceBear cartoon emoji and use medical fallback icon
                  name: isDoctor ? request.parentName : '',
                  size: 44,
                  fallbackIcon: isDoctor
                      ? Icons.person
                      : Icons.medical_services_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDoctor
                          ? (isAccepted
                              ? '✅ تم قبول طلبك لإضافة ${request.childName}'
                              : isRejected
                                  ? '❌ تم رفض طلب إضافة ${request.childName}'
                                  : 'ارسلت طلب إضافة لـ ${request.parentName}')
                          : (request.childName.isNotEmpty && request.childName != 'null')
                              ? '🔔 د. ${request.doctorName} يريد متابعة حالة طفلك (${request.childName})'
                              : '🔔 د. ${request.doctorName} يريد متابعة الحالة',
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    if (isDoctor && request.childName.isNotEmpty && request.childName != 'null') ...[
                      const SizedBox(height: 4),
                      Text(
                        'الطفل: ${request.childName}',
                        style: AppTextStyles.caption.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeago.format(request.createdAt,
                        locale:
                            Localizations.localeOf(context).languageCode),
                    style: AppTextStyles.caption.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 10),
                  ),
                  if (!isPending) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          statusLabel,
                          style: AppTextStyles.caption.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),

          // ── Accept/Reject buttons for parent view (pending only) ──
          if (!isDoctor && isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleAccept(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.accept,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleReject(request),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.destructive,
                      side: const BorderSide(color: AppColors.destructive),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.reject,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],

          // ── Doctor can view patient profile for accepted requests ──
          if (isDoctor && isAccepted) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.doctorPatientDetail,
                    arguments: {
                      'parentId': request.parentId,
                      'parentName': request.parentName,
                      'childName': request.childName,
                    },
                  );
                },
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('عرض الملف'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Card: Like / Comment / Other general notification ──
  Widget _buildRichNotificationCard(
    BuildContext context,
    ThemeData theme,
    dynamic notification, {
    required IconData icon,
    required Color iconColor,
    required Color accentColor,
  }) {
    final title = (notification['title'] ?? 'إشعار جديد').toString();
    final content =
        (notification['content'] ?? notification['message'] ?? '').toString();
    final createdAt =
        DateTime.tryParse(notification['created_at'] ?? '') ?? DateTime.now();
    final isReadVal = notification['is_read'];
    final isUnread = isReadVal == false ||
        isReadVal == 0 ||
        isReadVal == null ||
        notification['read_at'] == null;

    // Try to get sender avatar / image
    final imageUrl = notification['image_url']?.toString() ??
        notification['sender']?['avatar_url']?.toString() ??
        notification['creator']?['avatar_url']?.toString();

    final senderName = notification['sender']?['name']?.toString() ??
        notification['creator']?['name']?.toString();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnread
            ? accentColor.withValues(alpha: 0.05)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnread
              ? accentColor.withValues(alpha: 0.25)
              : theme.dividerColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sender avatar or icon
          if (imageUrl != null && imageUrl.isNotEmpty)
            Stack(
              children: [
                AvatarWidget(imageUrl: imageUrl, name: senderName, size: 40),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: theme.cardColor, width: 1.5),
                    ),
                    child: Icon(icon, color: Colors.white, size: 10),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (content.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    content,
                    style: AppTextStyles.caption.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  timeago.format(createdAt,
                      locale:
                          Localizations.localeOf(context).languageCode),
                  style: AppTextStyles.caption.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  // ── Card: Connection notification from backend (accepted/rejected) ──
  Widget _buildConnectionNotificationCard(
    BuildContext context,
    ThemeData theme,
    dynamic notification,
    bool isDoctor,
  ) {
    final type = _getNotifType(notification);
    final isAccepted =
        type == 'connectionAccepted' || type == 'connection_accepted';

    final iconColor =
        isAccepted ? const Color(0xFF10B981) : AppColors.primary;
    final icon = isAccepted
        ? Icons.check_circle_rounded
        : Icons.person_add_rounded;

    return _buildRichNotificationCard(
      context,
      theme,
      notification,
      icon: icon,
      iconColor: iconColor,
      accentColor: iconColor,
    );
  }

  // ── Card: Dynamic Notification for Analysis/Comments ──
  Widget _buildDynamicNotificationCard(BuildContext context, ThemeData theme, dynamic notification) {
    final t = _getNotifType(notification).toLowerCase();
    final body = (notification['content'] ?? notification['message'] ?? '').toString().toLowerCase();
    
    IconData icon = Icons.notifications_active_rounded;
    Color iconColor = AppColors.primary;
    Color accentColor = AppColors.primary;

    if (t.contains('analysis')) {
      icon = Icons.analytics_rounded;
      // Urgency logic based on body text
      if (body.contains('تراجع') || body.contains('تدخل') || body.contains('انحدار') || body.contains('طوارئ') || body.contains('خطر')) {
        iconColor = Colors.redAccent;
        accentColor = Colors.redAccent;
        icon = Icons.warning_rounded;
      } else if (body.contains('تحسن') || body.contains('ممتاز') || body.contains('جيد')) {
        iconColor = const Color(0xFF10B981);
        accentColor = const Color(0xFF10B981);
      } else {
        iconColor = Colors.orangeAccent;
        accentColor = Colors.orangeAccent;
      }
    } else if (t.contains('comment') || t.contains('like')) {
      icon = Icons.chat_bubble_rounded;
      iconColor = Colors.blueAccent;
      accentColor = Colors.blueAccent;
    }

    return _buildRichNotificationCard(
      context,
      theme,
      notification,
      icon: icon,
      iconColor: iconColor,
      accentColor: accentColor,
    );
  }
}
