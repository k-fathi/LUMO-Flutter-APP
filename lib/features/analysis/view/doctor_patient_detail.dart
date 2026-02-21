import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/providers/auth_provider.dart';
import '../view_model/analysis_view_model.dart';
import 'analysis_card_widget.dart';
import 'create_analysis_dialog.dart';
import 'edit_analysis_dialog.dart';

class DoctorPatientDetail extends StatefulWidget {
  final String parentId;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(title: widget.childName),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          CreateAnalysisDialog.show(
            context,
            childName: widget.childName,
            onSubmit: (state, notes) async {
              final authProvider = context.read<AuthProvider>();
              final currentUser = authProvider.currentUser;
              if (currentUser == null) return;

              await context.read<AnalysisViewModel>().createAnalysis(
                    parentId: widget.parentId,
                    parentName: widget.parentName,
                    childName: widget.childName,
                    doctorId: currentUser.id,
                    doctorName: currentUser.name,
                    currentState: state,
                    notes: notes.isEmpty ? null : notes,
                  );

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إنشاء التحليل بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('تحليل جديد'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<AnalysisViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.analyses.isEmpty) {
            return const EmptyState(
              icon: Icons.analytics_outlined,
              title: 'لا توجد تحليلات بعد',
              message: 'قم بإضافة أول تحليل للطفل',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.analyses.length,
            itemBuilder: (context, index) {
              final analysis = viewModel.analyses[index];
              return AnalysisCardWidget(
                analysis: analysis,
                showActions: true,
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
        },
      ),
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
