import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/elevated_card.dart';
import '../view_model/home_view_model.dart';
import '../../community/view/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<HomeViewModel>();
    _viewModel.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'مرحباً، ${currentUser.name}',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _viewModel.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              _buildWelcomeCard(currentUser.name, currentUser.role.isDoctor),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(context, currentUser.role.isDoctor),
              const SizedBox(height: 24),

              // Stats Section
              Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return _buildStatsSection(
                    context,
                    viewModel,
                    currentUser.role.isDoctor,
                  );
                },
              ),
              const SizedBox(height: 24),

              // Recent Activity
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String name, bool isDoctor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.primary.withOpacity(0.3)
                : Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDoctor
                      ? Icons.medical_services_rounded
                      : Icons.child_care_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isDoctor ? 'طبيب' : 'ولي أمر',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'مرحباً بعودتك!',
            style: AppTextStyles.h3.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isDoctor ? 'جاهز لمساعدة مرضاك اليوم' : 'متابعة صحة طفلك بسهولة',
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDoctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: AppTextStyles.h2,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.add_rounded,
                title: isDoctor ? 'تحليل جديد' : 'منشور جديد',
                color: AppColors.primary,
                onTap: () {
                  if (isDoctor) {
                    Navigator.pushNamed(context, RouteNames.doctorPatients);
                  } else {
                    Navigator.pushNamed(context, RouteNames.createPost);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.chat_outlined,
                title: 'محادثة جديدة',
                color: AppColors.secondary,
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.chatsList);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.smart_toy_outlined,
                title: 'المساعد الذكي',
                color: AppColors.accent,
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.aiChat);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: isDoctor
                    ? Icons.people_outline
                    : Icons.medical_services_outlined,
                title: isDoctor ? 'مرضاي' : 'طلب طبيب',
                color: AppColors.success,
                onTap: () {
                  if (isDoctor) {
                    Navigator.pushNamed(context, RouteNames.doctorPatients);
                  } else {
                    Navigator.pushNamed(context, RouteNames.doctorRequest);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    HomeViewModel viewModel,
    bool isDoctor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات',
          style: AppTextStyles.h2,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.article_outlined,
                title: 'المنشورات',
                value: viewModel.postsCount.toString(),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.analytics_outlined,
                title: isDoctor ? 'المرضى' : 'التحليلات',
                value: viewModel.analysesCount.toString(),
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.chat_outlined,
                title: 'المحادثات',
                value: viewModel.chatsCount.toString(),
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.people_outline,
                title: 'المتابعون',
                value: viewModel.followersCount.toString(),
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return ElevatedCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: AppTextStyles.h2.copyWith(
                  color: color,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'النشاط الأخير',
              style: AppTextStyles.h2,
            ),
            TextButton(
              onPressed: () {
                // TODO: View all activity
              },
              child: Text(
                'عرض الكل',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.article_outlined,
                title: 'منشور جديد في المجتمع',
                time: 'منذ ساعتين',
                color: AppColors.primary,
              ),
              const Divider(height: 24),
              _buildActivityItem(
                icon: Icons.chat_outlined,
                title: 'رسالة جديدة من الطبيب',
                time: 'منذ 3 ساعات',
                color: AppColors.secondary,
              ),
              const Divider(height: 24),
              _buildActivityItem(
                icon: Icons.analytics_outlined,
                title: 'تحليل جديد متاح',
                time: 'منذ يوم',
                color: AppColors.success,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppColors.mutedForeground,
        ),
      ],
    );
  }
}
