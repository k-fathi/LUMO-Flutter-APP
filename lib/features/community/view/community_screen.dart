import 'package:flutter/material.dart';

import '../widgets/community_header.dart';
import '../widgets/post_card.dart';
import '../widgets/quick_post_widget.dart';
import '../../../shared/providers/community_provider.dart';
import 'package:provider/provider.dart';
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
  bool _isLoadingMore = false;
  bool _isInitialLoading = false;

  @override
  void initState() {
    super.initState();

    // Simulate initial loading
    _isInitialLoading = true;
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    });
  }

  void _onScrollThresholdReached() {
    if (!_isLoadingMore) {
      // Trigger load more
      setState(() {
        _isLoadingMore = true;
      });
      // Simulate network delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
            // Append more items to list here in real implementation
          });
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = context.watch<CommunityProvider>();
    final posts = communityProvider.posts;
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // ── Sticky Header ─────────────────────────────────
              const CommunityHeader(),

              // ── Tab Bar ───────────────────────────────────────
              TabBar(
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor:
                    Theme.of(context).textTheme.bodySmall?.color,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: [
                  Tab(text: l10n.explore),
                  Tab(text: l10n.following),
                ],
              ),

              // ── Scrollable Feed ───────────────────────────────
              Expanded(
                child: TabBarView(
                  children: [
                    _buildFeedTab(posts),
                    _buildFeedTab(posts.reversed
                        .toList()), // Mock sorting for Following tab
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedTab(List posts) {
    if (_isInitialLoading) return _buildShimmerLoading(context);
    if (posts.isEmpty) return _buildEmptyState(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!scrollInfo.metrics.outOfRange &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
          _onScrollThresholdReached();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: posts.length + 1 + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const QuickPostWidget();
          }
          if (index == posts.length + 1 && _isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return PostCard(post: posts[index - 1]);
        },
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 180,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2)), // Basic placeholder for shimmer
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined,
              size: 80, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            'لا توجد منشورات حتى الآن',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'كن أول من يشارك قصة أو نصيحة في المجتمع!',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        ],
      ),
    );
  }
}
