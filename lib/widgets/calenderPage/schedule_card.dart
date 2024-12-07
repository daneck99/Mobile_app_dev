//스케줄 등록 시 카드 등록 위젯
import 'package:flutter/material.dart';
import 'package:security/style/colors.dart';
import 'package:intl/intl.dart'; // intl 패키지 import

class _Time extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;

  const _Time({super.key, required this.startTime, required this.endTime});

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = TextStyle(
      fontWeight: FontWeight.w500,
      color: Colors.indigo.shade400,
      fontSize: 18,
    );

    // 시간을 "시간:분" 형식으로 포맷팅
    final String formattedStartTime = DateFormat('hh:mm a').format(startTime);
    final String formattedEndTime = DateFormat('hh:mm a').format(endTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formattedStartTime, // 포맷팅된 시작 시간
          style: defaultTextStyle,
        ),
        Text(
          formattedEndTime, // 포맷팅된 종료 시간
          style: defaultTextStyle.copyWith(
            fontSize: 14,
          ),
        )
      ],
    );
  }
}

class _Title extends StatelessWidget {
  final String title;

  const _Title({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ));
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
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
    ));
  }
}

class _Creator extends StatelessWidget {
  final String creator;

  const _Creator({super.key, required this.creator});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      child: Text(
        creator,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
    ));
  }
}

class _Assignee extends StatelessWidget {
  final String assignee;

  const _Assignee({super.key, required this.assignee});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      child: Text(
        assignee,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
    ));
  }
}

class _Category extends StatelessWidget {
  final Color color;

  const _Category({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      width: 16,
      height: 16,
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final String title;
  final String content;
  final String creator;
  final String assignee;
  final Color color;
  final VoidCallback onTap; // 클릭 시 실행될 콜백 추가

  const ScheduleCard(
      {super.key,
      required this.startTime,
      required this.endTime,
      required this.title,
      required this.content,
      required this.creator,
      required this.assignee,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 클릭 이벤트 처리
      child: Container(
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
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Title(title: title),
                    const SizedBox(height: 8),
                    _Content(content: content)
                  ],
                )),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Creator(creator: creator),
                      _Assignee(assignee: assignee),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _Category(color: color), // 색상 전달
              ],
            ),
          ),
        ),
      ),
    );
  }
}
