import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

import '../view/notifications_screen.dart';

/// CommunityHeader - Figma Screen 6 Spec
///
/// Title: "Community" (المجتمع)
/// Action: Search Button (Circular gradient background)
/// Style: White BG + Border bottom
class CommunityHeader extends StatelessWidget {
  final VoidCallback? onSearch;

  const CommunityHeader({super.key, this.onSearch});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            'المجتمع',
            style: AppTextStyles.h1.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),

          // Notifications Button
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.notifications_none_rounded,
                color: theme.iconTheme.color,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
