import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:security/models/schedule_model.dart';

class TaskCard extends StatefulWidget {
  final Schedule schedule;

  const TaskCard({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isChecked = false; // 체크 상태

  @override
  void initState() {
    super.initState();
    _isChecked = widget.schedule.isCompleted; // 초기값 Firestore에서 가져옴
  }

  Future<void> _updateIsCompleted(bool value) async {
    try {
      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(widget.schedule.id)
          .update({'isCompleted': value});
    } catch (e) {
      print('Error updating isCompleted: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업데이트 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formatting time and date
    final String time =
        "${widget.schedule.startTime.hour}:${widget.schedule.startTime.minute.toString().padLeft(2, '0')} - ${widget.schedule.endTime.hour}:${widget.schedule.endTime.minute.toString().padLeft(2, '0')}";
    final String date =
        "${widget.schedule.date.year}-${widget.schedule.date.month.toString().padLeft(2, '0')}-${widget.schedule.date.day.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: _isChecked ? Colors.grey.withOpacity(0.6) : Colors.white, // 체크 여부에 따라 색상 변경
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
          // Title section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isChecked ? Colors.grey.withOpacity(0.6) : Color(widget.schedule.colorID),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool? value) async {
                    if (value != null) {
                      setState(() {
                        _isChecked = value;
                      });
                      await _updateIsCompleted(value); // Firestore 업데이트
                    }
                  },
                ),
                const SizedBox(width: 8),
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
                const Icon(Icons.more_horiz, color: Colors.white),
              ],
            ),
          ),
          // Details section
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
          // Optional content section
          if (widget.schedule.content.isNotEmpty)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                widget.schedule.content,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
