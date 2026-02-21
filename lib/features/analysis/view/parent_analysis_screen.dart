import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../data/models/parent_model.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/emotion_bar.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/providers/patient_provider.dart';

/// AnalysisScreen (Parent View) — Figma Screen 11
///
/// Role-specific: ONLY shown if userRole == Parent
///
/// Structure:
///   - Header: Title + Date Selector row (< This Week >)
///   - Chart Section: EmotionBar widgets (custom, no chart packages)
///   - History: Daily Summary Cards (Date + Dominant Emotion)
class ParentAnalysisScreen extends StatelessWidget {
  const ParentAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.analysisTitle),
      ),
      body: PatientAnalysisView(),
    );
  }
}

class PatientAnalysisView extends StatefulWidget {
  final String? patientId;
  final String? patientName;
  final String? patientAge;
  final String? patientPhotoUrl;

  const PatientAnalysisView({
    super.key,
    this.patientId,
    this.patientName,
    this.patientAge,
    this.patientPhotoUrl,
  });

  @override
  State<PatientAnalysisView> createState() => _PatientAnalysisViewState();
}

class _PatientAnalysisViewState extends State<PatientAnalysisView> {
  int _selectedSessionIndex = 0;
  DateTimeRange? _selectedDateRange;
  int _chartType = 0; // 0 = Bars, 1 = Pie, 2 = Line

  void _shiftDateRange(int days) {
    setState(() {
      DateTime currentEnd = _selectedDateRange?.end ?? DateTime.now();
      DateTime currentStart = _selectedDateRange?.start ??
          DateTime.now().subtract(const Duration(days: 7));

      DateTime newStart = currentStart.add(Duration(days: days));
      DateTime newEnd = currentEnd.add(Duration(days: days));

      if (newEnd.isAfter(DateTime.now())) {
        newEnd = DateTime.now();
        // Maintain the same duration
        newStart = newEnd.subtract(currentEnd.difference(currentStart));
      }

      _selectedDateRange = DateTimeRange(start: newStart, end: newEnd);
    });
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        // Optionally reset session index if date changes
        _selectedSessionIndex = 0;
      });
    }
  }

  String _getDateLabel(AppLocalizations l10n) {
    if (_selectedDateRange == null) return 'This Week';
    final start = _selectedDateRange!.start;
    final end = _selectedDateRange!.end;
    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final patientProvider = context.watch<PatientProvider>();

    MockPatient? currentPatient;
    if (widget.patientId != null) {
      currentPatient = patientProvider.patients
          .cast<MockPatient?>()
          .firstWhere((p) => p?.id == widget.patientId, orElse: () => null);
    } else {
      // Logic for parent login matching could go here
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientMiniProfile(theme, l10n),
            const SizedBox(height: 24),
            Text(
              'اختر الجلسة',
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _buildSessionSelector(theme, l10n),
            const SizedBox(height: 24),

            // Filterable Content
            if (_selectedSessionIndex == 0) ...[
              _buildAIProgressReport(l10n, theme),
              const SizedBox(height: 24),
              _buildAnalysisHeader(theme, l10n),
              const SizedBox(height: 16),
              _buildMetricGrid(l10n, theme, currentPatient),
              const SizedBox(height: 32),
              _buildSectionTitle('توصيات المساعد الذكي'),
              const SizedBox(height: 16),
              _buildRecommendationsList(l10n, theme),
              const SizedBox(height: 24),
              _buildEmotionChart(l10n, theme),
              const SizedBox(height: 24),
              _buildSectionTitle('Daily History'),
              const SizedBox(height: 16),
              ..._dailySummaries.map((s) => _buildDaySummaryCard(s, theme)),
            ] else ...[
              // Session Specific View
              _buildSessionSummary(theme, l10n, _selectedSessionIndex),
              const SizedBox(height: 24),
              _buildEmotionChart(l10n, theme),
              const SizedBox(height: 24),
              _buildSectionTitle('Session Recommendations'),
              const SizedBox(height: 16),
              _buildRecommendationsList(l10n, theme),
            ],
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  // ── Patient Profile Header ────────────────────────────────
  Widget _buildPatientMiniProfile(ThemeData theme, AppLocalizations l10n) {
    final authProvider = context.read<AuthProvider>();

    String name = widget.patientName ?? '';
    String age = widget.patientAge ?? '';
    String? photoUrl = widget.patientPhotoUrl;

    if (name.isEmpty && authProvider.currentUser != null) {
      if (authProvider.currentUser is ParentModel) {
        final parent = authProvider.currentUser as ParentModel;
        name = parent.childName;
        age = '${parent.childAge} سنوات';
        photoUrl = parent.childPhotoUrl;
      } else {
        name = 'كريم محمد';
        age = '٦ سنوات';
      }
    } else if (name.isEmpty) {
      name = 'كريم محمد';
      age = '٦ سنوات';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary
                .withOpacity(theme.brightness == Brightness.light ? 0.08 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          AvatarWidget(
            size: 72,
            imageFile: photoUrl != null ? File(photoUrl) : null,
            fallbackIcon: Icons.child_care_rounded,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(
                            theme.brightness == Brightness.light ? 0.1 : 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        age,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(
                            theme.brightness == Brightness.light ? 0.1 : 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.green, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            l10n.stateGood,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Session Selector ─────────────────────────────────────
  Widget _buildSessionSelector(ThemeData theme, AppLocalizations l10n) {
    final sessions = [
      'كل الجلسات',
      'جلسة #1',
      'جلسة #2',
      'جلسة #3',
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedSessionIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(sessions[index]),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _selectedSessionIndex = index;
                  });
                }
              },
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  // ── AI Progress Report ───────────────────────────────────
  Widget _buildAIProgressReport(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF2563EB)
          ], // Premium AI Blue Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.aiProgressReport,
                style: AppTextStyles.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.aiReportContent,
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withOpacity(0.95),
              height: 1.6,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(
      AppLocalizations l10n, ThemeData theme, MockPatient? patient) {
    return LayoutBuilder(builder: (context, constraints) {
      final cardWidth = (constraints.maxWidth - 16) / 2;

      // Calculate trends
      String engagementValue = '85%';
      String engagementTrend = '+5%';
      String sessionsValue = '24';
      String sessionsTrend = '+3';
      Color engagementTrendColor = Colors.green;
      Color sessionsTrendColor = Colors.green;

      if (patient != null) {
        // Engagement
        engagementValue = '${(patient.engagementRate * 100).toInt()}%';
        final eDiff = patient.engagementRate - patient.previousEngagementRate;
        engagementTrend = '${eDiff >= 0 ? "+" : ""}${(eDiff * 100).toInt()}%';
        engagementTrendColor = eDiff >= 0 ? Colors.green : Colors.red;

        // Sessions
        sessionsValue = '${patient.sessionsCompleted}';
        final sDiff = patient.sessionsCompleted - patient.previousSessions;
        sessionsTrend = '${sDiff >= 0 ? "+" : ""}$sDiff';
        sessionsTrendColor = sDiff >= 0 ? Colors.green : Colors.red;
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMetricCard(
            theme,
            width: cardWidth,
            title: l10n.engagementRate,
            value: engagementValue,
            trend: engagementTrend,
            trendColor: engagementTrendColor,
            icon: Icons.local_fire_department_rounded,
            color: Colors.orange,
          ),
          _buildMetricCard(
            theme,
            width: cardWidth,
            title: l10n.sessionsCompleted,
            value: sessionsValue,
            trend: sessionsTrend,
            trendColor: sessionsTrendColor,
            icon: Icons.check_circle_outline_rounded,
            color: Colors.green,
          ),
        ],
      );
    });
  }

  Widget _buildMetricCard(
    ThemeData theme, {
    required double width,
    required String title,
    required String value,
    required String trend,
    required Color trendColor,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.light
                ? Colors.black.withOpacity(0.03)
                : Colors.white.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(
                      theme.brightness == Brightness.light ? 0.1 : 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded,
                        color: Colors.green, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: AppTextStyles.caption.copyWith(
                        color: trendColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h1.copyWith(
              color: theme.textTheme.displayLarge?.color,
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h2.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    );
  }

  // ── Recommendations ────────────────────────────────────────
  Widget _buildRecommendationsList(AppLocalizations l10n, ThemeData theme) {
    final suggestions = _selectedSessionIndex == 0
        ? [
            'الاستمرار في تمارين التحدث لمدة ٣٠ دقيقة يومياً',
            'تشجيع الطفل على التعبير عن غضبه بالرسم',
            'زيادة فترات اللعب الاجتماعي مع أقرانه',
          ]
        : [
            'التركيز على مهارات تبادل الأدوار',
            'استخدام الروبوت كمحفز للنطق الوجداني',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...suggestions.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                    alpha: theme.brightness == Brightness.light ? 0.03 : 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primary.withValues(
                        alpha:
                            theme.brightness == Brightness.light ? 0.1 : 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildAnalysisHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: _showDateRangePicker,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: theme.brightness == Brightness.light
                      ? Colors.black.withValues(alpha: 0.04)
                      : Colors.white.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  _getDateLabel(l10n),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: theme.disabledColor),
              ],
            ),
          ),
        ),
        Row(
          children: [
            _buildHeaderAction(theme, Icons.chevron_left_rounded, onTap: () {
              _shiftDateRange(-7);
            }),
            const SizedBox(width: 8),
            _buildHeaderAction(theme, Icons.chevron_right_rounded,
                enabled: _selectedDateRange != null &&
                    _selectedDateRange!.end
                        .add(const Duration(days: 1))
                        .isBefore(DateTime.now()), onTap: () {
              _shiftDateRange(7);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderAction(ThemeData theme, IconData icon,
      {VoidCallback? onTap, bool enabled = true}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
        child: Icon(icon,
            size: 20, color: enabled ? AppColors.primary : theme.disabledColor),
      ),
    );
  }

  Widget _buildSessionSummary(
      ThemeData theme, AppLocalizations l10n, int sessionIndex) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(
                alpha: theme.brightness == Brightness.light ? 0.3 : 0.5),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.rocket_launch_rounded,
                    color: Colors.white),
              ),
              Text(
                'جلسة #$sessionIndex',
                style: AppTextStyles.h3
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'ملخص الجلسة',
            style: AppTextStyles.label.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'خلال هذه الجلسة، أظهر الطفل تقدماً ملحوظاً في حل الألغاز التعاونية مع الروبوت. كان التواصل البصري مستقراً بنسبة ٧٥٪.',
            style:
                AppTextStyles.body.copyWith(color: Colors.white, height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSessionStat('مدة الجلسة', '٢٥ دقيقة'),
              const SizedBox(width: 24),
              _buildSessionStat('مستوى التفاعل', 'ممتاز'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption
              .copyWith(color: Colors.white.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ── Emotion Chart Card ──────────────────────────────────────
  Widget _buildEmotionChart(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.light
                ? Colors.black.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.insights_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.emotionDistribution,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.headlineSmall?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart Type Selector
          Center(
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                    value: 0,
                    icon: Icon(Icons.bar_chart_rounded),
                    label: Text('أشرطة')),
                ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.pie_chart_rounded),
                    label: Text('دائري')),
                ButtonSegment(
                    value: 2,
                    icon: Icon(Icons.show_chart_rounded),
                    label: Text('خطوط')),
              ],
              selected: {_chartType},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _chartType = newSelection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                selectedForegroundColor: Colors.white,
                selectedBackgroundColor: AppColors.primary,
                backgroundColor: theme.scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Render selected chart type
          if (_chartType == 0) _buildBarChart(l10n),
          if (_chartType == 1) _buildPieChart(l10n),
          if (_chartType == 2) _buildLineChart(l10n, theme),
        ],
      ),
    );
  }

  Widget _buildBarChart(AppLocalizations l10n) {
    return Column(
      children: [
        EmotionBar(
          emoji: '😊',
          label: l10n.happy,
          percentage: 0.60,
          color: const Color(0xFF22C55E), // Green
        ),
        EmotionBar(
          emoji: '😌',
          label: l10n.calm,
          percentage: 0.20,
          color: AppColors.primary, // Blue
        ),
        EmotionBar(
          emoji: '😢',
          label: l10n.sad,
          percentage: 0.12,
          color: AppColors.destructive, // Red
        ),
        EmotionBar(
          emoji: '😠',
          label: l10n.angry,
          percentage: 0.08,
          color: const Color(0xFFF97316), // Orange
        ),
      ],
    );
  }

  Widget _buildPieChart(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '٨٥٪',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                    ),
                  ),
                  Text(
                    'تفاعل إيجابي',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      color:
                          const Color(0xFF3B82F6), // Professional High-End Blue
                      value: 60,
                      title: '',
                      radius: 25,
                      badgeWidget: _buildPieBadge('😊', theme),
                      badgePositionPercentageOffset: 0.9,
                    ),
                    PieChartSectionData(
                      color: const Color(0xFF10B981), // Medical Green
                      value: 20,
                      title: '',
                      radius: 22,
                    ),
                    PieChartSectionData(
                      color: const Color(0xFFFACC15), // Insightful Yellow
                      value: 12,
                      title: '',
                      radius: 19,
                    ),
                    PieChartSectionData(
                      color: const Color(0xFFEF4444).withValues(
                          alpha:
                              theme.brightness == Brightness.light ? 0.6 : 0.8),
                      value: 8,
                      title: '',
                      radius: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildChartLegend(theme),
      ],
    );
  }

  Widget _buildChartLegend(ThemeData theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem(theme, color: const Color(0xFF3B82F6), label: 'سعيد'),
        _buildLegendItem(theme, color: const Color(0xFF10B981), label: 'هادئ'),
        _buildLegendItem(theme, color: const Color(0xFFFACC15), label: 'نشط'),
        _buildLegendItem(theme, color: const Color(0xFFEF4444), label: 'متوتر'),
      ],
    );
  }

  Widget _buildLegendItem(ThemeData theme,
      {required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPieBadge(String emoji, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4)
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildLineChart(AppLocalizations l10n, ThemeData theme) {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.dividerColor.withValues(alpha: 0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}%',
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
                reservedSize: 35,
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = [
                    'سبت',
                    'أحد',
                    'اثنين',
                    'ثلاثاء',
                    'أربعاء',
                    'خميس',
                    'جمعة'
                  ];
                  if (value >= 0 && value < 7) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(days[value.toInt()],
                          style: AppTextStyles.caption.copyWith(fontSize: 10)),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 30,
                interval: 1,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 45),
                FlSpot(1, 52),
                FlSpot(2, 48),
                FlSpot(3, 75),
                FlSpot(4, 70),
                FlSpot(5, 85),
                FlSpot(6, 80),
              ],
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(
                        alpha:
                            theme.brightness == Brightness.light ? 0.3 : 0.5),
                    const Color(0xFF3B82F6).withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Daily Summary Card ──────────────────────────────────────
Widget _buildDaySummaryCard(_DailySummary summary, ThemeData theme) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: theme.dividerColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.light ? 0.02 : 0.12),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // Emoji
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: summary.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            summary.emoji,
            style: const TextStyle(
              fontSize: 24,
              fontFamilyFallback: [
                'Apple Color Emoji',
                'Segoe UI Emoji',
                'Noto Color Emoji',
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Date + Emotion label
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.day,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                summary.emotionLabel,
                style: AppTextStyles.caption.copyWith(
                  color: summary.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Score badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: summary.color.withValues(
                alpha: theme.brightness == Brightness.light ? 0.1 : 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                '${summary.score}%',
                style: AppTextStyles.label.copyWith(
                  color: summary.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ── Mock Daily Summaries ────────────────────────────────────────
class _DailySummary {
  final String day;
  final String emoji;
  final String emotionLabel;
  final int score;
  final Color color;

  const _DailySummary({
    required this.day,
    required this.emoji,
    required this.emotionLabel,
    required this.score,
    required this.color,
  });
}

const List<_DailySummary> _dailySummaries = [
  _DailySummary(
    day: 'الإثنين ١٧ فبراير',
    emoji: '😊',
    emotionLabel: 'سعيد - يوم ممتاز',
    score: 90,
    color: Color(0xFF22C55E),
  ),
  _DailySummary(
    day: 'الأحد ١٦ فبراير',
    emoji: '😌',
    emotionLabel: 'هادئ - يوم جيد',
    score: 75,
    color: AppColors.primary,
  ),
  _DailySummary(
    day: 'السبت ١٥ فبراير',
    emoji: '😊',
    emotionLabel: 'سعيد - نشاط عالي',
    score: 85,
    color: Color(0xFF22C55E),
  ),
  _DailySummary(
    day: 'الجمعة ١٤ فبراير',
    emoji: '😢',
    emotionLabel: 'حزين - يوم صعب',
    score: 35,
    color: AppColors.destructive,
  ),
  _DailySummary(
    day: 'الخميس ١٣ فبراير',
    emoji: '😊',
    emotionLabel: 'سعيد - تحسن ملحوظ',
    score: 88,
    color: Color(0xFF22C55E),
  ),
];
