import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/community_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../data/repositories/community_repository.dart';

class CreatePostScreen extends StatefulWidget {
  final Map<String, dynamic>? initialPost;

  const CreatePostScreen({super.key, this.initialPost});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialPost != null) {
      _controller.text = widget.initialPost!['content'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title:
            Text(widget.initialPost != null ? 'تعديل المنشور' : 'إضافة منشور'),
        actions: [
          TextButton(
            onPressed: _isUploading
                ? null
                : () async {
                    if (_controller.text.isNotEmpty) {
                      setState(() => _isUploading = true);

                      try {
                        final userProvider = context.read<UserProvider>();
                        final userName = userProvider.user?.name ?? 'المستخدم';
                        final userRole =
                            userProvider.user?.role.name ?? 'parent';
                        final userId = userProvider.user?.id ?? 'mock_user_id';

                        String? uploadedImageUrl;
                        if (_selectedImage != null) {
                          final communityRepo = getIt<CommunityRepository>();
                          final postId =
                              DateTime.now().millisecondsSinceEpoch.toString();
                          // Upload to Firebase Storage
                          uploadedImageUrl =
                              await communityRepo.uploadPostImage(
                                  userId, postId, _selectedImage!.path);
                        }

                        if (context.mounted) {
                          if (widget.initialPost != null) {
                            final postId = widget.initialPost!['id'];
                            context.read<CommunityProvider>().updatePost(
                                  postId: postId,
                                  content: _controller.text,
                                  imageUrl:
                                      uploadedImageUrl ?? _selectedImage?.path,
                                );
                          } else {
                            context.read<CommunityProvider>().addPost(
                                  authorName: userName,
                                  authorRole: userRole,
                                  content: _controller.text,
                                  imageUrl:
                                      uploadedImageUrl ?? _selectedImage?.path,
                                );
                          }

                          Navigator.pop(context, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(widget.initialPost != null
                                    ? 'تم تعديل المنشور بنجاح!'
                                    : 'تم النشر بنجاح!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('حدث خطأ أثناء رفع الصورة')),
                          );
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => _isUploading = false);
                        }
                      }
                    }
                  },
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.initialPost != null ? 'حفظ' : 'نشر',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.secondary,
                  child: Builder(
                    builder: (context) {
                      final userName =
                          context.read<UserProvider>().user?.name ?? 'المستخدم';
                      return Text(
                        userName.isNotEmpty ? userName[0] : 'م',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final userName =
                            context.read<UserProvider>().user?.name ??
                                'المستخدم';
                        return Text(
                          userName,
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 12, color: theme.hintColor),
                          const SizedBox(width: 4),
                          Builder(
                            builder: (context) {
                              final role = context
                                      .read<UserProvider>()
                                      .user
                                      ?.role
                                      .name ??
                                  'parent';
                              return Text(
                                role == 'doctor' ? 'طبيب' : 'ولي أمر',
                                style: TextStyle(
                                    fontSize: 10, color: theme.hintColor),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'بم تفكر؟',
                  hintStyle: TextStyle(color: theme.hintColor),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_selectedImage != null)
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () => setState(() => _selectedImage = null),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Divider(color: theme.dividerColor),
            Row(
              children: [
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image, color: Colors.green),
                ),
                IconButton(
                  onPressed: _pickCamera,
                  icon: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
