import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/session_analysis_model.dart';

class AnalysisDetailScreen extends StatelessWidget {
  final SessionAnalysisModel session;
  const AnalysisDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final focus = session.averageFocus ?? session.focusedPercentage;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(session.title, style: AppTextStyles.h2),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نسبة التركيز', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text('${(focus * 100).toInt()}%',
                style: AppTextStyles.h1.copyWith(color: AppColors.primary)),
            const SizedBox(height: 24),
            Text('الملخص', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(session.summary.isEmpty ? 'لا يوجد ملخص' : session.summary,
                style: AppTextStyles.body),
            const SizedBox(height: 24),
            Text('التحليلات الخام', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  session.analytics?.toString() ?? 'لا توجد تحليلات إضافية',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
