import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/community_header.dart';
import '../widgets/quick_post_widget.dart';
import '../widgets/post_card.dart';
import '../view_model/community_view_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';


class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Start fetching data immediately on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        context.read<CommunityViewModel>().fetchPosts(
          userId: authProvider.currentUser?.id
        );
      }
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    
    // If switched to "Following" tab (index 1), refresh it
    if (_tabController.index == 1) {
      context.read<CommunityViewModel>().loadFollowingFeed();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Sticky Header ─────────────────────────────────
            const CommunityHeader(),

            // ── Tab Bar ───────────────────────────────────────
            TabBar(
              controller: _tabController,
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
                controller: _tabController,
                children: [
                  const _CommunityFeedWrapper(isExplore: true),
                  const _CommunityFeedWrapper(isExplore: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityFeedWrapper extends StatelessWidget {
  final bool isExplore;
  const _CommunityFeedWrapper({required this.isExplore});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if (isExplore) {
          await context.read<CommunityViewModel>().loadExploreFeed();
        } else {
          await context.read<CommunityViewModel>().loadFollowingFeed();
        }
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: QuickPostWidget(),
          ),
          Consumer<CommunityViewModel>(
            builder: (context, viewModel, child) {
              final posts = isExplore ? viewModel.explorePosts : viewModel.followingPosts;
              
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
                            onPressed: () => isExplore ? viewModel.loadExploreFeed() : viewModel.loadFollowingFeed(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (posts.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: isExplore ? Icons.article_outlined : Icons.people_outline_rounded,
                    title: isExplore ? 'لا توجد منشورات بعد' : 'لا تتابع أحداً بعد',
                    message: isExplore ? 'كن أول من ينشر في المجتمع' : 'تابع بعض المستخدمين لرؤية منشوراتهم هنا',
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
