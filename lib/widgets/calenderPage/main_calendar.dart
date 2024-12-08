import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../style/colors.dart';

class MainCalendar extends StatelessWidget {
  final OnDaySelected onDaySelected;
  final DateTime selectedDate;
  final DateTime focusedDate;
  final Map<DateTime, int> taskCountByDate; // 날짜별 Task 개수

  MainCalendar({
    super.key,
    required this.onDaySelected,
    required this.selectedDate,
    required this.taskCountByDate, // 외부에서 전달받은 Task 개수 맵
    DateTime? initialFocusedDate,
  }) : focusedDate = initialFocusedDate ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    final defaultBoxDeco = BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
    );
    final defaultTextStyle = TextStyle(
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w700,
    );

    return TableCalendar(
      locale: 'ko_kr',
      focusedDay: focusedDate,
      firstDay: DateTime(2000, 1, 1),
      lastDay: DateTime(2100, 1, 1),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      calendarStyle: CalendarStyle(
        isTodayHighlighted: true,
        todayDecoration: defaultBoxDeco.copyWith(
          color: Colors.blueAccent.shade200,
        ),
        defaultDecoration: defaultBoxDeco,
        weekendDecoration: defaultBoxDeco.copyWith(
          color: Colors.white,
        ),
        selectedDecoration: defaultBoxDeco.copyWith(
          color: Colors.white,
          border: Border.all(
            color: primaryColor,
            width: 1.5,
          ),
        ),
        defaultTextStyle: defaultTextStyle,
        weekendTextStyle: defaultTextStyle.copyWith(
          color: Colors.pink,
        ),
        selectedTextStyle: defaultTextStyle.copyWith(
          color: primaryColor,
        ),
      ),
      onDaySelected: onDaySelected,
      selectedDayPredicate: (date) =>
      date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day,
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          final taskCount = taskCountByDate[DateTime(date.year, date.month, date.day)] ?? 0;

          return Stack(
            children: [
              Center(
                child: Text(
                  '${date.day}',
                  style: defaultTextStyle,
                ),
              ),
              if (taskCount > 0)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$taskCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        todayBuilder: (context, date, _) {
          final taskCount = taskCountByDate[DateTime(date.year, date.month, date.day)] ?? 0;

          return Stack(
            children: [
              Center(
                child: Text(
                  '${date.day}',
                  style: defaultTextStyle.copyWith(color: Colors.blueAccent),
                ),
              ),
              if (taskCount > 0)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$taskCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
