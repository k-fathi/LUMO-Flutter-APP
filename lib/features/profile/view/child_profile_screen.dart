import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../l10n/app_localizations.dart';
import '../models/mock_child_data.dart';
import '../../../data/models/parent_model.dart';
import '../../../shared/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ChildProfileScreen extends StatelessWidget {
  final MockChildData? childData;

  const ChildProfileScreen({
    super.key,
    this.childData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().currentUser;

    String name = childData?.name ?? defaultMockChild.name;
    int age = childData?.age ?? defaultMockChild.age;
    String? photoUrl = childData?.photoUrl ?? defaultMockChild.photoUrl;
    String conditionKey =
        childData?.conditionKey ?? defaultMockChild.conditionKey;

    if (user is ParentModel) {
      name = user.childName;
      age = user.childAge;
      photoUrl = user.childPhotoUrl;
      conditionKey = user.childMedicalCondition ?? conditionKey;
    }

    // Translation lookup for condition based on key.
    String translatedCondition =
        conditionKey == 'conditionAutism' ? l10n.conditionAutism : conditionKey;

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
                imageUrl: photoUrl,
                name: name,
                size: 100,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              l10n.childAgeValue(age),
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
