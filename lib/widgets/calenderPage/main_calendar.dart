import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../style/colors.dart';

class MainCalendar extends StatefulWidget {
  final Function(DateTime selectedDate, DateTime focusedDate) onDaySelected;
  final DateTime selectedDate;
  final DateTime initialFocusedDate;
  final Map<DateTime, int> taskCountByDate; // 날짜별 Task 개수

  const MainCalendar({
    super.key,
    required this.onDaySelected,
    required this.selectedDate,
    required this.taskCountByDate,
    required this.initialFocusedDate,
  });

  @override
  State<MainCalendar> createState() => _MainCalendarState();
}

class _MainCalendarState extends State<MainCalendar> {
  late DateTime focusedDate;
  late Map<DateTime, int> taskCountByDate;

  @override
  void initState() {
    super.initState();
    focusedDate = widget.initialFocusedDate;
    taskCountByDate = Map.from(widget.taskCountByDate); // 초기 데이터 복사
  }
  // 부모 위젯으로부터 taskCount 업데이트 시 호출
  void updateTaskCount(Map<DateTime, int> newTaskCounts) {
    setState(() {
      taskCountByDate = newTaskCounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultBoxDeco = BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white, // 하얀 테두리 추가
        width: 1.0,
      ),
    );
    final defaultTextStyle = TextStyle(
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w700,
    );

    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: focusedDate, // 내부 상태 사용
      firstDay: DateTime(2000, 1, 1),
      lastDay: DateTime(2100, 1, 1),
      selectedDayPredicate: (date) =>
      date.year == widget.selectedDate.year &&
          date.month == widget.selectedDate.month &&
          date.day == widget.selectedDate.day,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          focusedDate = focusedDay; // 상태 업데이트
        });
        widget.onDaySelected(selectedDay, focusedDay);
      },
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
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          final taskCount =
              widget.taskCountByDate[DateTime(date.year, date.month, date.day)] ?? 0;

          return Stack(
            children: [
              Center(
                child: Text(
                  '${date.day}',
                  style: defaultTextStyle.copyWith(
                    color: date.weekday == DateTime.saturday || date.weekday == DateTime.sunday
                        ? Colors.pink
                        : Colors.grey,
                  ),
                ),
              ),
              if (taskCount > 0)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$taskCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        todayBuilder: (context, date, _) {
          final taskCount =
              widget.taskCountByDate[DateTime(date.year, date.month, date.day)] ?? 0;

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
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$taskCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
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
