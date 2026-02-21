import 'dart:io';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/patient_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/generate_code_dialog.dart';
import 'patient_details_screen.dart';
import '../../../shared/widgets/avatar_widget.dart';

/// DoctorPatientsScreen (Doctor View) — Patient Management
///
/// Role-specific: ONLY shown if userRole == Doctor
///
/// Structure:
///   1. Gradient Action Card (Generate New Code)
///   2. Patient List (Avatar + Child Name + Age + Last Update + Chevron)
class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  final _patientsListKey = GlobalKey();

  void _acceptRequest(JoinRequest request) {
    context.read<PatientProvider>().acceptRequest(request);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              AppLocalizations.of(context)!.requestAccepted(request.name))),
    );
  }

  void _rejectRequest(JoinRequest request) {
    context.read<PatientProvider>().rejectRequest(request);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              AppLocalizations.of(context)!.requestRejected(request.name))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final patientProvider = context.watch<PatientProvider>();
    final patients = patientProvider.patients;
    final joinRequests = patientProvider.joinRequests;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          l10n.myPatients,
          style: AppTextStyles.h1.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.textTheme.headlineMedium?.color,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: theme.dividerColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. Dashboard & Action Card ───────────────────
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 160,
                  child: _buildDashboardCard(
                    context,
                    title: l10n.totalPatients,
                    count: '${patients.length}',
                    trendValue: patientProvider.patientsTrend,
                    icon: Icons.people_alt_rounded,
                    color: AppColors.primary,
                    onTap: () {
                      final context = _patientsListKey.currentContext;
                      if (context != null) {
                        Scrollable.ensureVisible(
                          context,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 160,
                  child: _buildActionCard(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── 2. Join Requests ─────────────────────────────
          Row(
            children: [
              Text(
                l10n.joinRequests,
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.headlineSmall?.color,
                ),
              ),
              if (joinRequests.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(
                        alpha:
                            theme.brightness == Brightness.light ? 0.1 : 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${joinRequests.length}',
                    style: AppTextStyles.caption.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (joinRequests.isEmpty)
            _buildEmptyRequests(theme, l10n)
          else
            ...joinRequests.map((req) => _buildJoinRequestCard(context, req)),
          const SizedBox(height: 24),

          // ── 3. Patient List Title ────────────────────────
          Row(
            key: _patientsListKey,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.patientsList,
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.headlineSmall?.color,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${patients.length} ${l10n.patientSuffix}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── 4. Patient List ──────────────────────────────
          ...patients.map((p) => _buildPatientCard(context, p)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Dashboard Card ──────────────────────────────────────────
  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String count,
    required double trendValue,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.light
                  ? color.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(
                        alpha:
                            theme.brightness == Brightness.light ? 0.1 : 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                if (trendValue != 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (trendValue >= 0 ? Colors.green : Colors.red)
                          .withValues(
                              alpha: theme.brightness == Brightness.light
                                  ? 0.1
                                  : 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                            trendValue >= 0
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: trendValue >= 0 ? Colors.green : Colors.red,
                            size: 16),
                        const SizedBox(width: 4),
                        Text(
                            '${trendValue >= 0 ? "+" : ""}${trendValue.toStringAsFixed(0)}%',
                            style: AppTextStyles.caption.copyWith(
                                color:
                                    trendValue >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: AppTextStyles.h1.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                    color: theme.textTheme.displayLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: theme.iconTheme.color?.withValues(alpha: 0.3),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Compact Action Card ─────────────────────────────────────
  Widget _buildActionCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => GenerateCodeDialog(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.light
                  ? const Color(0xFF2563EB).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.newCode,
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.addPatient,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Join Request Card ───────────────────────────────────────
  Widget _buildJoinRequestCard(BuildContext context, JoinRequest request) {
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(
                0xFF334155), // Slate-700 for better visibility in both
            backgroundImage: request.childPhotoUrl != null
                ? FileImage(File(request.childPhotoUrl!))
                : null,
            child: request.childPhotoUrl == null
                ? const Icon(Icons.person, color: AppColors.primary, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.childName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    )),
                Text('والد الطفل: ${request.name}',
                    style: AppTextStyles.caption
                        .copyWith(color: theme.textTheme.bodySmall?.color)),
              ],
            ),
          ),
          // Actions
          IconButton(
            onPressed: () => _acceptRequest(request),
            icon: const Icon(Icons.check_circle, color: Colors.green),
            tooltip: l10n.accept,
          ),
          IconButton(
            onPressed: () => _rejectRequest(request),
            icon: const Icon(Icons.cancel, color: Colors.red),
            tooltip: l10n.reject,
          ),
        ],
      ),
    );
  }

  // ── Patient Card ────────────────────────────────────────────
  Widget _buildPatientCard(BuildContext context, MockPatient patient) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: AvatarWidget(
          size: 48,
          imageFile: patient.childPhotoUrl != null
              ? File(patient.childPhotoUrl!)
              : null,
          fallbackIcon: Icons.child_care_rounded,
        ),
        title: Text(
          patient.childName,
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.cake_outlined,
                    size: 14, color: theme.textTheme.bodySmall?.color),
                const SizedBox(width: 4),
                Text(
                  patient.age,
                  style: AppTextStyles.caption.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.access_time_rounded,
                    size: 14, color: theme.textTheme.bodySmall?.color),
                const SizedBox(width: 4),
                Text(
                  patient.lastUpdate,
                  style: AppTextStyles.caption.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.chevron_left_rounded,
            color: theme.iconTheme.color?.withValues(alpha: 0.5),
            size: 20,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientDetailsScreen(
                patientId: patient.id,
                patientName: patient.childName,
                patientAge: patient.age,
                patientPhotoUrl: patient.childPhotoUrl,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyRequests(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.checklist_rtl_rounded,
                color: theme.disabledColor, size: 32),
            const SizedBox(height: 8),
            Text(
              'لا يوجد طلبات انضمام حالياً',
              style: AppTextStyles.caption.copyWith(color: theme.disabledColor),
            ),
          ],
        ),
      ),
    );
  }
}
