import 'package:flutter/material.dart';
import 'package:security/custom_text_field.dart';
import 'colors.dart';

// 임시 저장용 스케줄 리스트
List<Schedule> schedules = [];

class ScheduleAdd extends StatefulWidget {
  final DateTime selectedDate;

  const ScheduleAdd({super.key, required this.selectedDate});

  @override
  State<ScheduleAdd> createState() => _ScheduleAddState();
}

class _ScheduleAddState extends State<ScheduleAdd> {
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _contentController = TextEditingController(); // 내용 입력용 컨트롤러



  // 스케줄을 저장하는 함수
  void _saveSchedule() {
    final int startTime = int.tryParse(_startTimeController.text) ?? 0;
    final int endTime = int.tryParse(_endTimeController.text) ?? 0;
    final String content = _contentController.text;

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내용을 입력하세요')),
      );
      return;
    }

    final newSchedule = Schedule(
      id: schedules.length + 1, // 임시 ID, 실제 DB에서는 auto-increment
      content: content,
      date: widget.selectedDate,
      startTime: startTime,
      endTime: endTime,
      colorID: 1,
      createdAt: DateTime.now(),
    );

    // 데이터를 pop하여 CalendarPage로 전달
    Navigator.pop(context, newSchedule);

    print("스케줄 저장됨: ${newSchedule.startTime} - ${newSchedule.endTime}");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets, // 키보드 가림 방지
        child: Column(
          mainAxisSize: MainAxisSize.min, // 필요한 만큼만 공간 사용
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: "Start Time",
                    isTime: true,
                    controller: _startTimeController,
                    onSaved: (value) {
                      _startTimeController.text = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '시작 시간을 입력하세요';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: "End Time",
                    isTime: true,
                    controller: _endTimeController,
                    onSaved: (value) {
                      _endTimeController.text = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '종료 시간을 입력하세요';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Type in your Text(내용)',
              isTime: false,
              controller: _contentController,
              onSaved: (value) {
                _contentController.text = value ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '내용을 입력하세요';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveSchedule,
              child: Text("Save Schedule"),
            ),
          ],
        ),
      ),
    );
  }
}

// 임시 스케줄 클래스
class Schedule {
  final int id;
  final String content;
  final DateTime date;
  final int startTime;
  final int endTime;
  final int colorID;
  final DateTime createdAt;

  Schedule({
    required this.id,
    required this.content,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.colorID,
    required this.createdAt,
  });
}
