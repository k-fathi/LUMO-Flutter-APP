import 'package:flutter/material.dart';

import '../../../core/enums/child_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class CreateAnalysisDialog extends StatefulWidget {
  final String childName;
  final Function(ChildState state, String notes) onSubmit;

  const CreateAnalysisDialog({
    super.key,
    required this.childName,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required String childName,
    required Function(ChildState state, String notes) onSubmit,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CreateAnalysisDialog(
        childName: childName,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<CreateAnalysisDialog> createState() => _CreateAnalysisDialogState();
}

class _CreateAnalysisDialogState extends State<CreateAnalysisDialog> {
  final _notesController = TextEditingController();
  ChildState _selectedState = ChildState.good;
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    try {
      await widget.onSubmit(_selectedState, _notesController.text.trim());
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.analytics_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'تحليل جديد',
                      style: AppTextStyles.h3,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'للطفل: ${widget.childName}',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'الحالة الصحية',
                style: AppTextStyles.label,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ChildState.values.map((state) {
                  final isSelected = _selectedState == state;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedState = state);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? state.color.withOpacity(0.2)
                            : AppColors.muted.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? state.color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            state.icon,
                            size: 20,
                            color: isSelected
                                ? state.color
                                : AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state.displayName,
                            style: AppTextStyles.body.copyWith(
                              color: isSelected
                                  ? state.color
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _notesController,
                label: 'ملاحظات (اختياري)',
                hint: 'أضف ملاحظاتك هنا...',
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'حفظ التحليل',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
