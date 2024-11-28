// lib/features/tasks/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:security/widgets/taskListPage/progressBar.dart';
import 'package:security/widgets/taskListPage/taskCard.dart';
import 'package:security/widgets/taskListPage/taskDetail.dart';
import 'package:security/map/map_page.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({Key? key}) : super(key: key);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        barrierColor: Colors.black.withOpacity(0.5),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.7,
                          minChildSize: 0.5,
                          maxChildSize: 0.95,
                          builder: (context, scrollController) => TaskDetailSheet(
                            title: '강의실 순찰',
                            description: '안녕하세요 적당히 바람이 시원해',
                            time: '08:30 PM',
                          ),
                        ),
                      );
                    },
                    child: TaskCard(
                      title: '강의실 순찰',
                      time: '08:30 PM',
                      participants: '1',
                      repeatCount: '2',
                      date: 'Mon, 19 Jul 2022',
                      color: Color(0xFF3F51B5),
                    )
                ),

                const SizedBox(height: 12),
                const TaskCard(
                  title: '열쇠 반납',
                  time: '08:30 PM',
                  participants: '1',
                  repeatCount: '2',
                  date: 'Mon, 19 Jul 2022',
                  color: Color(0xFFF44336),
                ),
              ],
            ),
          ),
          const ProgressBar(),
          const CustomBottomNavBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3F51B5),
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}



class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF3F51B5),
      unselectedItemColor: Colors.grey,
      currentIndex: 1,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: ''),
      ],
    );
  }
}