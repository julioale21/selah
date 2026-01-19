import 'package:flutter/material.dart';
import 'package:selah_ui_kit/selah_ui_kit.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../domain/entities/daily_plan.dart';

class WeekCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final List<DailyPlan> plans;
  final Function(DateTime) onDateSelected;
  final Function(DateTime)? onPageChanged;

  const WeekCalendar({
    super.key,
    required this.selectedDate,
    required this.plans,
    required this.onDateSelected,
    this.onPageChanged,
  });

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  late DateTime _focusedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
  }

  @override
  void didUpdateWidget(WeekCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _focusedDay = widget.selectedDate;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DailyPlan? _getPlanForDay(DateTime day) {
    return widget.plans.where((p) => _isSameDay(p.date, day)).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(SelahSpacing.radiusMd),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => _isSameDay(widget.selectedDate, day),
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {
          CalendarFormat.week: 'Semana',
          CalendarFormat.twoWeeks: '2 Semanas',
          CalendarFormat.month: 'Mes',
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: 'es_ES',
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: SelahColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(SelahSpacing.radiusSm),
          ),
          formatButtonTextStyle: TextStyle(
            color: SelahColors.primary,
            fontSize: 12,
          ),
          titleTextStyle: Theme.of(context).textTheme.titleMedium!,
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            color: SelahColors.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: SelahColors.primary,
            fontWeight: FontWeight.bold,
          ),
          selectedDecoration: BoxDecoration(
            color: SelahColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          defaultTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          weekendTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          markerDecoration: BoxDecoration(
            color: SelahColors.success,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          markerSize: 6,
          markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final plan = _getPlanForDay(date);
            if (plan == null) return null;

            return Positioned(
              bottom: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: plan.isCompleted
                      ? SelahColors.success
                      : SelahColors.primary.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
          defaultBuilder: (context, day, focusedDay) {
            final plan = _getPlanForDay(day);
            if (plan != null && plan.isCompleted) {
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: SelahColors.success.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: SelahColors.success,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: SelahColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }
            return null;
          },
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
          widget.onDateSelected(selectedDay);
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          widget.onPageChanged?.call(focusedDay);
        },
      ),
    );
  }
}
