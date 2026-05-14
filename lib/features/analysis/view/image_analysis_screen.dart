import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/emotion_analysis_model.dart';
import '../view_model/image_analysis_view_model.dart';

/// Full-screen UI for capturing / selecting a child's photo and sending it
/// to Carol's Emotion & Gaze Analysis API (:8001/analyze_image).
///
/// Consumed via [ChangeNotifierProvider<ImageAnalysisViewModel>] — register
/// it in the widget tree before pushing this route.
class ImageAnalysisScreen extends StatelessWidget {
  const ImageAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Consumer<ImageAnalysisViewModel>(
        builder: (context, vm, _) {
          return Stack(
            children: [
              // ── Decorative background blobs ──────────────────────────────
              _BackgroundBlobs(),

              // ── Scrollable content ───────────────────────────────────────
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeaderCard(),
                      const SizedBox(height: 20),
                      _ImagePickerCard(vm: vm),
                      const SizedBox(height: 20),
                      if (vm.errorMessage != null)
                        _ErrorBanner(
                          message: vm.errorMessage!,
                          onDismiss: vm.clearError,
                        ),
                      if (vm.hasResult) ...[
                        const SizedBox(height: 4),
                        _ResultsCard(result: vm.result!),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Floating action area ─────────────────────────────────────
              Positioned(
                left: 20,
                right: 20,
                bottom: 24,
                child: _AnalyzeButton(vm: vm),
              ),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
              )
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.chevron_left_rounded,
                color: Color(0xFF475569), size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Text(
        'تحليل مشاعر الطفل',
        style: AppTextStyles.label.copyWith(
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ─── Background ───────────────────────────────────────────────────────────────

class _BackgroundBlobs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF818CF8).withValues(alpha: 0.25),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -60,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34D399).withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.8), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.face_retouching_natural_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تحليل المشاعر والتركيز',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'التقط صورة للطفل لتحليل مشاعره واتجاه نظره باستخدام الذكاء الاصطناعي',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Image Picker Card ────────────────────────────────────────────────────────

class _ImagePickerCard extends StatelessWidget {
  final ImageAnalysisViewModel vm;

  const _ImagePickerCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image preview / placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: vm.hasImage
                    ? const Color(0xFF6366F1).withValues(alpha: 0.6)
                    : const Color(0xFFE2E8F0),
                width: 2,
              ),
            ),
            child: vm.hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        vm.selectedImage!,
                        fit: BoxFit.cover,
                      ),
                      // Loading overlay
                      if (vm.isLoading)
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.35),
                            child: const Center(
                              child: _LoadingIndicator(),
                            ),
                          ),
                        ),
                      // Clear button
                      if (!vm.isLoading)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: vm.clearResults,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : _EmptyImagePlaceholder(),
          ),
        ),
        const SizedBox(height: 16),
        // Picker action buttons
        Row(
          children: [
            Expanded(
              child: _PickerButton(
                icon: Icons.camera_alt_rounded,
                label: 'الكاميرا',
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                onTap: vm.isLoading ? null : vm.pickImageFromCamera,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PickerButton(
                icon: Icons.photo_library_rounded,
                label: 'المعرض',
                gradient: const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                ),
                onTap: vm.isLoading ? null : vm.pickImageFromGallery,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_a_photo_rounded,
            size: 36,
            color: Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'اختر صورة للتحليل',
          style: AppTextStyles.label.copyWith(
            color: const Color(0xFF334155),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'التقط صورة أو اختر من المعرض',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const _PickerButton({
    required this.icon,
    required this.label,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Analyze Button ───────────────────────────────────────────────────────────

class _AnalyzeButton extends StatelessWidget {
  final ImageAnalysisViewModel vm;

  const _AnalyzeButton({required this.vm});

  @override
  Widget build(BuildContext context) {
    final canAnalyze = vm.hasImage && !vm.isLoading;

    return GestureDetector(
      onTap: canAnalyze ? vm.analyzeCurrentImage : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 58,
        decoration: BoxDecoration(
          gradient: canAnalyze
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: canAnalyze ? null : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(18),
          boxShadow: canAnalyze
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              : null,
        ),
        child: Center(
          child: vm.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.biotech_rounded,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'تحليل الصورة',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Results Card ─────────────────────────────────────────────────────────────

class _ResultsCard extends StatelessWidget {
  final EmotionAnalysisModel result;

  const _ResultsCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: Color(0xFF6366F1),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'نتائج التحليل',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'مكتمل ✓',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF059669),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 20),

              // ── Emotion row ─────────────────────────────────────────────
              _ResultRow(
                icon: Icons.mood_rounded,
                iconColor: const Color(0xFFF59E0B),
                label: 'المشاعر المكتشفة',
                value: result.emotionAr,
                subtitle: result.emotionConfidence != null
                    ? 'الثقة: ${result.confidencePercent}'
                    : null,
              ),
              const SizedBox(height: 16),

              // ── Confidence bar ──────────────────────────────────────────
              if (result.emotionConfidence != null) ...[
                _ConfidenceBar(
                  label: 'دقة اكتشاف المشاعر',
                  value: result.emotionConfidence!,
                  color: _emotionColor(result.emotion),
                ),
                const SizedBox(height: 16),
              ],

              // ── Gaze row ────────────────────────────────────────────────
              _ResultRow(
                icon: Icons.remove_red_eye_rounded,
                iconColor: const Color(0xFF6366F1),
                label: 'اتجاه النظر',
                value: result.gazeAr,
                subtitle: result.gazeConfidence != null
                    ? 'الثقة: ${(result.gazeConfidence! * 100).toStringAsFixed(1)}%'
                    : null,
              ),
              const SizedBox(height: 16),

              // ── Eye contact ─────────────────────────────────────────────
              _EyeContactBadge(hasContact: result.hasEyeContact),

              // ── Raw dump (debug-friendly collapsible) ───────────────────
              if (result.raw.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 12),
                _RawDataExpansion(raw: result.raw),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _emotionColor(String? emotion) {
    switch ((emotion ?? '').toLowerCase()) {
      case 'happy':
        return const Color(0xFF10B981);
      case 'sad':
        return const Color(0xFF3B82F6);
      case 'angry':
        return const Color(0xFFEF4444);
      case 'neutral':
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xFF6366F1);
    }
  }
}

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? subtitle;

  const _ResultRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: const Color(0xFF0F172A),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ConfidenceBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.mutedForeground),
            ),
            Text(
              '${(value * 100).toStringAsFixed(1)}%',
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _EyeContactBadge extends StatelessWidget {
  final bool hasContact;

  const _EyeContactBadge({required this.hasContact});

  @override
  Widget build(BuildContext context) {
    final color = hasContact ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final label =
        hasContact ? 'يوجد تواصل بصري ✓' : 'لا يوجد تواصل بصري';
    final bgColor = hasContact
        ? const Color(0xFF10B981).withValues(alpha: 0.1)
        : const Color(0xFFF59E0B).withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasContact
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _RawDataExpansion extends StatelessWidget {
  final Map<String, dynamic> raw;

  const _RawDataExpansion({required this.raw});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          'البيانات الخام',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.mutedForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: raw.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Text(
                  '${e.key}: ',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
                Expanded(
                  child: Text(
                    '${e.value}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedForeground,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.destructive.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.destructive.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.destructive, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.destructive,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded,
                color: AppColors.destructive, size: 18),
          ),
        ],
      ),
    );
  }
}

// ─── Loading Indicator ────────────────────────────────────────────────────────

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'جارٍ التحليل...',
          style: AppTextStyles.label.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
