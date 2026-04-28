import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../domain/gig_event.dart';
import '../../../state/gigbag_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';
import '../../widgets/gig_card.dart';
import '../../widgets/standard_top_bar.dart';
import '../events/event_detail_screen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  static const TextStyle _calDayText = TextStyle(
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _todayDayText = TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GigbagStore>();
    final events = store.events;

    List<GigEvent> eventsForDay(DateTime day) {
      return events
          .where((e) => isSameDay(e.startsAt, day))
          .toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    }

    final selected = _selectedDay ?? _focusedDay;
    final dayEvents = eventsForDay(selected);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StandardTopBarRow(
                leading: SizedBox(width: 48, height: 48),
                centerTitle: Text('Agenda'),
                trailing: SizedBox(width: 48, height: 48),
              ),
              const SizedBox(height: AppLayout.screenGap),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenHorizontal),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TableCalendar<GigEvent>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      availableGestures: AvailableGestures.horizontalSwipe,
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.textSecondary),
                        rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        titleTextStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                        weekendStyle: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                      ),
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: _calDayText,
                        weekendTextStyle: _calDayText,
                        holidayTextStyle: _calDayText,
                        outsideTextStyle: _calDayText.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.55),
                        ),
                        selectedTextStyle: _calDayText,
                        todayTextStyle: _todayDayText,
                        todayDecoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.stroke),
                        ),
                        selectedDecoration: BoxDecoration(
                          color: AppColors.accentTeal.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accentTeal),
                        ),
                        markerDecoration: const BoxDecoration(
                          color: AppColors.accentTeal,
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 3,
                      ),
                      eventLoader: eventsForDay,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, dayEvents) {
                          if (dayEvents.isEmpty) return null;
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  dayEvents.length.clamp(1, 3),
                                  (i) => Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentTeal,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppLayout.screenGap),
                    Text(
                      'Bags do dia',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppLayout.bagsMonthCardsGap),
                    if (dayEvents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Nenhuma bag neste dia.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    else
                      for (var i = 0; i < dayEvents.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        GigCard(
                          title: dayEvents[i].title,
                          subtitle: _compactDate(dayEvents[i].startsAt),
                          onTap: () => _openEvent(context, dayEvents[i]),
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

  void _openEvent(BuildContext context, GigEvent e) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: e.id)),
    );
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
