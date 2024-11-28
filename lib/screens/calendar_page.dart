import 'package:flutter/material.dart';
import 'package:security/widgets/calenderPage/main_calendar.dart';
import 'package:security/widgets/calenderPage/schedule_card.dart';
import '../style/colors.dart';
import 'package:security/widgets/calenderPage/today_banner.dart';
import 'package:security/widgets/common/bottom_nav_bar.dart';
import '../widgets/calenderPage/schedule_add.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _selectedIndex = 0;

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    // 선택된 날짜의 일정 필터링
    List<Schedule> filteredSchedules = schedules.where((schedule) {
      return schedule.date.year == selectedDate.year &&
          schedule.date.month == selectedDate.month &&
          schedule.date.day == selectedDate.day;
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () async {
          // ScheduleAdd 모달 창 열기
          final newSchedule = await showModalBottomSheet<Schedule>(
            context: context,
            isScrollControlled: true,//스크롤링
            builder: (_) {
              return Container(
                padding: EdgeInsets.all(16),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8, // 높이 제한 설정
                  minHeight: 100, // 최소 높이
                ),
                child: ScheduleAdd(selectedDate: selectedDate),
              );
            },
          );

          // 반환된 새 일정을 schedules 리스트에 추가
          if (newSchedule != null) {
            setState(() {
              schedules.add(newSchedule);
            });
          }
        },
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MainCalendar(
              selectedDate: selectedDate,
              onDaySelected: onDaySelected,
            ),
            SizedBox(height: 8.0),
            TodayBanner(
              selectedDate: selectedDate,
              count: filteredSchedules.length,
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ListView.separated(
                  itemCount: filteredSchedules.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 8);
                  },
                  itemBuilder: (context, index) {
                    final schedule = filteredSchedules[index];
                    return Dismissible(
                      key: Key(schedule.id.toString()), // 각 스케줄 고유 키 설정
                      direction: DismissDirection.endToStart, // 오른쪽에서 왼쪽으로만 스와이프
                      onDismissed: (direction) {
                        setState(() {
                          schedules.removeWhere((s) => s.id == schedule.id); // 스케줄 삭제
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${schedule.content}이 삭제되었습니다.')),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ScheduleCard(
                        startTime: schedule.startTime,
                        endTime: schedule.endTime,
                        content: schedule.content,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      this.selectedDate = selectedDate;
    });
  }
}
