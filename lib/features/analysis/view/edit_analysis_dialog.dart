import 'package:flutter/material.dart';

import '../../../core/enums/child_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../data/models/child_analysis_model.dart';

class EditAnalysisDialog extends StatefulWidget {
  final ChildAnalysisModel analysis;
  final Function(ChildState state, String notes) onSubmit;

  const EditAnalysisDialog({
    super.key,
    required this.analysis,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required ChildAnalysisModel analysis,
    required Function(ChildState state, String notes) onSubmit,
  }) {
    return showDialog(
      context: context,
      builder: (context) => EditAnalysisDialog(
        analysis: analysis,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<EditAnalysisDialog> createState() => _EditAnalysisDialogState();
}

class _EditAnalysisDialogState extends State<EditAnalysisDialog> {
  late TextEditingController _notesController;
  late ChildState _selectedState;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.analysis.notes);
    _selectedState = widget.analysis.currentState;
  }

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
                    Icons.edit_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'تعديل التحليل',
                      style: AppTextStyles.h3,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
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
                label: 'ملاحظات',
                hint: 'أضف ملاحظاتك هنا...',
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'حفظ التعديلات',
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
