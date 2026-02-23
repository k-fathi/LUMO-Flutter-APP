import 'dart:io';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final String? name;
  final double size;
  final VoidCallback? onTap;
  final bool showOnlineIndicator;
  final bool isOnline;
  final IconData? fallbackIcon;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.name,
    this.size = 40,
    this.onTap,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor,
              border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
              image: imageFile != null
                  ? DecorationImage(
                      image: FileImage(imageFile!),
                      fit: BoxFit.cover,
                    )
                  : (imageUrl != null && imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: imageUrl!.startsWith('http')
                              ? NetworkImage(imageUrl!) as ImageProvider
                              : FileImage(File(imageUrl!)),
                          fit: BoxFit.cover,
                        )
                      : null),
            ),
            child:
                (imageFile == null && (imageUrl == null || imageUrl!.isEmpty))
                    ? Center(
                        child: Icon(
                          fallbackIcon ?? Icons.person_rounded,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withValues(alpha: 0.5),
                          size: size * 0.5,
                        ),
                      )
                    : null,
          ),
          if (showOnlineIndicator)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.25,
                height: size * 0.25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? AppColors.online : AppColors.offline,
                  border: Border.all(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
