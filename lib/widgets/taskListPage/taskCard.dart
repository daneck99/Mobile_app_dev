import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:security/models/schedule_model.dart';
import '../../screens/taskList/ScheduleEditPage.dart';

class TaskCard extends StatefulWidget {
  final Schedule schedule;
  final Function(bool isCompleted, DateTime? completedAt)? onCompletionToggle;
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleCompletion() async {
    final DateTime now = DateTime.now();

    setState(() {
      isCompleted = !isCompleted;

      // Trigger animation
      if (isCompleted) {
        _controller.forward().then((_) => _controller.reverse());
      }

      if (widget.onCompletionToggle != null) {
        widget.onCompletionToggle!(isCompleted, isCompleted ? now : null);
      }
    });

    // Firestore 업데이트
    try {
      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(widget.schedule.id)
          .update({'isCompleted': isCompleted});
    } catch (e) {
      print('Error updating isCompleted: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업데이트 중 오류가 발생했습니다.')),
      );
    }

    // Notify parent widget
    if (widget.onCompletionToggle != null) {
      widget.onCompletionToggle!(isCompleted, isCompleted ? now : null);
    }
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          Column(
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
                  Navigator.pop(context);
                  if (widget.onDelete != null) {
                    widget.onDelete!(widget.schedule);
                  }
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
    final String date =
        "${widget.schedule.date.year}-${widget.schedule.date.month.toString().padLeft(2, '0')}-${widget.schedule.date.day.toString().padLeft(2, '0')}";

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
                  color: isCompleted ? Colors.grey.withOpacity(0.5) : Color(widget.schedule.colorID),
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
                      onChanged: (value) {
                        if (value != null) {
                          _toggleCompletion();
                        }
                      },
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
                    const SizedBox(width: 16),
                    Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      widget.schedule.assignee.isNotEmpty
                          ? widget.schedule.assignee
                          : '담당자 없음',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.schedule.tags != null && widget.schedule.tags!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    children: widget.schedule.tags!
                        .map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.grey[200],
                    ))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
