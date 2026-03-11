import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../l10n/app_localizations.dart';
import '../models/mock_child_data.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditChildProfileScreen extends StatefulWidget {
  final MockChildData childData;

  const EditChildProfileScreen({
    super.key,
    this.childData = defaultMockChild,
  });

  @override
  State<EditChildProfileScreen> createState() => _EditChildProfileScreenState();
}

class _EditChildProfileScreenState extends State<EditChildProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _conditionController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  File? _childImage;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.childData.name);
    _ageController =
        TextEditingController(text: widget.childData.age.toString());
    _conditionController = TextEditingController(
        text: widget.childData.conditionKey == 'conditionAutism'
            ? 'طيف التوحد'
            : widget.childData.conditionKey);
    _bloodTypeController =
        TextEditingController(text: widget.childData.bloodType);
    _weightController =
        TextEditingController(text: widget.childData.weight.toString());
    _heightController =
        TextEditingController(text: widget.childData.height.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _conditionController.dispose();
    _bloodTypeController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _childImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل اختيار الصورة: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: l10n.editChildInfo,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? theme.dividerColor
                            : const Color(0xFFE3F2FD),
                        width: 4,
                      ),
                    ),
                    child: AvatarWidget(
                      imageUrl: widget.childData.photoUrl,
                      imageFile: _childImage,
                      name: _nameController.text.isNotEmpty
                          ? _nameController.text
                          : 'طفل',
                      size: 100,
                      fallbackIcon: Icons.child_care_rounded,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildFormField(
              theme,
              label: 'اسم الطفل',
              icon: Icons.person_outline,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            _buildFormField(
              theme,
              label: 'العمر',
              icon: Icons.calendar_today_outlined,
              controller: _ageController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildFormField(
              theme,
              label: 'الحالة',
              icon: Icons.medical_information_outlined,
              controller: _conditionController,
            ),
            const SizedBox(height: 16),
            _buildFormField(
              theme,
              label: 'فصيلة الدم',
              icon: Icons.bloodtype_outlined,
              controller: _bloodTypeController,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    theme,
                    label: 'الوزن (كجم)',
                    icon: Icons.monitor_weight_outlined,
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFormField(
                    theme,
                    label: 'الطول (سم)',
                    icon: Icons.height_outlined,
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Mock save behavior
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'حفظ التعديلات',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
    ThemeData theme, {
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.5),
          ),
        ),
        filled: true,
        fillColor: theme.cardColor,
      ),
    );
  }
}
