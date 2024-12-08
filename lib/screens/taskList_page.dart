import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:security/widgets/taskListPage/taskCard.dart';
import 'package:security/widgets/taskListPage/taskDetail.dart';
import '../models/schedule_model.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Schedule> schedules = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;

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

      // 정렬: 완료 여부(isCompleted) -> 시작 시간(startTime)
      fetchedSchedules.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1; // 완료된 일정은 뒤로
        }
        return a.startTime.compareTo(b.startTime); // 시작 시간 순으로 정렬
      });

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

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final String formattedDate = DateFormat('yyyy년 MM월 dd일').format(today);

    // 오늘 날짜 기준으로 필터링
    final todaySchedules = schedules.where((schedule) {
      return schedule.date.year == today.year &&
          schedule.date.month == today.month &&
          schedule.date.day == today.day;
    }).toList();

    // 체크표시된 항목들을 맨 아래로 정렬
    todaySchedules.sort((a, b) {
      if (a.isCompleted == b.isCompleted) {
        return 0; // 동일한 상태일 경우 순서 유지
      }
      return a.isCompleted ? 1 : -1; // 완료된 항목을 뒤로 보냄
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$formattedDate 업무 목록',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : todaySchedules.isEmpty
          ? const Center(
        child: Text(
          '오늘 등록된 일정이 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: todaySchedules.length,
        itemBuilder: (context, index) {
          final schedule = todaySchedules[index];
          return GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    TaskDetailSheet(schedule: schedule),
              );
            },
            child: TaskCard(
              schedule: schedule,

            ),
          );
        },
      ),
    );
  }
}