import 'package:flutter/material.dart';

import '../../domain/equipment.dart';
import '../theme/app_colors.dart';
import 'fixed_height_card.dart';

/// Card de linha de equipamento alinhado à tela Inventário (altura 88, padding, tipografia).
class EquipmentListCard extends StatelessWidget {
  const EquipmentListCard({
    super.key,
    required this.equipment,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  final Equipment equipment;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final category = (equipment.category ?? '').trim();
    final hasCategory = category.isNotEmpty;

    return FixedHeightCard(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  equipment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (hasCategory) ...[
                const SizedBox(width: 10),
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
