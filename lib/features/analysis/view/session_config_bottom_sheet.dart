import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';

class SessionConfigBottomSheet extends StatefulWidget {
  final void Function(double gamesDuration, double storiesDuration) onSubmit;

  const SessionConfigBottomSheet({super.key, required this.onSubmit});

  /// Presents the Session Configuration Form as a Modal Bottom Sheet
  static void show(BuildContext context,
      {required void Function(double gamesDuration, double storiesDuration)
          onSubmit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SessionConfigBottomSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<SessionConfigBottomSheet> createState() =>
      _SessionConfigBottomSheetState();
}

class _SessionConfigBottomSheetState extends State<SessionConfigBottomSheet> {
  // Config Durations Default to 10 minutes, ranging 5 - 30.
  double _gamesDuration = 10.0;
  double _storiesDuration = 10.0;
  bool _isSubmitting = false;

  void _handleSubmit() {
    setState(() => _isSubmitting = true);

    // Simulate network delay for premium feel
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      Navigator.pop(context); // Close BottomSheet

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال إعدادات الجلسة للروبوت بنجاح',
              style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Trigger the mock flow upstream
      widget.onSubmit(_gamesDuration, _storiesDuration);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              const Icon(
                Icons.play_circle_fill_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'إعداد الجلسة للروبوت',
                  style: AppTextStyles.h3,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.muted.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Games Duration Slider
          _buildSliderSection(
            title: 'مدة الألعاب (بالدقائق)',
            value: _gamesDuration,
            icon: Icons.videogame_asset_rounded,
            onChanged: (val) {
              setState(() => _gamesDuration = val);
            },
          ),

          const SizedBox(height: 24),

          // Stories Duration Slider
          _buildSliderSection(
            title: 'مدة القصص التفاعلية (بالدقائق)',
            value: _storiesDuration,
            icon: Icons.menu_book_rounded,
            onChanged: (val) {
              setState(() => _storiesDuration = val);
            },
          ),

          const SizedBox(height: 40),

          // Submit Button
          AppButton(
            text: 'بدء الجلسة',
            onPressed: _handleSubmit,
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection({
    required String title,
    required double value,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.label),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${value.toInt()} دقيقة',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
            trackHeight: 6.0,
            valueIndicatorTextStyle: const TextStyle(
              fontFamily: 'Cairo', // Ensure RTL font renders numbers well
              color: Colors.white,
            ),
          ),
          child: Slider(
            value: value,
            min: 5,
            max: 30,
            divisions: 25, // 1 minute increments between 5 and 30
            label: '${value.toInt()}',
            onChanged: onChanged,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('5', style: TextStyle(color: AppColors.mutedForeground)),
              Text('30', style: TextStyle(color: AppColors.mutedForeground)),
            ],
          ),
        )
      ],
    );
  }
}
