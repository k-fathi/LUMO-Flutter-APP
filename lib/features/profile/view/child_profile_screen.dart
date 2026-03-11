import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../l10n/app_localizations.dart';
import '../models/mock_child_data.dart';

class ChildProfileScreen extends StatelessWidget {
  final MockChildData childData;

  const ChildProfileScreen({
    super.key,
    this.childData = defaultMockChild,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Translation lookup for condition based on key. We have only 'conditionAutism' right now.
    String translatedCondition = childData.conditionKey == 'conditionAutism'
        ? l10n.conditionAutism
        : childData.conditionKey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: l10n.childInfo,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: AvatarWidget(
                imageUrl: childData.photoUrl,
                name: childData.name,
                size: 100,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              childData.name,
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              l10n.childAgeValue(childData.age),
              style:
                  AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                      context,
                      l10n.childCondition,
                      translatedCondition,
                      Icons.medical_information_outlined,
                      Colors.redAccent),
                  const Divider(height: 30),
                  _buildInfoRow(context, l10n.bloodType, childData.bloodType,
                      Icons.bloodtype_outlined, Colors.red),
                  const Divider(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                            context,
                            l10n.weight,
                            '${childData.weight} ${l10n.kg}',
                            Icons.monitor_weight_outlined,
                            Colors.blue),
                      ),
                      Container(
                          width: 1, height: 40, color: theme.dividerColor),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildInfoRow(
                              context,
                              l10n.height,
                              '${childData.height} ${l10n.cm}',
                              Icons.height_outlined,
                              Colors.green),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/edit-child-profile');
                },
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.editChildInfo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.cardColor,
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
