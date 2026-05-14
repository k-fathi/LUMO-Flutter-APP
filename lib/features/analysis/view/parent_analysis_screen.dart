import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../view_model/analysis_view_model.dart';
import '../../session/view_model/session_view_model.dart';
import 'analysis_card_widget.dart';
import 'session_detail_placeholder_screen.dart';

class ParentAnalysisScreen extends StatefulWidget {
  const ParentAnalysisScreen({super.key});

  @override
  State<ParentAnalysisScreen> createState() => _ParentAnalysisScreenState();
}

class _ParentAnalysisScreenState extends State<ParentAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // ✅ إصلاح: Future<void> بدل void عشان onRefresh يشتغل صح
  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser != null) {
      await context
          .read<AnalysisViewModel>()
          .loadParentAnalyses(currentUser.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('تحليلات الطفل'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<AnalysisViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.analyses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null && viewModel.analyses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.analyses.isEmpty) {
            return const EmptyState(
              icon: Icons.analytics_outlined,
              title: 'لا توجد تحليلات بعد',
              message: 'ستظهر هنا تقارير الطبيب فور إتمامها',
            );
          }

          // ✅ إصلاح: onRefresh بيـawait _loadData فعلاً
          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.analyses.length,
              itemBuilder: (context, index) {
                final analysis = viewModel.analyses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AnalysisCardWidget(
                    analysis: analysis,
                    onTap: () async {
                      final sessionId = int.tryParse(analysis.id);
                      if (sessionId == null) return;

                      // Show loading overlay
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      );

                      final sessionViewModel = context.read<SessionViewModel>();
                      await sessionViewModel.loadSessionDetails(sessionId);

                      if (!context.mounted) return;
                      Navigator.pop(context); // Remove loading dialog

                      if (sessionViewModel.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              sessionViewModel.errorMessage!,
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                            backgroundColor: AppColors.destructive,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      final displayIndex = viewModel.analyses.length - index;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: sessionViewModel,
                            child: SessionDetailPlaceholderScreen(displayIndex: displayIndex),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
