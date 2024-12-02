import 'package:flutter/material.dart';
import 'package:security/widgets/calenderPage/custom_text_field.dart';
import '../../style/colors.dart';

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

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // 시간 선택 함수
  Future<void> _pickTime(BuildContext context, TextEditingController controller, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        final formattedTime = pickedTime.format(context); // HH:mm AM/PM 형식으로 변환
        controller.text = formattedTime;

        // 시작 시간 또는 종료 시간을 저장
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  // 스케줄을 저장하는 함수
  void _saveSchedule() {
    if (_startTime == null || _endTime == null || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 채워주세요!')),
      );
      return;
    }

    final DateTime startTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final DateTime endTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final newSchedule = Schedule(
      id: schedules.length + 1,
      content: _contentController.text,
      date: widget.selectedDate,
      startTime: startTime,
      endTime: endTime,
      colorID: 1,
      createdAt: DateTime.now(),
    );

    // 데이터를 pop하여 CalendarPage로 전달
    Navigator.pop(context, newSchedule);
    print("스케줄 저장됨: $startTime - $endTime");
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
                  child: GestureDetector(
                    onTap: () => _pickTime(context, _startTimeController, true),
                    child: AbsorbPointer(
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
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(context, _endTimeController, false),
                    child: AbsorbPointer(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 버튼 배경색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // 모서리 둥글기
                  side: BorderSide(
                    color: primaryColor, // 경계선 색상
                    width: 1.5, // 경계선 두께
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ), // 내부 패딩
                elevation: 0, // 그림자 제거
              ),
              child: Text(
                "Save Schedule",
                style: TextStyle(
                  color: primaryColor, // 텍스트 색상
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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
  final DateTime startTime;
  final DateTime endTime;
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
