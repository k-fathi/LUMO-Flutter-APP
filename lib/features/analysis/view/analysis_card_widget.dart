import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/enums/child_state.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/child_analysis_model.dart';

/// AnalysisCardWidget - Matches React AnalysisScreen card pattern
///
/// React: p-6 rounded-3xl shadow-md border-[#E3F2FD]
/// - Date: text-sm text-[#2196F3] mb-3
/// - Title: text-xl text-[#1565C0] mb-6
/// - Chart + results row (recharts PieChart donut)
/// - Results: Circle bullets (fill-[#ec4899] for checked, text-[#cbd5e1] for unchecked)
class AnalysisCardWidget extends StatelessWidget {
  final ChildAnalysisModel analysis;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const AnalysisCardWidget({
    super.key,
    required this.analysis,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    // React: p-6 rounded-3xl shadow-md border-[#E3F2FD]
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // rounded-3xl
          border: Border.all(color: const Color(0xFFE3F2FD)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // React: text-sm text-[#2196F3] mb-3
            Text(
              'التاريخ: ${DateFormatter.formatDate(analysis.date)}',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 12),

            // React: text-xl text-[#1565C0] mb-6
            Text(
              analysis.childName,
              style: AppTextStyles.h3.copyWith(
                color: const Color(0xFF1565C0),
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 24),

            // Chart + Results row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pie chart area - React: w-28 h-28 relative (recharts PieChart donut)
                SizedBox(
                  width: 112,
                  height: 112,
                  child: CustomPaint(
                    painter: _PieChartPainter(
                      states: analysis.states,
                      currentState: analysis.currentState,
                    ),
                    child: Center(
                      child: Text(
                        '${analysis.states.where((s) => s.isCurrent).length * 20}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Results list - React: flex-1 space-y-2
                Expanded(
                  child: Column(
                    children: analysis.states.map((state) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            // React: Circle w-4 h-4 fill or outline
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: state.isCurrent
                                    ? const Color(0xFFEC4899) // fill-[#ec4899]
                                    : Colors.transparent,
                                border: Border.all(
                                  color: state.isCurrent
                                      ? const Color(0xFFEC4899)
                                      : const Color(
                                          0xFFCBD5E1), // text-[#cbd5e1]
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // React: text-[#64748b]
                            Text(
                              state.label,
                              style: AppTextStyles.body.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            // Doctor info
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.medical_services_outlined,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  'د. ${analysis.doctorName}',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),

            // Notes
            if (analysis.hasNotes) ...[
              const SizedBox(height: 12),
              Text(
                analysis.notes!,
                style: AppTextStyles.body.copyWith(
                  color: const Color(0xFF64748B),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Actions
            if (showActions && (onEdit != null || onDelete != null)) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE3F2FD)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('تعديل'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                        ),
                      ),
                    if (onEdit != null && onDelete != null)
                      const SizedBox(width: 8),
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outlined, size: 18),
                        label: const Text('حذف'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// CustomPainter for the donut pie chart - matches React recharts PieChart
/// Colors: [#ec4899, #2196f3, #ffc107, #4caf50, #ff5722]
class _PieChartPainter extends CustomPainter {
  final List<AnalysisStateModel> states;
  final ChildState currentState;

  static const List<Color> _colors = [
    Color(0xFFEC4899), // pink - sad/current
    Color(0xFF2196F3), // blue - neutral
    Color(0xFFFFC107), // amber - scared
    Color(0xFF4CAF50), // green - happy
    Color(0xFFFF5722), // orange - angry
  ];

  const _PieChartPainter({required this.states, required this.currentState});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.55; // donut hole

    final total = states.length.toDouble();
    if (total == 0) return;

    double startAngle = -pi / 2; // start from top

    for (int i = 0; i < states.length; i++) {
      final sweepAngle = (2 * pi) / total;
      final color = _colors[i % _colors.length];
      final isActive = states[i].isCurrent;

      final paint = Paint()
        ..color = isActive ? color : color.withOpacity(0.25)
        ..style = PaintingStyle.fill;

      // Draw donut segment
      final path = Path();
      path.moveTo(
        center.dx + innerRadius * cos(startAngle),
        center.dy + innerRadius * sin(startAngle),
      );
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius - 4),
        startAngle,
        sweepAngle - 0.04,
        false,
      );
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle + sweepAngle - 0.04,
        -(sweepAngle - 0.04),
        false,
      );
      path.close();
      canvas.drawPath(path, paint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.states != states ||
        oldDelegate.currentState != currentState;
  }
}
