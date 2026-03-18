import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/community_header.dart';
import '../widgets/quick_post_widget.dart';
import '../widgets/post_card.dart';
import '../view_model/community_view_model.dart';
import 'posts_feed_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../l10n/app_localizations.dart';

/// CommunityScreen (Home) - Figma Screen 6
///
/// Assembly:
/// - Sticky CommunityHeader
/// - QuickPostWidget
/// - ListView of PostCards with mock data
/// - BG: #F8FAFC (light grey-blue)
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    // Start fetching data immediately on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CommunityViewModel>().fetchPosts();
      }
    });
  }

  Future<void> _handleRefresh() async {
    final viewModel = context.read<CommunityViewModel>();
    await Future.wait([
      viewModel.loadHomeFeed(),
      viewModel.loadFollowingFeed(),
      viewModel.loadMyPosts(),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // ── Sticky Header ─────────────────────────────────
              const CommunityHeader(),

              // ── Tab Bar ───────────────────────────────────────
              TabBar(
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.textTheme.bodySmall?.color,
                indicatorColor: theme.colorScheme.primary,
                tabs: [
                  Tab(text: l10n.explore),
                  Tab(text: l10n.following),
                ],
              ),

              // ── Scrollable Feed ───────────────────────────────
              Expanded(
                child: TabBarView(
                  children: [
                    const _CommunityFeedWrapper(),
                    RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: Consumer<CommunityViewModel>(
                        builder: (context, viewModel, child) => PostsFeedWidget(
                          customPosts: viewModel.followingPosts,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityFeedWrapper extends StatelessWidget {
  const _CommunityFeedWrapper();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<CommunityViewModel>().loadHomeFeed();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: QuickPostWidget(),
          ),
          Consumer<CommunityViewModel>(
            builder: (context, viewModel, child) {
              final posts = viewModel.posts;
              
              // Show shimmer if loading OR if not yet initialized (first load)
              if ((viewModel.isLoading || !viewModel.isInitialized) && posts.isEmpty) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: ShimmerCard(),
                    ),
                    childCount: 3,
                  ),
                );
              }

              if (viewModel.errorMessage != null && posts.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => viewModel.loadHomeFeed(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (posts.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.article_outlined,
                    title: 'لا توجد منشورات بعد',
                    message: 'كن أول من ينشر في المجتمع',
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => PostCard(post: posts[index]),
                  childCount: posts.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
