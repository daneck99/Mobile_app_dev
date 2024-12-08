import 'package:flutter/material.dart';
import 'package:security/widgets/calenderPage/main_calendar.dart';
import 'package:security/widgets/calenderPage/schedule_card.dart';
import '../models/schedule_model.dart';
import '../style/colors.dart';
import 'package:security/widgets/calenderPage/today_banner.dart';
import '../widgets/calenderPage/schedule_add.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Schedule> schedules = [];
  Map<DateTime, int> taskCountByDate = {};
  DateTime selectedDate = DateTime.now();

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
          .where('userId', isEqualTo: user.uid)
          .get();

      final fetchedSchedules = snapshot.docs.map((doc) {
        return Schedule.fromJson(doc.data());
      }).toList();

      _updateTaskCounts(fetchedSchedules);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터 가져오기 실패: $e')),
      );
    }
  }

  void _updateTaskCounts(List<Schedule> schedules) {
    final Map<DateTime, int> taskCounts = {};

    for (var schedule in schedules) {
      final date = DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
      taskCounts[date] = (taskCounts[date] ?? 0) + 1;
    }

    setState(() {
      this.schedules = schedules;
      taskCountByDate = taskCounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredSchedules = schedules.where((schedule) {
      return schedule.date.year == selectedDate.year &&
          schedule.date.month == selectedDate.month &&
          schedule.date.day == selectedDate.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        tooltip: '새 일정 추가',
        onPressed: () async {
          final newSchedule = await showModalBottomSheet<Schedule>(
            context: context,
            isScrollControlled: true,
            builder: (_) {
              return Container(
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: ScheduleAdd(
                  selectedDate: selectedDate,
                  initialSchedule: null,
                ),
              );
            },
          );

          if (newSchedule != null) {
            try {
              await _firestore
                  .collection('schedules')
                  .doc(newSchedule.id)
                  .set(newSchedule.toJson());

              setState(() {
                schedules.add(newSchedule);
                _updateTaskCounts(schedules);
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('스케줄 추가 실패: $e')),
              );
            }
          }
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MainCalendar(
              selectedDate: selectedDate,
              initialFocusedDate: selectedDate,
              taskCountByDate: taskCountByDate,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                });
              },
            ),
            const SizedBox(height: 8.0),
            TodayBanner(
              selectedDate: selectedDate,
              count: filteredSchedules.length,
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: filteredSchedules.isEmpty
                    ? const Center(
                  child: Text(
                    '선택한 날짜에 일정이 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                )
                    : ListView.separated(
                  itemCount: filteredSchedules.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 8);
                  },
                  itemBuilder: (context, index) {
                    final schedule = filteredSchedules[index];
                    return Dismissible(
                      key: Key(schedule.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        try {
                          await _firestore
                              .collection('schedules')
                              .doc(schedule.id)
                              .delete();

                          setState(() {
                            schedules.remove(schedule);
                            _updateTaskCounts(schedules);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${schedule.title}이 삭제되었습니다.'),
                            ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ScheduleCard(
                        startTime: schedule.startTime,
                        endTime: schedule.endTime,
                        title: schedule.title,
                        content: schedule.content,
                        creator: schedule.creator,
                        assignee: schedule.assignee,
                        color: Color(schedule.colorID),
                        onTap: () async {
                          final updatedSchedule = await showModalBottomSheet<Schedule>(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                                ),
                                child: ScheduleAdd(
                                  selectedDate: selectedDate,
                                  initialSchedule: schedule,
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
                                final index = schedules.indexWhere(
                                        (s) => s.id == schedule.id);
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
}
