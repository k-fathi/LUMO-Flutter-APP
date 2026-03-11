import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

// --- Data Models for Visual Summary ---
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

class SessionDetailPlaceholderScreen extends StatefulWidget {
  const SessionDetailPlaceholderScreen({super.key});

  @override
  State<SessionDetailPlaceholderScreen> createState() =>
      _SessionDetailPlaceholderScreenState();
}

class _SessionDetailPlaceholderScreenState
    extends State<SessionDetailPlaceholderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _chartType = 0; // 0 = Bars, 1 = Pie

  // Mock Session Data for Visuals
  late final SessionAnalysisData _sessionData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Derived from Gamified Screen
    _sessionData = SessionAnalysisData(
      id: 'session_1',
      title: 'جلسة #1 - تقييم الروبوت التلقائي',
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
        EmotionData('surprise', '😲', 'متفاجئ', 0.20, const Color(0xFFA855F7)),
      ],
      focusedPercentage: 0.85,
      notFocusedPercentage: 0.15,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _sessionData.title,
          style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جاري تحميل التقرير...',
                      style: TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.mutedForeground,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppTextStyles.body,
          tabs: const [
            Tab(text: "الملخص البصري", icon: Icon(Icons.analytics_outlined)),
            Tab(
                text: "التقرير الطبي",
                icon: Icon(Icons.medical_information_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Visual Summary
          _buildVisualSummaryTab(),

          // TAB 2: Clinical Report
          _buildClinicalReportTab(),
        ],
      ),
    );
  }

  // ================= TAB 1: VISUAL SUMMARY =================

  Widget _buildVisualSummaryTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFocusAnalysisBar(),
          const SizedBox(height: 24),
          _buildEmotionChart(),
        ],
      ),
    );
  }

  Widget _buildFocusAnalysisBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.remove_red_eye_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'تحليل التركيز',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(_sessionData.focusedPercentage * 100).toInt()}%',
                    style: AppTextStyles.h1.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  Text(
                    'مُركز',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: const [
                      Color(0xFF10B981),
                      Color(0xFF94A3B8),
                    ],
                    stops: [
                      _sessionData.focusedPercentage,
                      _sessionData.focusedPercentage,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: const Icon(Icons.psychology_rounded,
                    size: 100, color: Colors.white),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(_sessionData.notFocusedPercentage * 100).toInt()}%',
                    style: AppTextStyles.h1.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    'مشتت',
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

  Widget _buildEmotionChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.insights_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'توزيع المشاعر',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                backgroundColor: const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_chartType == 0) _buildBarChart(),
          if (_chartType == 1) _buildPieChart(),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Column(
      children: _sessionData.emotionDistribution.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(e.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(e.label, style: AppTextStyles.bodySmall),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: e.percentage,
                    backgroundColor: e.color.withValues(alpha: 0.1),
                    color: e.color,
                    minHeight: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text('${(e.percentage * 100).toInt()}%',
                    style: AppTextStyles.caption
                        .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.end),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPieChart() {
    final emotions = _sessionData.emotionDistribution;
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
                    topEmotion != null ? topEmotion.label : 'تفاعل',
                    style: AppTextStyles.caption
                        .copyWith(fontWeight: FontWeight.bold),
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
                      badgeWidget: isTop
                          ? Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 4)
                                ],
                              ),
                              child: Text(e.emoji,
                                  style: const TextStyle(fontSize: 16)),
                            )
                          : null,
                      badgePositionPercentageOffset: 0.9,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: emotions.map((e) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration:
                      BoxDecoration(color: e.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  e.label,
                  style: AppTextStyles.caption
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // ================= TAB 2: CLINICAL REPORT =================

  Widget _buildClinicalReportTab() {
    final topEmotion = _sessionData.emotionDistribution
        .reduce((a, b) => a.percentage > b.percentage ? a : b);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClinicalCard(
            title: "الحالة المزاجية الغالبة",
            modelName: "Emotional Intelligence Model",
            content:
                "الحالة المزاجية الغالبة للمريض هي ${topEmotion.label} بنسبة ${(topEmotion.percentage * 100).toInt()}%.",
            icon: Icons.sentiment_satisfied_alt_rounded,
            color: const Color(0xFF22C55E), // Green
          ),
          const SizedBox(height: 16),
          _buildClinicalCard(
            title: "التدفق الصوتي والقصص",
            modelName: "Educational Voice Flow Model",
            content:
                "تفاعل المريض صوتياً وأجاب على أسئلة القصة التفاعلية بشكل صحيح (True).",
            icon: Icons.record_voice_over_rounded,
            color: const Color(0xFF3B82F6), // Blue
          ),
          const SizedBox(height: 16),
          _buildClinicalCard(
            title: "التواصل البصري",
            modelName: "Eye Tracking Model",
            content:
                "التواصل البصري مستقر. تمركزت نقاط النظر نحو الروبوت بنسبة ${(_sessionData.focusedPercentage * 100).toInt()}%.",
            icon: Icons.visibility_rounded,
            color: const Color(0xFFF59E0B), // Amber
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalCard({
    required String title,
    required String modelName,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Column
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          // Content Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  modelName,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  content,
                  style: AppTextStyles.body.copyWith(
                    height: 1.6,
                    color: const Color(0xFF334155), // Slate-700
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
