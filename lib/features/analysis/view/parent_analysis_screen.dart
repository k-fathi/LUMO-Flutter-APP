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
import '../../../core/router/route_names.dart';

// --- (NEW) Dynamic Data Models for UI ---
class EmotionData {
  final String id;
  final String emoji;
  final String label;
  final double percentage; // 0.0 to 1.0
  final Color color;

  EmotionData(this.id, this.emoji, this.label, this.percentage, this.color);
}

class SessionAnalysisData {
  final String id;
  final String title;
  final String summary;
  final String duration;
  final String engagementLevel;
  final List<String> recommendations;
  final List<EmotionData> emotionDistribution;
  final double focusedPercentage;
  final double notFocusedPercentage;

  SessionAnalysisData({
    required this.id,
    required this.title,
    required this.summary,
    required this.duration,
    required this.engagementLevel,
    required this.recommendations,
    required this.emotionDistribution,
    required this.focusedPercentage,
    required this.notFocusedPercentage,
  });
}
// ----------------------------------------

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
      body: const PatientAnalysisView(),
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
  // Task 2 Toggle
  bool isLinked = true;

  int _selectedSessionIndex = 0;
  DateTimeRange? _selectedDateRange;
  int _chartType = 0; // 0 = Bars, 1 = Pie, 2 = Line

  // --- Dynamic Mock Data ---
  late final SessionAnalysisData _overallData;
  late final List<SessionAnalysisData> _sessionsData;

  @override
  void initState() {
    super.initState();
    _initMockData();
  }

  void _initMockData() {
    _overallData = SessionAnalysisData(
      id: 'overall',
      title: 'كل الجلسات',
      summary:
          'تقدم عام ملحوظ على مدار جميع الجلسات. تحسن في التواصل البصري بنسبة كبيرة وانخفاض في مستويات التوتر.',
      duration: 'إجمالي الساعات: ١٠',
      engagementLevel: 'جيد جداً',
      recommendations: [
        'الاستمرار في تمارين التحدث لمدة ٣٠ دقيقة يومياً',
        'تشجيع الطفل على التعبير عن غضبه بالرسم',
        'زيادة فترات اللعب الاجتماعي مع أقرانه',
      ],
      emotionDistribution: [
        EmotionData('happy', '😊', 'سعيد', 0.25, const Color(0xFF22C55E)),
        EmotionData('calm', '😌', 'هادئ', 0.20, AppColors.primary),
        EmotionData('sad', '😢', 'حزين', 0.15, AppColors.destructive),
        EmotionData('angry', '😠', 'غاضب', 0.10, const Color(0xFFF97316)),
        EmotionData(
            'fear', '😨', 'خائف', 0.15, const Color(0xFF6366F1)), // Indigo
        EmotionData('surprise', '😲', 'متفاجئ', 0.15,
            const Color(0xFFA855F7)), // Purple
      ],
      focusedPercentage: 0.70,
      notFocusedPercentage: 0.30,
    );

    _sessionsData = [
      SessionAnalysisData(
        id: 'session_1',
        title: 'جلسة #1',
        summary:
            'خلال هذه الجلسة، أظهر الطفل تقدماً ملحوظاً في حل الألغاز التعاونية مع الروبوت. وتواصل بصري بنسبة ٧٥٪.',
        duration: '٢٥ دقيقة',
        engagementLevel: 'ممتاز',
        recommendations: [
          'التركيز على مهارات تبادل الأدوار',
          'استخدام الروبوت كمحفز للنطق الوجداني',
        ],
        emotionDistribution: [
          EmotionData('happy', '😊', 'سعيد', 0.35, const Color(0xFF22C55E)),
          EmotionData('calm', '😌', 'هادئ', 0.15, AppColors.primary),
          EmotionData('sad', '😢', 'حزين', 0.15, AppColors.destructive),
          EmotionData('angry', '😠', 'غاضب', 0.05, const Color(0xFFF97316)),
          EmotionData('fear', '😨', 'خائف', 0.10, const Color(0xFF6366F1)),
          EmotionData(
              'surprise', '😲', 'متفاجئ', 0.20, const Color(0xFFA855F7)),
        ],
        focusedPercentage: 0.85,
        notFocusedPercentage: 0.15,
      ),
      SessionAnalysisData(
        id: 'session_2',
        title: 'جلسة #2',
        summary:
            'جلسة تعارف قوية، كان هناك بعض التوتر في البداية ولكن سرعان ما انسجم الطفل مع الألعاب التفاعلية.',
        duration: '٣٠ دقيقة',
        engagementLevel: 'جيد',
        recommendations: [
          'تكثيف ألعاب المطابقة البصرية',
          'تقليل وقت الشاشات غير التفاعلية',
        ],
        emotionDistribution: [
          EmotionData('happy', '😊', 'سعيد', 0.15, const Color(0xFF22C55E)),
          EmotionData('calm', '😌', 'هادئ', 0.25, AppColors.primary),
          EmotionData('sad', '😢', 'حزين', 0.20, AppColors.destructive),
          EmotionData('angry', '😠', 'غاضب', 0.10, const Color(0xFFF97316)),
          EmotionData('fear', '😨', 'خائف', 0.20, const Color(0xFF6366F1)),
          EmotionData(
              'surprise', '😲', 'متفاجئ', 0.10, const Color(0xFFA855F7)),
        ],
        focusedPercentage: 0.60,
        notFocusedPercentage: 0.40,
      ),
      SessionAnalysisData(
        id: 'session_3',
        title: 'جلسة #3',
        summary:
            'تركزت هذه الجلسة على التعبير العاطفي. تفاعل الطفل بشكل جيد مع المؤثرات الصوتية للروبوت.',
        duration: '٢٠ دقيقة',
        engagementLevel: 'مرتفع',
        recommendations: [
          'استخدام كروت المشاعر في المنزل',
          'ممارسة تمارين التنفس عند الغضب',
        ],
        emotionDistribution: [
          EmotionData('happy', '😊', 'سعيد', 0.30, const Color(0xFF22C55E)),
          EmotionData('calm', '😌', 'هادئ', 0.20, AppColors.primary),
          EmotionData('sad', '😢', 'حزين', 0.10, AppColors.destructive),
          EmotionData('angry', '😠', 'غاضب', 0.05, const Color(0xFFF97316)),
          EmotionData('fear', '😨', 'خائف', 0.15, const Color(0xFF6366F1)),
          EmotionData(
              'surprise', '😲', 'متفاجئ', 0.20, const Color(0xFFA855F7)),
        ],
        focusedPercentage: 0.75,
        notFocusedPercentage: 0.25,
      ),
    ];
  }

  SessionAnalysisData get currentData {
    if (_selectedSessionIndex == 0) return _overallData;
    if (_selectedSessionIndex > 0 &&
        _selectedSessionIndex <= _sessionsData.length) {
      return _sessionsData[_selectedSessionIndex - 1];
    }
    return _overallData;
  }

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
        child: !isLinked
            ? _buildNotLinkedState(theme, l10n)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTreatingDoctorCard(theme, l10n),
                  const SizedBox(height: 24),
                  _buildPatientMiniProfile(theme, l10n),
                  const SizedBox(height: 24),
                  _buildOverviewContent(theme, l10n, currentPatient),
                ],
              ),
      ),
    );
  }

  // ── Overview Content ────────────────────────────────────────
  Widget _buildOverviewContent(
      ThemeData theme, AppLocalizations l10n, MockPatient? currentPatient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر الجلسة',
          style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _buildSessionSelector(theme, l10n),
        const SizedBox(height: 24),
        if (_selectedSessionIndex == 0) ...[
          _buildAIProgressReport(l10n, theme),
          const SizedBox(height: 24),
          _buildAnalysisHeader(theme, l10n),
          const SizedBox(height: 16),
          _buildMetricGrid(l10n, theme, currentPatient),
          const SizedBox(height: 32),
          _buildFocusAnalysisBar(l10n, theme),
          const SizedBox(height: 24),
          _buildEmotionChart(l10n, theme),
          const SizedBox(height: 32),
          _buildSectionTitle('توصيات المساعد الذكي'),
          const SizedBox(height: 16),
          _buildRecommendationsList(l10n, theme),
        ] else ...[
          _buildSessionSummary(theme, l10n, _selectedSessionIndex),
          const SizedBox(height: 24),
          _buildFocusAnalysisBar(l10n, theme),
          const SizedBox(height: 24),
          _buildEmotionChart(l10n, theme),
          const SizedBox(height: 24),
          _buildSectionTitle('Session Recommendations'),
          const SizedBox(height: 16),
          _buildRecommendationsList(l10n, theme),
        ],
      ],
    );
  }

  // ── State A: Not Linked ─────────────────────────────────────
  Widget _buildNotLinkedState(ThemeData theme, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Icon(Icons.link_off_rounded, size: 80, color: theme.disabledColor),
        const SizedBox(height: 24),
        Text(
          l10n.notLinkedToDoctor,
          style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'حسابك غير مرتبط بطبيب حالياً. يرجى الانتظار حتى يرسل لك طبيبك المعالج طلب إضافة من خلال العيادة.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.mutedForeground,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── State B: Linked Doctor Card ─────────────────────────────
  Widget _buildTreatingDoctorCard(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.treatingDoctor,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'د. أحمد مجدي',
                      style: AppTextStyles.h3
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    isLinked = true; // Toggle back for testing
                  });
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                tooltip: 'Unlink',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 18, color: AppColors.mutedForeground),
              const SizedBox(width: 8),
              Text(
                '${l10n.clinicLocation}: عيادة الأمل، القاهرة',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.mutedForeground),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.event_outlined,
                  size: 18, color: AppColors.mutedForeground),
              const SizedBox(width: 8),
              Text(
                '${l10n.nextSession}: الأربعاء، ٤:٠٠ م',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.mutedForeground),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  RouteNames.chatRoom,
                  arguments: {
                    'chatRoomId': 'doc_chat_${widget.patientId ?? '1'}',
                    'otherUserName': 'د. أحمد مجدي',
                    'otherUserAvatar': 'https://i.pravatar.cc/150?img=11',
                  },
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: Text(l10n.sendMessage),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
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
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
                alpha: theme.brightness == Brightness.light ? 0.08 : 0.2),
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
                        color: AppColors.primary.withValues(
                            alpha: theme.brightness == Brightness.light
                                ? 0.1
                                : 0.2),
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
                        color: Colors.green.withValues(
                            alpha: theme.brightness == Brightness.light
                                ? 0.1
                                : 0.2),
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
    final List<String> sessions = [
      _overallData.title,
      ..._sessionsData.map((e) => e.title)
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
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
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
                  color: Colors.white.withValues(alpha: 0.2),
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
              color: Colors.white.withValues(alpha: 0.95),
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
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.light
                ? Colors.black.withValues(alpha: 0.03)
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(
                      alpha: theme.brightness == Brightness.light ? 0.1 : 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
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
    final suggestions = currentData.recommendations;

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
                currentData.title,
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
            currentData.summary,
            style:
                AppTextStyles.body.copyWith(color: Colors.white, height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSessionStat('مدة الجلسة', currentData.duration),
              const SizedBox(width: 24),
              _buildSessionStat('مستوى التفاعل', currentData.engagementLevel),
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
        ],
      ),
    );
  }

  String _getLocalizedEmotion(String id, AppLocalizations l10n) {
    switch (id) {
      case 'happy':
        return l10n.happy;
      case 'calm':
        return l10n.calm;
      case 'sad':
        return l10n.sad;
      case 'angry':
        return l10n.angry;
      case 'fear':
        return l10n.fear;
      case 'surprise':
        return l10n.surprise;
      case 'neutral':
        return l10n.neutral;
      default:
        return id;
    }
  }

  // ── Focus Analysis Chart Card ──────────────────────────────────────
  Widget _buildFocusAnalysisBar(AppLocalizations l10n, ThemeData theme) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF10B981),
                      Color(0xFF059669)
                    ], // Medical Green Gradient
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.remove_red_eye_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.focusAnalysis,
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.headlineSmall?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Custom Brain Focus Indicator
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left: Focused Percentage text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(currentData.focusedPercentage * 100).toInt()}%',
                    style: AppTextStyles.h1.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                      color: const Color(0xFF10B981), // Teal/Green
                    ),
                  ),
                  Text(
                    l10n.focused,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),

              // Center: ShaderMask Brain Graphic
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: const [
                      Color(0xFF10B981), // Filled Teal
                      Color(0xFF94A3B8), // Unfilled Slate Gray
                    ],
                    stops: [
                      currentData.focusedPercentage,
                      currentData.focusedPercentage,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: const Icon(
                  Icons.psychology_rounded,
                  size: 100,
                  color: Colors.white,
                ),
              ),

              // Right: Not Focused Percentage text
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(currentData.notFocusedPercentage * 100).toInt()}%',
                    style: AppTextStyles.h1.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                      color: const Color(0xFF94A3B8), // Slate Gray
                    ),
                  ),
                  Text(
                    l10n.notFocused,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(AppLocalizations l10n) {
    return Column(
      children: currentData.emotionDistribution
          .map((e) => EmotionBar(
                emoji: e.emoji,
                label: _getLocalizedEmotion(e.id, l10n),
                percentage: e.percentage,
                color: e.color,
              ))
          .toList(),
    );
  }

  Widget _buildPieChart(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final emotions = currentData.emotionDistribution;

    EmotionData? topEmotion;
    if (emotions.isNotEmpty) {
      topEmotion =
          emotions.reduce((a, b) => a.percentage > b.percentage ? a : b);
    }

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
                    topEmotion != null
                        ? '${(topEmotion.percentage * 100).toInt()}٪'
                        : '--٪',
                    style: AppTextStyles.h1.copyWith(
                      color: topEmotion?.color ?? AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                    ),
                  ),
                  Text(
                    topEmotion != null
                        ? _getLocalizedEmotion(topEmotion.id, l10n)
                        : 'تفاعل',
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
                  sections: emotions.map((e) {
                    final isTop = e == topEmotion;
                    return PieChartSectionData(
                      color: e.color,
                      value: e.percentage * 100,
                      title: '',
                      radius: isTop ? 25.0 : 20.0,
                      badgeWidget:
                          isTop ? _buildPieBadge(e.emoji, theme) : null,
                      badgePositionPercentageOffset: 0.9,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildChartLegend(theme, l10n),
      ],
    );
  }

  Widget _buildChartLegend(ThemeData theme, AppLocalizations l10n) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: currentData.emotionDistribution
          .map((e) => _buildLegendItem(theme,
              color: e.color, label: _getLocalizedEmotion(e.id, l10n)))
          .toList(),
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
}
