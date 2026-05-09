import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PillIconButton extends StatelessWidget {
  const PillIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.textSecondary,
          size: 18,
        ),
      ),
    );
  }
}

