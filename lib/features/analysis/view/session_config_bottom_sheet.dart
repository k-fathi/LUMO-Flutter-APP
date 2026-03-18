import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../session/view_model/session_view_model.dart';
import '../../session/models/session_part.dart';
import 'package:provider/provider.dart';

class SessionConfigBottomSheet extends StatefulWidget {
  final int receiverId;
  final void Function(List<SessionPart> parts)? onSubmit;

  const SessionConfigBottomSheet({
    super.key,
    required this.receiverId,
    this.onSubmit,
  });

  static void show(
    BuildContext context, {
    required int receiverId,
    void Function(List<SessionPart> parts)? onSubmit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SessionConfigBottomSheet(
        receiverId: receiverId,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<SessionConfigBottomSheet> createState() => _SessionConfigBottomSheetState();
}

class _SessionConfigBottomSheetState extends State<SessionConfigBottomSheet> {
  final List<SessionPart> _tempParts = [];

  void _addPart() async {
    final result = await showDialog<SessionPart>(
      context: context,
      builder: (context) => const _AddPartDialog(),
    );

    if (result != null) {
      setState(() {
        _tempParts.add(result);
      });
    }
  }

  void _handleSubmit() async {
    if (_tempParts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة جزء واحد على الأقل')),
      );
      return;
    }

    final viewModel = context.read<SessionViewModel>();
    await viewModel.startSession(
      receiverId: widget.receiverId,
      parts: _tempParts,
    );

    if (mounted) {
      if (viewModel.errorMessage == null) {
        widget.onSubmit?.call(_tempParts);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage!),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
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
              const Icon(Icons.playlist_add_rounded, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text('بناء تسلسل الجلسة', style: AppTextStyles.h3),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Parts List
          Flexible(
            child: _tempParts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _tempParts.length,
                    itemBuilder: (context, index) {
                      final part = _tempParts[index];
                      return _buildPartItem(part, index);
                    },
                  ),
          ),

          const SizedBox(height: 24),

          // Add Part Button
          OutlinedButton.icon(
            onPressed: _addPart,
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة جزء جديد للجلسة', style: TextStyle(fontFamily: 'Cairo')),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 24),

          // Start Button
          AppButton(
            text: 'بدء الجلسة الآن',
            onPressed: _handleSubmit,
            isLoading: context.watch<SessionViewModel>().isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.layers_clear_outlined, size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'لا يوجد أجزاء مضافة بعد',
            style: AppTextStyles.body.copyWith(color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _buildPartItem(SessionPart part, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(part.typeLabel, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                Text('${part.durationMinutes} دقيقة', style: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedForeground)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _tempParts.removeAt(index)),
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.destructive),
          ),
        ],
      ),
    );
  }
}

class _AddPartDialog extends StatefulWidget {
  const _AddPartDialog();

  @override
  State<_AddPartDialog> createState() => _AddPartDialogState();
}

class _AddPartDialogState extends State<_AddPartDialog> {
  String _selectedType = 'games';
  int _selectedDuration = 10;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة جزء للجلسة', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Cairo')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: const InputDecoration(labelText: 'النوع', labelStyle: TextStyle(fontFamily: 'Cairo')),
            items: const [
              DropdownMenuItem(value: 'games', child: Text('ألعاب', style: TextStyle(fontFamily: 'Cairo'))),
              DropdownMenuItem(value: 'stories', child: Text('قصص', style: TextStyle(fontFamily: 'Cairo'))),
              DropdownMenuItem(value: 'education', child: Text('تعليم', style: TextStyle(fontFamily: 'Cairo'))),
            ],
            onChanged: (val) => setState(() => _selectedType = val!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedDuration,
            decoration: const InputDecoration(labelText: 'المدة (بالدقائق)', labelStyle: TextStyle(fontFamily: 'Cairo')),
            items: [5, 10, 15, 20, 30].map((d) => DropdownMenuItem(value: d, child: Text('$d دقيقة', style: const TextStyle(fontFamily: 'Cairo')))).toList(),
            onChanged: (val) => setState(() => _selectedDuration = val!),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, SessionPart(type: _selectedType, durationMinutes: _selectedDuration)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
