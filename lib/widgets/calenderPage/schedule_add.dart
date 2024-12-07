import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:security/widgets/calenderPage/color_picker.dart';
import 'package:security/widgets/calenderPage/custom_text_field.dart';
import '../../style/colors.dart';
import 'package:security/models/schedule_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 임시 저장용 스케줄 리스트
List<Schedule> schedules = [];

class ScheduleAdd extends StatefulWidget {
  final DateTime selectedDate;
  final Schedule? initialSchedule; // 수정 시 기존 스케줄 데이터를 받음

  const ScheduleAdd({super.key, required this.selectedDate, this.initialSchedule});

  @override
  State<ScheduleAdd> createState() => _ScheduleAddState();
}

class _ScheduleAddState extends State<ScheduleAdd> {
  final _creatorController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _contentController = TextEditingController(); // 내용 입력용 컨트롤러
  final _titleController = TextEditingController();
  final _assigneeController = TextEditingController();
  Color _selectedColor = Colors.pinkAccent.shade100; // 기본 선택 색상


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
  @override
  void initState() {
    super.initState();

    // 수정 모드일 경우 기존 데이터를 초기화
    if (widget.initialSchedule != null) {
      final schedule = widget.initialSchedule!;
      _creatorController.text = ''; // 보고자 (필요시 수정)
      _assigneeController.text = ''; // 담당자 (필요시 수정)
      _contentController.text = schedule.content;
      _selectedColor = Color(schedule.colorID);

      _startTime = TimeOfDay.fromDateTime(schedule.startTime);
      _endTime = TimeOfDay.fromDateTime(schedule.endTime);
    } else {
      _selectedColor = Colors.pinkAccent.shade100; // 기본 색상
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 여기서 `BuildContext`를 사용할 수 있음
    if (widget.initialSchedule != null) {
      _startTimeController.text =
          TimeOfDay.fromDateTime(widget.initialSchedule!.startTime).format(context);
      _endTimeController.text =
          TimeOfDay.fromDateTime(widget.initialSchedule!.endTime).format(context);
    }
  }


  // 스케줄을 저장하는 함수
  void _saveSchedule() async {
    if (_startTime == null || _endTime == null || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 채워주세요!')),
      );
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final startTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final schedule = Schedule(
      id: widget.initialSchedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: _titleController.text,
      date: widget.selectedDate,
      startTime: startTime,
      endTime: endTime,
      colorID: _selectedColor.value,
      createdAt: widget.initialSchedule?.createdAt ?? DateTime.now(),
      userId: user.uid, // 현재 사용자 UID 추가
    );

    try {
      final collection = FirebaseFirestore.instance.collection('schedules');

      if (widget.initialSchedule == null) {
        // 새 스케줄 저장
        await collection.doc(schedule.id).set(schedule.toJson());
      } else {
        // 기존 스케줄 업데이트
        await collection.doc(schedule.id).update(schedule.toJson());
      }

      Navigator.pop(context, schedule);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 오류 발생: $e')),
      );
    }
  }

  void _loadUserSchedules() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('로그인된 사용자가 없습니다.');
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('schedules')
          .where('userId', isEqualTo: user.uid) // 사용자 UID 필터링
          .get();

      final List<Schedule> userSchedules = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Schedule(
          id: data['id'],
          content: data['content'],
          date: DateTime.parse(data['date']),
          startTime: DateTime.parse(data['startTime']),
          endTime: DateTime.parse(data['endTime']),
          colorID: data['colorID'],
          createdAt: DateTime.parse(data['createdAt']),
          userId: data['userId'],
        );
      }).toList();

      setState(() {
        schedules = userSchedules;
      });
    } catch (e) {
      print('스케줄 로드 오류: $e');
    }
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
                    label: '보고자',
                    isTime: false,
                    controller: _creatorController,
                    onSaved: (value) {
                      _creatorController.text = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '보고자를 입력하세요';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: '담당자',
                    isTime: false,
                    controller: _assigneeController,
                    onSaved: (value) {
                      _assigneeController.text = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '담당자를 입력하세요';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
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
            //제목 입력 코드
            CustomTextField(
              label: 'Type in your Text(제목)',
              isTime: false,
              controller: _titleController,
              onSaved: (value) {
                _titleController.text = value ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '내용을 입력하세요';
                }
                return null;
              },
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
            // priority 설정 코드
            ColorPicker(
                selectedColor: _selectedColor,
                onColorSelected: (color){
                  setState(() {
                  _selectedColor = color;
                  print('Color updated: $color'); // 로그 추가
              });
            }),
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
                widget.initialSchedule == null
                    ? "Save Schedule" : "Update Schedule",
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
