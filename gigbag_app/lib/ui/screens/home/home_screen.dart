import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/gig_event.dart';
import '../../../state/gigbag_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';
import '../../widgets/gig_card.dart';
import '../../widgets/pill_icon_button.dart';
import '../../widgets/standard_top_bar.dart';
import '../equipment/inventory_screen.dart';
import '../events/event_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigateToBags});

  /// Quantidade máxima de bags próximas mostradas na Home (sem limite no cadastro).
  static const int _maxBagsShownOnHome = 5;

  final VoidCallback onNavigateToBags;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GigbagStore>();
    final now = DateTime.now();
    final events = store.events.toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final upcoming = events.where((e) => !e.startsAt.isBefore(now)).toList();
    final upcomingOnHome = upcoming.take(_maxBagsShownOnHome).toList();
    final next = upcomingOnHome.firstOrNull;
    final rest = upcomingOnHome.skip(1).toList();

    final dateLabel = '${_weekdayShort(now)}, ${now.day}';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StandardTopBarRow(
              leading: PillIconButton(
                icon: Icons.grid_view_rounded,
                iconColor: AppColors.textPrimary,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const InventoryScreen()),
                  );
                },
              ),
              centerTitle: Text(dateLabel),
              trailing: PillIconButton(
                icon: Icons.notifications_none_rounded,
                iconColor: AppColors.textPrimary,
                onPressed: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppLayout.screenGap),
                  Text(
                    'Olá, Usuário',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600, // SemiBold
                          fontSize: 20,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Organizando sua gig!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: AppLayout.screenGap),
                  InkWell(
                    onTap: onNavigateToBags,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Gig Bags',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppLayout.contentLabelToCardGap),
                  if (next != null)
                    GigCard(
                      title: next.title,
                      subtitle: _compactDate(next.startsAt),
                      isNext: true,
                      trailingText: 'próx',
                      onTap: () => _openEvent(context, next),
                    )
                  else
                    const Text(
                      'Sem próximos eventos.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  const SizedBox(height: 12),
                  ...rest.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GigCard(
                        title: e.title,
                        subtitle: _compactDate(e.startsAt),
                        onTap: () => _openEvent(context, e),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEvent(BuildContext context, GigEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
    );
  }

  String _weekdayShort(DateTime dt) {
    const map = {
      DateTime.monday: 'Seg',
      DateTime.tuesday: 'Ter',
      DateTime.wednesday: 'Qua',
      DateTime.thursday: 'Qui',
      DateTime.friday: 'Sex',
      DateTime.saturday: 'Sáb',
      DateTime.sunday: 'Dom',
    };
    return map[dt.weekday] ?? '—';
  }

  String _compactDate(DateTime dt) {
    final month = _monthShort(dt.month);
    return '${dt.day.toString().padLeft(2, '0')} • $month';
  }

  String _monthShort(int m) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return months[(m - 1).clamp(0, 11)];
  }
}

