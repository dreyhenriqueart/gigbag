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

class _BagMonthSection {
  _BagMonthSection(this.label);

  final String label;
  final List<GigEvent> events = [];
}

class BagsScreen extends StatefulWidget {
  const BagsScreen({super.key});

  @override
  State<BagsScreen> createState() => _BagsScreenState();
}

class _BagsScreenState extends State<BagsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GigbagStore>();
    final events = store.events.toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    final filtered = _query.trim().isEmpty
        ? events
        : events
            .where((e) => e.title.toLowerCase().contains(_query.toLowerCase().trim()))
            .toList();

    final sortedFiltered = [...filtered]..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    final now = DateTime.now();
    final nextBagId = sortedFiltered.where((e) => !e.startsAt.isBefore(now)).firstOrNull?.id;

    final sections = <_BagMonthSection>[];
    for (final e in sortedFiltered) {
      final lbl = _monthLabel(e.startsAt);
      if (sections.isEmpty || sections.last.label != lbl) {
        final sec = _BagMonthSection(lbl);
        sec.events.add(e);
        sections.add(sec);
      } else {
        sections.last.events.add(e);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
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
                centerTitle: const Text('Minhas bags'),
                trailing: PillIconButton(
                  icon: Icons.notifications_none_rounded,
                  iconColor: AppColors.textPrimary,
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: AppLayout.screenGap),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenHorizontal),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar gig bag',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(height: AppLayout.screenGap),
              if (sections.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(
                    child: Text(
                      'Nenhuma bag encontrada.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var gi = 0; gi < sections.length; gi++) ...[
                        if (gi != 0) const SizedBox(height: AppLayout.bagsMonthCardsGap),
                        Text(
                          sections[gi].label,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppLayout.bagsMonthCardsGap),
                        for (final e in sections[gi].events)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GigCard(
                              title: e.title,
                              subtitle: _compactDate(e.startsAt),
                              isNext: e.id == nextBagId,
                              trailingText: e.id == nextBagId ? 'próx' : null,
                              onTap: () => _openEvent(context, e),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEvent(BuildContext context, GigEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
    );
  }

  String _monthLabel(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month) return _labelThisMonth();
    return _monthName(dt.month);
  }

  String _labelThisMonth() => 'Este mês';

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

  String _monthName(int m) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[(m - 1).clamp(0, 11)];
  }
}
