import 'package:flutter/material.dart';
import 'package:security/widgets/calenderPage/main_calendar.dart';
import 'package:security/widgets/calenderPage/schedule_card.dart';
import '../models/schedule_model.dart';
import '../style/colors.dart';
import 'package:security/widgets/calenderPage/today_banner.dart';
import 'package:security/widgets/common/bottom_nav_bar.dart';
import '../widgets/calenderPage/schedule_add.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Schedule> schedules = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인된 사용자가 없습니다.');
      }

      final snapshot = await _firestore
          .collection('schedules')
          .where('userId', isEqualTo: user.uid) // 로그인한 사용자 UID로 필터링
          .get();

      final fetchedSchedules = snapshot.docs.map((doc) {
        return Schedule.fromJson(doc.data());
      }).toList();

      setState(() {
        schedules = fetchedSchedules;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터 가져오기 실패: $e')),
      );
    }
  }

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    // 선택된 날짜에 해당하는 일정 필터링
    final filteredSchedules = schedules.where((schedule) {
      return schedule.date.year == selectedDate.year &&
          schedule.date.month == selectedDate.month &&
          schedule.date.day == selectedDate.day;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        tooltip: '새 일정 추가',
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
                child: ScheduleAdd(
                  selectedDate: selectedDate,
                  initialSchedule: null, // 기존 데이터를 전달
                ),
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
                child: filteredSchedules.isEmpty
                    ? Center(
                  child: Text(
                    '일정이 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                )
                    : ListView.separated(
                  itemCount: filteredSchedules.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 8);
                  },
                  itemBuilder: (context, index) {
                    final schedule = filteredSchedules[index];
                    return Dismissible(
                      key: Key(schedule.id.toString()), // 각 스케줄 고유 키 설정
                      direction: DismissDirection.endToStart, // 오른쪽에서 왼쪽으로만 스와이프
                      onDismissed: (direction) async {
                        try {
                          await _firestore.collection('schedules').doc(schedule.id).delete();
                          setState(() {
                            schedules.removeWhere((s) => s.id == schedule.id);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${schedule.content}이 삭제되었습니다.')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('스케줄 삭제 실패: $e')),
                          );
                        }
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
                        color: Color(schedule.colorID), // 기존 저장된 색상 사용
                        onTap: () async {
                          final updatedSchedule = await showModalBottomSheet<Schedule>(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) {
                              return Container(
                                padding: EdgeInsets.all(16),
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                                ),
                                child: ScheduleAdd(
                                  selectedDate: selectedDate,
                                  initialSchedule: schedule, // 기존 데이터(수정할 스케쥴)를 전달
                                ),
                              );
                            },
                          );

                          if (updatedSchedule != null) {
                            try {
                              await _firestore
                                  .collection('schedules')
                                  .doc(updatedSchedule.id)
                                  .update(updatedSchedule.toJson());

                              setState(() {
                                final index =
                                schedules.indexWhere((s) => s.id == schedule.id);
                                if (index != -1) {
                                  schedules[index] = updatedSchedule;
                                }
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('스케줄 업데이트 실패: $e')),
                              );
                            }
                          }
                        },
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
