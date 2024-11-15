//스케줄 등록 시 카드 등록 위젯
import 'package:flutter/material.dart';
import 'colors.dart';

class _Time extends StatelessWidget {
  final int startTime;
  final int endTime;

  const _Time({super.key, required this.startTime, required this.endTime});

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = TextStyle(
      fontWeight: FontWeight.w500,
      color: Colors.indigo.shade400,
      fontSize: 18,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${startTime.toString().padLeft(2, '0')}:00',
          style: defaultTextStyle,
        ),
        Text(
          '${endTime.toString().padLeft(2,'0')}:00',
          style: defaultTextStyle.copyWith(
            fontSize: 14,
          ),
        )
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final String content;

  const _Content({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
          child: Text(
            content,
          ),
        )
    );
  }
}
class _Category extends StatelessWidget {
  const _Category({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.pinkAccent.shade100,
        shape: BoxShape.circle,
      ),
      width: 16,
      height: 16,
    );
  }
}
class ScheduleCard extends StatelessWidget {
  final int startTime;
  final int endTime;
  final String content;

  const ScheduleCard({super.key, required this.startTime, required this.endTime, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.6,
          color: primaryColor,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: IntrinsicHeight(
          //IntrinsicHeight : 가장 높은 위젯이 차지하고 있는 높이만큼 높이 제함
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Time(startTime: startTime, endTime: endTime),
              const SizedBox(width: 16),
              _Content(content: content),
              const SizedBox(width: 16),
              _Category(),
            ],
          ),
        ),
      ),
    );
  }
}

