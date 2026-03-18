import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/providers/patient_provider.dart';
import '../view_model/analysis_view_model.dart';
import '../../session/models/session_part.dart';
import 'analysis_card_widget.dart';
import 'session_config_bottom_sheet.dart';

import 'edit_analysis_dialog.dart';

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

class DoctorPatientDetail extends StatefulWidget {
  final int parentId;
  final String parentName;
  final String childName;

  const DoctorPatientDetail({
    super.key,
    required this.parentId,
    required this.parentName,
    required this.childName,
  });

  @override
  State<DoctorPatientDetail> createState() => _DoctorPatientDetailState();
}

class _DoctorPatientDetailState extends State<DoctorPatientDetail> {
  // New State Variable for the Robot Mock Flow
  bool hasSessionData = false;
  int _selectedSessionIndex = 0; // 0: All Sessions, 1: Session #1

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: widget.childName,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_remove_rounded, color: AppColors.destructive),
            tooltip: 'إلغاء ربط المريض',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).cardColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.destructive.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_remove_rounded,
                            color: AppColors.destructive,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'إلغاء ربط المريض',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'هل أنت متأكد أنك تريد إلغاء ربط المريض ${widget.childName}؟ سيتم إزالته من قائمة مرضاك.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(ctx).textTheme.bodySmall?.color,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'تراجع',
                                  style: TextStyle(
                                    color: Theme.of(ctx).textTheme.bodyLarge?.color,
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  try {
                                    await context.read<PatientProvider>().disconnectPatient(widget.parentId);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('تم إلغاء ربط المريض بنجاح', style: TextStyle(fontFamily: 'Cairo')),
                                          backgroundColor: Colors.green,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      Navigator.pop(context); // Go back to patients list
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(context.read<PatientProvider>().error ?? 'فشل إلغاء الربط', style: const TextStyle(fontFamily: 'Cairo')),
                                          backgroundColor: AppColors.destructive,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.destructive,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'إلغاء الربط',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          SessionConfigBottomSheet.show(
            context,
            receiverId: widget.parentId,
            onSubmit: (List<SessionPart> parts) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جاري بدء الجلسة...', style: TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          );
        },
        icon: const Icon(Icons.timer_rounded),
        label: const Text('إعداد جلسة جديدة',
            style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<AnalysisViewModel>(
        builder: (context, viewModel, child) {
          // If no mock session has occurred and real records are empty, show empty state
          if (!hasSessionData && viewModel.analyses.isEmpty) {
            return const EmptyState(
              icon: Icons.analytics_outlined,
              title: 'لا توجد تحليلات بعد',
              message: 'ستظهر التحليلات هنا فور انتهاء الروبوت من الجلسة',
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Session Selector Header
              if (hasSessionData || viewModel.analyses.isNotEmpty)
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('كل الجلسات',
                              style: TextStyle(fontFamily: 'Cairo')),
                          selected: _selectedSessionIndex == 0,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedSessionIndex = 0);
                            }
                          },
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.2),
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: _selectedSessionIndex == 0
                                ? AppColors.primary
                                : Colors.grey.shade600,
                            fontWeight: _selectedSessionIndex == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          showCheckmark: false,
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('جلسة #1',
                              style: TextStyle(fontFamily: 'Cairo')),
                          selected: _selectedSessionIndex == 1,
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() {
                                _selectedSessionIndex = 1;
                              });
                            }
                          },
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.2),
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: _selectedSessionIndex == 1
                                ? AppColors.primary
                                : Colors.grey.shade600,
                            fontWeight: _selectedSessionIndex == 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          showCheckmark: false,
                        ),
                      ],
                    ),
                  ),
                ),

              // Divider
              Divider(height: 1, color: Colors.grey.shade200),

              // Dynamic Body Target
              Expanded(
                child: _selectedSessionIndex == 0
                    ? _buildAllSessionsList(viewModel)
                    : const _InlineSessionDetails(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllSessionsList(AnalysisViewModel viewModel) {
    // If no real data and no simulated data
    if (viewModel.analyses.isEmpty && !hasSessionData) {
      return const EmptyState(
        icon: Icons.analytics_outlined,
        title: 'لا توجد تحليلات بعد',
        message: 'ستظهر التحليلات هنا فور انتهاء الروبوت من الجلسة',
      );
    }

    // Combine Real Analyses + Front-End Mock (if hasSessionData but no actual analyses yet or we just want to inject it)
    final itemCount = viewModel.analyses.length +
        (hasSessionData && viewModel.analyses.isEmpty ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // If we are showing the mock injected session
        if (hasSessionData && viewModel.analyses.isEmpty && index == 0) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: const Text('جلسة #1',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      fontSize: 16)),
              subtitle: const Text('تقييم الروبوت التلقائي',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 13, fontFamily: 'Cairo')),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('85%',
                    style: TextStyle(
                        color: AppColors.success, fontWeight: FontWeight.bold)),
              ),
              onTap: () {
                setState(() {
                  _selectedSessionIndex = 1;
                });
              },
            ),
          );
        }

        final analysis = viewModel.analyses[
            index - (hasSessionData && viewModel.analyses.isEmpty ? 1 : 0)];
        return AnalysisCardWidget(
          analysis: analysis,
          showActions: true,
          onTap: () {
            setState(() {
              _selectedSessionIndex = 1;
            });
          },
          onEdit: () {
            EditAnalysisDialog.show(
              context,
              analysis: analysis,
              onSubmit: (state, notes) async {
                await viewModel.updateAnalysis(
                  analysisId: analysis.id,
                  currentState: state,
                  notes: notes.isEmpty ? null : notes,
                );

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث التحليل بنجاح'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            );
          },
          onDelete: () {
            _showDeleteDialog(analysis.id);
          },
        );
      },
    );
  }

  void _showDeleteDialog(String analysisId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف التحليل'),
        content: const Text('هل أنت متأكد من حذف هذا التحليل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<AnalysisViewModel>().deleteAnalysis(analysisId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

// ================= THE INLINE TAB CONTROLLER =================

class _InlineSessionDetails extends StatefulWidget {
  const _InlineSessionDetails();

  @override
  State<_InlineSessionDetails> createState() => _InlineSessionDetailsState();
}

class _InlineSessionDetailsState extends State<_InlineSessionDetails>
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
    return Column(
      children: [
        // TabBar Strip
        Container(
          color: Colors.white,
          child: TabBar(
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
                  text: "التقرير السريري",
                  icon: Icon(Icons.medical_information_outlined)),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: Visual Summary
              _buildVisualSummaryTab(),

              // TAB 2: Clinical Report
              _buildClinicalReportTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ================= TAB 1: VISUAL SUMMARY =================

  Widget _buildVisualSummaryTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            "تفاصيل أجزاء الجلسة",
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Part 1: Interactive Games
          _buildSessionPartCard(
            partTitle: "الجزء الأول: الألعاب التفاعلية",
            subTitle: "لعبة تطابق الألوان (Color Matching)",
            performanceText: "حل اللعبة بشكل صحيح (Solved correctly)",
            aiOutputText: "الحالة المزاجية (سعيد)، التركيز (عالي)",
            icon: Icons.extension_rounded,
            themeColor: const Color(0xFF10B981), // Emerald/Green
          ),
          const SizedBox(height: 16),

          // Part 2: Educational Stories
          _buildSessionPartCard(
            partTitle: "الجزء الثاني: القصص التفاعلية",
            subTitle: "قصة تعليمية (Educational Story)",
            performanceText: "استمع للنهاية (Listened to the end)",
            aiOutputText: "الحالة المزاجية (حزين/مشتت)، التركيز (ضعيف)",
            icon: Icons.menu_book_rounded,
            themeColor: const Color(0xFFF59E0B), // Orange/Warning
          ),
          const SizedBox(height: 32),

          // AI Recommendation Card
          _buildAIRecommendationCard(),
        ],
      ),
    );
  }

  Widget _buildSessionPartCard({
    required String partTitle,
    required String subTitle,
    required String performanceText,
    required String aiOutputText,
    required IconData icon,
    required Color themeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: themeColor, size: 28),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partTitle,
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subTitle,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        size: 20, color: AppColors.mutedForeground),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "الأداء: $performanceText",
                        style: AppTextStyles.body.copyWith(
                          color: const Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.analytics_outlined, size: 20, color: themeColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "تحليل الذكاء الاصطناعي: $aiOutputText",
                        style: AppTextStyles.body.copyWith(
                          color: themeColor.withValues(alpha: 0.9),
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildAIRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.1), // Indigo light
            const Color(0xFFA855F7).withValues(alpha: 0.05), // Purple light
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "توصيات المساعد الذكي",
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4338CA), // Indigo prominent
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "بناءً على تحليل بيانات هذه الجلسة والجلسات السابقة، يُظهر الطفل تفاعلاً وتركيزاً ممتازاً أثناء الألعاب البصرية، بينما يقل تركيزه وتتغير حالته المزاجية للحزن أثناء سرد القصص. نوصي بتقليل مدة القصص إلى 5 دقائق وزيادة الألعاب التفاعلية.",
            style: AppTextStyles.body.copyWith(
              height: 1.8,
              fontSize: 15,
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
