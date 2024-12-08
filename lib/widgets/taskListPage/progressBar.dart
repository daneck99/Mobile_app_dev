import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int totalTasks; // 전체 task 개수
  final int completedTasks; // 완료된 task 개수

  const ProgressBar({
    Key? key,
    required this.totalTasks,
    required this.completedTasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 진행률 계산 (예: 완료된 개수 / 전체 개수)
    final double progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.78,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${(progress * 100).toInt()}% 진행률', // 퍼센트로 표시
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
