import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/schedule_model.dart';
import '../../screens/taskList/ScheduleEditPage.dart';

class TaskCard extends StatefulWidget {
  final Schedule schedule;
  final Function(bool isCompleted)? onCompletionToggle;
  final Function(Schedule schedule)? onEdit;
  final Function(Schedule schedule)? onDelete;
  final Function(Schedule schedule)? onShare;

  const TaskCard({
    Key? key,
    required this.schedule,
    this.onCompletionToggle,
    this.onEdit,
    this.onDelete,
    this.onShare,
  }) : super(key: key);

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late bool isCompleted;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  void _deleteTask(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(widget.schedule.id)
          .delete();

      // 부모 위젯에 상태 전달 (onDelete 콜백)
      if (widget.onDelete != null) {
        widget.onDelete!(widget.schedule);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('스케줄이 삭제되었습니다.')),
      );
    } catch (e) {
      print('Error deleting task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('스케줄 삭제 중 오류가 발생했습니다: $e')),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    isCompleted = widget.schedule.isCompleted;

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.schedule.isCompleted != oldWidget.schedule.isCompleted) {
      setState(() {
        isCompleted = widget.schedule.isCompleted;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleCompletion() async {
    final newCompletedStatus = !isCompleted;
    setState(() {
      isCompleted = newCompletedStatus;

      // Trigger animation
      if (isCompleted) {
        _controller.forward().then((_) => _controller.reverse());
      }
    });

    // Firestore 업데이트
    try {
      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(widget.schedule.id)
          .update({'isCompleted': newCompletedStatus});
    } catch (e) {
      print('Error updating isCompleted: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업데이트 중 오류가 발생했습니다.')),
      );
    }

    // 부모 위젯에 상태 전달
    if (widget.onCompletionToggle != null) {
      widget.onCompletionToggle!(isCompleted);
    }
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('수정'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ScheduleEditPage(schedule: widget.schedule),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('삭제'),
            onTap: () {
              Navigator.pop(context); // BottomSheet 닫기
              _deleteTask(context); // 삭제 작업 호출
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('공유'),
            onTap: () {
              Navigator.pop(context);
              if (widget.onShare != null) {
                widget.onShare!(widget.schedule);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String time =
        "${widget.schedule.startTime.hour}:${widget.schedule.startTime.minute.toString().padLeft(2, '0')} - ${widget.schedule.endTime.hour}:${widget.schedule.endTime.minute.toString().padLeft(2, '0')}";

    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: isCompleted ? Colors.grey.withOpacity(0.5) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.black,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.grey.withOpacity(0.5)
                      : Color(widget.schedule.colorID),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.black),
                    Expanded(
                      child: Text(
                        widget.schedule.title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Checkbox(
                      value: isCompleted,
                      onChanged: (_) => _toggleCompletion(),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      widget.schedule.assignee.isNotEmpty
                          ? widget.schedule.assignee
                          : '담당자 없음', // assignee 표시
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
