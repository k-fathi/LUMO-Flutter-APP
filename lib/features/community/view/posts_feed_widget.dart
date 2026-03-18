import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../data/models/post_model.dart';
import '../view_model/community_view_model.dart';
import '../widgets/post_card.dart';

/// Posts Feed Widget - Complete social feed with full integration
class PostsFeedWidget extends StatelessWidget {
  final List<PostModel>? customPosts;
  const PostsFeedWidget({super.key, this.customPosts});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CommunityViewModel, AuthProvider>(
      builder: (context, viewModel, authProvider, child) {
        final currentPosts = customPosts ?? viewModel.posts;

        // Loading state
        if ((viewModel.isLoading || !viewModel.isInitialized) && currentPosts.isEmpty) {
          return ListView.builder(
            itemCount: 5,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ShimmerCard(),
            ),
          );
        }

        // Error state
        if (viewModel.errorMessage != null && currentPosts.isEmpty) {
          return Center(
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
          );
        }

        // Empty state
        if (currentPosts.isEmpty) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: const EmptyState(
                    icon: Icons.article_outlined,
                    title: 'لا توجد منشورات بعد',
                    message: 'كن أول من ينشر في المجتمع',
                  ),
                ),
              );
            },
          );
        }

        // Posts list
        return ListView.builder(
          itemCount: currentPosts.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final post = currentPosts[index];
            return PostCard(post: post);
          },
        );
      },
    );
  }
}
