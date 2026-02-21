import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/user_chip_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class NewChatDialog extends StatefulWidget {
  final Function(String userId, String userName) onUserSelected;

  const NewChatDialog({
    super.key,
    required this.onUserSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(String userId, String userName) onUserSelected,
  }) {
    return showDialog(
      context: context,
      builder: (context) => NewChatDialog(onUserSelected: onUserSelected),
    );
  }

  @override
  State<NewChatDialog> createState() => _NewChatDialogState();
}

class _NewChatDialogState extends State<NewChatDialog> {
  bool _isLoading = true;
  final List<Map<String, String>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    // TODO: Load users from repository
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _users.addAll([
        {'id': '1', 'name': 'د. أحمد محمد', 'avatar': ''},
        {'id': '2', 'name': 'د. فاطمة علي', 'avatar': ''},
        {'id': '3', 'name': 'ولي أمر - سارة', 'avatar': ''},
      ]);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(
                    Icons.chat_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'محادثة جديدة',
                    style: AppTextStyles.h3,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (_isLoading)
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => const ShimmerListTile(),
                ),
              )
            else if (_users.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('لا يوجد مستخدمون'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return UserChipWidget(
                      name: user['name']!,
                      avatarUrl: user['avatar'],
                      onTap: () {
                        widget.onUserSelected(user['id']!, user['name']!);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
