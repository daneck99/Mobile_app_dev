import 'package:flutter/material.dart';
import 'package:security/models/schedule_model.dart';


class TaskDetailSheet extends StatelessWidget {

  final Schedule schedule;

  const TaskDetailSheet({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String time =
        "${schedule.startTime.hour}:${schedule.startTime.minute.toString().padLeft(2, '0')} - ${schedule.endTime.hour}:${schedule.endTime.minute.toString().padLeft(2, '0')}";
    final String date =
        "${schedule.date.year}-${schedule.date.month.toString().padLeft(2, '0')}-${schedule.date.day.toString().padLeft(2, '0')}";
    WidgetsFlutterBinding.ensureInitialized();
    return Container(

      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Task Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Details section
            _buildDetailRow(
              icon: Icons.flag,
              label: "Title",
              value: schedule.title,
              boldValue: true,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.calendar_today_outlined,
              label: "Date",
              value: date,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.access_time,
              label: "Time",
              value: time,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.person_outline,
              label: "Assignee",
              value: schedule.assignee.isNotEmpty
                  ? schedule.assignee
                  : "Unassigned",
            ),
            if (schedule.location != null && schedule.location!.isNotEmpty)
              const SizedBox(height: 12),
            if (schedule.location != null && schedule.location!.isNotEmpty)
              _buildDetailRow(
                icon: Icons.location_on,
                label: "Location",
                value: schedule.location!,
              ),
            const SizedBox(height: 12),

            // Tags
            if (schedule.tags != null && schedule.tags!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tags",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: schedule.tags!
                        .map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.grey[200],
                    ))
                        .toList(),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Description
            if (schedule.content.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    schedule.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Completion Status
            Row(
              children: [
                Icon(
                  schedule.isCompleted
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  size: 24,
                  color: schedule.isCompleted ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Text(
                  schedule.isCompleted ? "Completed" : "In Progress",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: schedule.isCompleted ? Colors.green : Colors.grey,
                  ),
                ),
                if (schedule.isCompleted && schedule.completedAt != null)
                  const SizedBox(width: 12),
                if (schedule.isCompleted && schedule.completedAt != null)
                  Text(
                    "at ${schedule.completedAt!.toLocal()}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFF3F51B5),
                ),
                child: const Text(
                  "Edit Task",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool boldValue = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF3F51B5), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: boldValue ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
