import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:security/widgets/taskListPage/progressBar.dart';
import 'package:security/widgets/taskListPage/taskCard.dart';
import 'package:security/widgets/taskListPage/taskDetail.dart';
import '../map/map_page.dart';
import '../models/schedule_model.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '업무 목록',
          style: TextStyle(
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
          : schedules.isEmpty
              ? const Center(
                  child: Text(
                    '등록된 일정이 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3F51B5),
        child: const Icon(Icons.add),
        onPressed: () {
          // Add a new task or navigate to another screen
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
