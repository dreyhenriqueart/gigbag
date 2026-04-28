import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../screen_map.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.active,
    required this.onSelect,
  });

  final AppTab active;
  final void Function(AppTab tab) onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 44),
        decoration: const BoxDecoration(color: AppColors.bg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavIcon(
              icon: Icons.home_rounded,
              isActive: active == AppTab.home,
              onTap: () => onSelect(AppTab.home),
            ),
            _NavIcon(
              icon: Icons.folder_rounded,
              isActive: active == AppTab.bags,
              onTap: () => onSelect(AppTab.bags),
            ),
            _NavIcon(
              icon: Icons.calendar_month_rounded,
              isActive: active == AppTab.agenda,
              onTap: () => onSelect(AppTab.agenda),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.accentTeal : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 46,
        height: 46,
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

