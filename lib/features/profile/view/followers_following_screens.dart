import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class FollowersScreen extends StatefulWidget {
  const FollowersScreen({super.key});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final List<bool> _isFollowing = List.generate(10, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المتابعون')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) => ListTile(
          leading: const CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, color: AppColors.primary)),
          title: Text('مستخدم ${index + 1}', style: AppTextStyles.body),
          subtitle: const Text('مهتم بصحة الطفل'),
          trailing: ElevatedButton(
            onPressed: () {
              setState(() {
                _isFollowing[index] = !_isFollowing[index];
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFollowing[index]
                      ? 'تتابع الآن مستخدم ${index + 1}'
                      : 'تم إلغاء المتابعة'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFollowing[index]
                  ? AppColors.mutedForeground
                  : AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 32),
            ),
            child: Text(_isFollowing[index] ? 'متابَع' : 'متابعة'),
          ),
        ),
      ),
    );
  }
}

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  late List<bool> _following;

  @override
  void initState() {
    super.initState();
    _following = List.generate(8, (_) => true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أتابعهم')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) => ListTile(
          leading: const CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, color: AppColors.primary)),
          title: Text('طبيب ${index + 1}', style: AppTextStyles.body),
          subtitle: const Text('أخصائي أطفال'),
          trailing: OutlinedButton(
            onPressed: () {
              setState(() {
                _following[index] = !_following[index];
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_following[index]
                      ? 'تتابع الآن طبيب ${index + 1}'
                      : 'تم إلغاء المتابعة'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Text(_following[index] ? 'إلغاء المتابعة' : 'متابعة'),
          ),
        ),
      ),
    );
  }
}
