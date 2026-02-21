import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../data/models/post_model.dart';
import '../view_model/community_view_model.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _contentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء كتابة محتوى المنشور'),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final viewModel = context.read<CommunityViewModel>();
    final success = await viewModel.updatePost(
      postId: widget.post.id,
      content: _contentController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث المنشور بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'فشل تحديث المنشور'),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'تعديل المنشور'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AppTextField(
                controller: _contentController,
                hint: 'ماذا تريد أن تشارك؟',
                maxLines: null,
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'حفظ التعديلات',
              onPressed: _handleUpdate,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
