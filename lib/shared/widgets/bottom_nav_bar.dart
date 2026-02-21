import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/enums/user_role.dart';

/// Bottom Nav Bar - Matches React BottomNav
///
/// React layout:
/// - fixed bottom-0 bg-white border-t border-[#E3F2FD] shadow-lg
/// - Active tab: gradient icon bg (rounded-xl) + text-[#2196F3] label
/// - Inactive tab: bg-transparent icon + text-[#64748b] label
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final UserRole userRole;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    // Tab definitions matching React
    final tabs = [
      const _TabData(Icons.home_outlined, Icons.home_rounded, 'الرئيسية'),
      _TabData(Icons.analytics_outlined, Icons.analytics_rounded,
          userRole.isDoctor ? 'مرضاي' : 'التحليل'),
      const _TabData(Icons.chat_outlined, Icons.chat_rounded, 'الدردشة'),
      const _TabData(
          Icons.smart_toy_outlined, Icons.smart_toy_rounded, 'المساعد الذكي'),
      const _TabData(Icons.person_outline, Icons.person_rounded, 'الملف'),
    ];

    // React: bg-white border-t border-[#E3F2FD] shadow-lg
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE3F2FD)),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          // React: px-2 py-3
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isActive = currentIndex == index;

              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // React: p-2 rounded-xl transition-all
                    // Active: bg-gradient-to-r from-[#2196F3] to-[#1565C0] shadow-md
                    // Inactive: bg-transparent
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: isActive ? AppColors.primaryGradient : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFF2196F3).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        isActive ? tab.activeIcon : tab.icon,
                        size: 20,
                        // React: active=text-white, inactive=text-[#64748b]
                        color:
                            isActive ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // React: text-xs
                    // Active: text-[#2196F3], Inactive: text-[#64748b]
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive
                            ? const Color(0xFF2196F3)
                            : const Color(0xFF64748B),
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _TabData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabData(this.icon, this.activeIcon, this.label);
}
