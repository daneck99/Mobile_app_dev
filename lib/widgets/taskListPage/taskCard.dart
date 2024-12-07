import 'package:flutter/material.dart';
import 'package:security/models/schedule_model.dart';

class TaskCard extends StatelessWidget {
  final Schedule schedule;

  const TaskCard({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formatting time and date
    final String time = "${schedule.startTime.hour}:${schedule.startTime.minute.toString().padLeft(2, '0')} - ${schedule.endTime.hour}:${schedule.endTime.minute.toString().padLeft(2, '0')}";
    final String date = "${schedule.date.year}-${schedule.date.month.toString().padLeft(2, '0')}-${schedule.date.day.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
              color: Color(schedule.colorID),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_outlined, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    schedule.title,
                    style: const TextStyle(
                      color: Colors.white,
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
                  schedule.assignee.isNotEmpty
                      ? schedule.assignee
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
          if (schedule.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                schedule.content,
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
