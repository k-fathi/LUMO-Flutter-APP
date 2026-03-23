import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../view_model/analysis_view_model.dart';
import 'analysis_card_widget.dart';

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
                    onTap: () {
                      // ✅ إصلاح: شاشة تفاصيل التحليل للـ parent
                      // مش شاشة الدكتور (doctorPatientDetail)
                      // ✅ إصلاح: RouteNames بدل hardcoded string
                      Navigator.pushNamed(
                        context,
                        RouteNames.sessionDetailPlaceholder,
                        arguments: {
                          'analysisId': analysis.id,
                          'parentId': analysis.parentId,
                          'parentName': analysis.parentName,
                          'childName': analysis.childName,
                        },
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
