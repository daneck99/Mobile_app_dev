import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:security/widgets/taskListPage/progressBar.dart';
import 'package:security/widgets/taskListPage/taskCard.dart';
import 'package:security/widgets/taskListPage/taskDetail.dart';
import '../map/map_page.dart';
import '../models/schedule_model.dart';
import 'package:security/widgets/taskListPage/progressBar.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Schedule> schedules = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;

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

      setState(() {
        schedules = fetchedSchedules;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터 가져오기 실패: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Get tasks filtered by the selected date
  List<Schedule> _getSchedulesForSelectedDate() {
    return schedules.where((schedule) {
      return schedule.date.year == selectedDate.year &&
          schedule.date.month == selectedDate.month &&
          schedule.date.day == selectedDate.day;
    }).toList();
  }

  // Navigate to the previous day
  void _goToPreviousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
  }
  // Navigate to the next day
  void _goToNextDay() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredSchedules = _getSchedulesForSelectedDate();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // 오늘 날짜의 일정 필터링
    final todaySchedules = schedules.where((schedule) {
      final taskDate = schedule.date;
      return taskDate.year == todayStart.year &&
          taskDate.month == todayStart.month &&
          taskDate.day == todayStart.day;
    }).toList();

    // 정렬: 체크된 항목은 아래로, 나머지는 시작시간 순서
    todaySchedules.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1; // 체크된 항목은 아래로
      }
      return a.startTime.compareTo(b.startTime); // 시작시간 기준 정렬
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '오늘의 업무 목록',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Date selector row
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goToPreviousDay,
                ),
                Text(
                  "${selectedDate.year}-${selectedDate.month.toString().padLeft(
                      2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _goToNextDay,
                ),
              ],
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchSchedules, // Pull-to-refresh callback
              child: filteredSchedules.isEmpty
                  ? const Center(
                child: Text(
                  '등록된 일정이 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = filteredSchedules[index];
                  return GestureDetector(
                    onTap: () async {
                      // Await for the result from TaskDetailSheet
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskDetailSheet(schedule: schedule),
                        ),
                      );

                      // Refresh schedules if needed
                      if (result == 'refresh') {
                        _fetchSchedules();
                      }
                    },
                    child: TaskCard(
                      schedule: schedule,
                      onEdit: (updatedSchedule) {
                        _fetchSchedules(); // Refresh after editing
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          const ProgressBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3F51B5),
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MapScreen(), // Replace with your add schedule page
            ),
          );
          // Refresh if a new task was added
          if (result == 'refresh') {
            _fetchSchedules();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
///////////////////////////////////////////////////
/////////////////////////////////
