import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../style/colors.dart';

class MainCalendar extends StatelessWidget {

  final OnDaySelected onDaySelected;
  final DateTime selectedDate;
  final DateTime focusedDate = DateTime.now();

  MainCalendar({super.key, required this.onDaySelected, required this.selectedDate});

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
        firstDay: DateTime(2000,1,1),
        lastDay: DateTime(2100,1,1),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered:true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          )
        ),

      calendarStyle: CalendarStyle(
        isTodayHighlighted: true,
        //박스 데코
        defaultDecoration: defaultBoxDeco,
        weekendDecoration: defaultBoxDeco.copyWith(
          color: Colors.white,
        ),
        selectedDecoration: defaultBoxDeco.copyWith(
          color: Colors.white,
          border: Border.all(
            color: primaryColor,
            width: 1.5,
          )
        ),
        //텍스트 데코
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
      date.year == selectedDate.year&&
      date.month == selectedDate.month&&
      date.day == selectedDate.day,

    );
  }
}
