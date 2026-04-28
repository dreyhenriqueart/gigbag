import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Mesmo ponto dos cards de bag (home/bags). Cor costuma ser [AppColors.textSecondary];
/// em seleção (ex.: editor de evento) usa [AppColors.accentTeal].
class GigCardStatusDot extends StatelessWidget {
  const GigCardStatusDot({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class GigCard extends StatelessWidget {
  const GigCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.isNext = false,
    this.trailingText,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isNext;
  final String? trailingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isNext ? AppColors.accentTeal : AppColors.surface2;
    final fg = isNext ? Colors.white : AppColors.textSecondary;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 88, maxHeight: 88),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(color: fg),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: fg),
                          ),
                        ),
                        if (trailingText != null) ...[
                          Text(
                            trailingText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: fg),
                          ),
                          const SizedBox(width: 10),
                        ],
                        GigCardStatusDot(color: fg),
                      ],
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

