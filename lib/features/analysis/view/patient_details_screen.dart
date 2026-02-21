import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'parent_analysis_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String? patientId;
  final String patientName;
  final String patientAge;
  final String? patientPhotoUrl;

  const PatientDetailsScreen({
    super.key,
    this.patientId,
    required this.patientName,
    required this.patientAge,
    this.patientPhotoUrl,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(widget.patientName),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'remove') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('إزالة المريض'),
                      content: Text(
                          'هل تريد إزالة ${widget.patientName} من قائمة مرضاك؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx); // Dialog
                            Navigator.pop(context); // Screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم إزالة المريض')),
                            );
                          },
                          child: const Text('إزالة',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'remove',
                  child:
                      Text('إزالة المريض', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'نظرة عامة'),
              Tab(text: 'التقرير الطبي'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const _OverviewTab(),
            PatientAnalysisView(
              patientId: widget.patientId,
              patientName: widget.patientName,
              patientAge: widget.patientAge,
              patientPhotoUrl: widget.patientPhotoUrl,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatefulWidget {
  const _OverviewTab();

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  final List<String> _notes = [
    'تحسن ملحوظ في التواصل البصري',
    'يحتاج إلى متابعة تمارين النطق',
  ];

  final List<Map<String, String>> _visits = [
    {'date': '2023-10-15', 'type': 'جلسة استشارة', 'status': 'مكتملة'},
    {'date': '2023-10-01', 'type': 'تقييم مبدئي', 'status': 'مكتملة'},
  ];

  void _addNote() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة ملاحظة'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'اكتب الملاحظة هنا...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _notes.insert(0, controller.text);
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _addVisit() async {
    final nameController = TextEditingController(text: 'جلسة متابعة');

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('جدولة جلسة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الجلسة / النوع',
                hintText: 'مثلاً: نطق، تواصل بصري...',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('متابعة'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 16, minute: 0),
      );

      if (pickedTime != null) {
        setState(() {
          _visits.insert(0, {
            'date': '${pickedDate.year}-${pickedDate.month}-${pickedDate.day}',
            'time': pickedTime.format(context),
            'type': nameController.text.isNotEmpty
                ? nameController.text
                : 'جلسة متابعة',
            'status': 'مجدولة',
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم جدولة الجلسة بنجاح')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Static Cards
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  context,
                  'تفاعل الروبوت',
                  '85% - ممتاز',
                  Icons.smart_toy_outlined,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCard(
                  context,
                  'الجلسات',
                  '24 جلسة مكتملة',
                  Icons.check_circle_outline_rounded,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCard(
            context,
            'الجلسة القادمة',
            'الثلاثاء، الساعة 4:00 عصراً مع د. سارة',
            Icons.calendar_month_rounded,
            AppColors.primary,
          ),
          const SizedBox(height: 24),

          // Notes Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الملاحظات', style: AppTextStyles.h3),
              IconButton(
                onPressed: _addNote,
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_notes.isEmpty)
            const Text('لا توجد ملاحظات')
          else
            ..._notes.map((note) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Text(note,
                      style: AppTextStyles.body.copyWith(
                        color: theme.textTheme.bodyLarge?.color,
                      )),
                )),

          const SizedBox(height: 24),

          // Visits Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('سجل الزيارات', style: AppTextStyles.h3),
              IconButton(
                onPressed: _addVisit,
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._visits.map((visit) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                          alpha: theme.brightness == Brightness.light
                              ? 0.02
                              : 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(
                                alpha: theme.brightness == Brightness.light
                                    ? 0.1
                                    : 0.22),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            visit['status'] == 'مكتملة'
                                ? Icons.check_circle_rounded
                                : Icons.calendar_today_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visit['type']!,
                              style: AppTextStyles.label.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${visit['date']!}${visit.containsKey('time') ? ' • ${visit['time']}' : ''}',
                              style: AppTextStyles.caption.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: visit['status'] == 'مكتملة'
                            ? Colors.green.withValues(
                                alpha: theme.brightness == Brightness.light
                                    ? 0.1
                                    : 0.2)
                            : Colors.orange.withValues(
                                alpha: theme.brightness == Brightness.light
                                    ? 0.1
                                    : 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        visit['status']!,
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: visit['status'] == 'مكتملة'
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color,
      {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(
                  alpha: theme.brightness == Brightness.light ? 0.04 : 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(
                    alpha: theme.brightness == Brightness.light ? 0.1 : 0.22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: theme.textTheme.bodyLarge?.color,
                      )),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_left_rounded,
                  color: AppColors.mutedForeground.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
