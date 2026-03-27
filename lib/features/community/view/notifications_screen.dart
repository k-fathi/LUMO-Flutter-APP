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
      context.read<NotificationProvider>().markAllAsRead();
    });
  }

  Future<void> _handleAccept(ConnectionRequestModel request) async {
    final scaffoldContext = ScaffoldMessenger.of(context);
    final patientProvider = context.read<PatientProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    
    try {
      await patientProvider.acceptPatientRequest(request);
      if (!mounted) return;

      // Send a simulated urgent notification to the doctor
      notificationProvider.sendConnectionAcceptedNotification(
        doctorId: int.tryParse(request.doctorId.toString()) ?? 0,
        patientName: request.childName,
      );

      scaffoldContext.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.requestAccepted(request.doctorName)),
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
          content: Text(AppLocalizations.of(context)!.requestRejected(request.doctorName)),
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
    final generalNotifications = context.watch<NotificationProvider>().notifications;
    final isLoading = patientProvider.isLoading || context.watch<NotificationProvider>().isLoading;

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
            color: theme.iconTheme.color ?? AppColors.foreground,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final patientProvider = context.read<PatientProvider>();
          final notificationProvider = context.read<NotificationProvider>();
          
          await patientProvider.fetchRequests();
          if (!mounted) return;
          await notificationProvider.fetchNotifications();
        },
        child: isLoading && requests.isEmpty && generalNotifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : requests.isEmpty && generalNotifications.isEmpty
                ? _buildEmptyState(l10n)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length + generalNotifications.length,
                    itemBuilder: (context, index) {
                      if (index < requests.length) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildNotificationCard(
                            context,
                            l10n,
                            theme,
                            isDoctor,
                            requests[index],
                          ),
                        );
                      } else {
                        final notification = generalNotifications[index - requests.length];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildGeneralNotificationCard(
                            context,
                            theme,
                            notification,
                          ),
                        );
                      }
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none_rounded,
              size: 64, color: AppColors.mutedForeground),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشعارات جديدة',
            style: AppTextStyles.body.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, 
    AppLocalizations l10n,
    ThemeData theme, 
    bool isDoctor,
    ConnectionRequestModel request,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
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
              AvatarWidget(
                imageUrl: isDoctor ? request.parentAvatarUrl : request.doctorAvatarUrl,
                name: isDoctor ? request.parentName : request.doctorName,
                size: 40,
                fallbackIcon: isDoctor ? Icons.person : Icons.medical_services_rounded,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isDoctor
                      ? l10n.doctorNotificationAccepted(request.childName)
                      : l10n.doctorRequestMessage(request.doctorName),
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                timeago.format(request.createdAt, locale: Localizations.localeOf(context).languageCode),
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.mutedForeground),
              )
            ],
          ),
          if (!isDoctor) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleAccept(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // Medical Green
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.accept,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ] else ...[
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
  Widget _buildGeneralNotificationCard(
    BuildContext context,
    ThemeData theme,
    dynamic notification,
  ) {
    // Backend returns notifications like: { title, content, type, created_at, is_read, ... }
    final title = notification['title'] ?? 'إشعار جديد';
    final content = notification['content'] ?? notification['message'] ?? '';
    final createdAt = DateTime.tryParse(notification['created_at'] ?? '') ?? DateTime.now();
    
    final isReadVal = notification['is_read'];
    final isUnread = isReadVal == false || isReadVal == 0 || isReadVal == null || notification['read_at'] == null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.primary.withValues(alpha: 0.05) : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnread ? AppColors.primary.withValues(alpha: 0.3) : theme.dividerColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active_outlined, 
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
                if (content.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  timeago.format(createdAt, locale: Localizations.localeOf(context).languageCode),
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedForeground, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

