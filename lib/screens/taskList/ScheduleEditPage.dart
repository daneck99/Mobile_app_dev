import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:security/models/schedule_model.dart';
import 'package:security/widgets/calenderPage/custom_text_field.dart';
import 'package:security/widgets/calenderPage/color_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../style/colors.dart';

class ScheduleEditPage extends StatefulWidget {
  final Schedule schedule;

  const ScheduleEditPage({Key? key, required this.schedule}) : super(key: key);

  @override
  State<ScheduleEditPage> createState() => _ScheduleEditPageState();
}

class _ScheduleEditPageState extends State<ScheduleEditPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _creatorController = TextEditingController();
  final _assigneeController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  Color _selectedColor = Colors.pinkAccent.shade100;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;


  @override
  void initState() {
    super.initState();

    // Initialize non-context-dependent fields
    final schedule = widget.schedule;

    _titleController.text = schedule.title;
    _contentController.text = schedule.content;
    _creatorController.text = schedule.creator;
    _assigneeController.text = schedule.assignee;
    _selectedColor = Color(schedule.colorID);

    // Delay context-dependent initialization
    _startTime = TimeOfDay.fromDateTime(schedule.startTime);
    _endTime = TimeOfDay.fromDateTime(schedule.endTime);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize context-dependent fields
    if (_startTime != null) {
      _startTimeController.text = _startTime!.format(context);
    }
    if (_endTime != null) {
      _endTimeController.text = _endTime!.format(context);
    }
  }

  // Save the updated schedule
  void _updateSchedule() async {
    if (_startTime == null || _endTime == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 채워주세요!')),
      );
      return;
    }

    final startTime = DateTime(
      widget.schedule.date.year,
      widget.schedule.date.month,
      widget.schedule.date.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endTime = DateTime(
      widget.schedule.date.year,
      widget.schedule.date.month,
      widget.schedule.date.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final updatedSchedule = Schedule(
      id: widget.schedule.id,
      title: _titleController.text,
      content: _contentController.text,
      creator: _creatorController.text,
      assignee: _assigneeController.text,
      date: widget.schedule.date,
      startTime: startTime,
      endTime: endTime,
      colorID: _selectedColor.value,
      createdAt: widget.schedule.createdAt,
      userId: widget.schedule.userId,
      isCompleted: widget.schedule.isCompleted,
      completedAt: widget.schedule.completedAt,
      location: widget.schedule.location,
      tags: widget.schedule.tags,
    );

    try {
      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(updatedSchedule.id)
          .update(updatedSchedule.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('스케줄이 성공적으로 업데이트되었습니다.')),
      );
      Navigator.pop(context, updatedSchedule);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업데이트 중 오류 발생: $e')),
      );
    }
  }

  // Time picker
  Future<void> _pickTime(BuildContext context, TextEditingController controller, bool isStartTime) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime ?? TimeOfDay.now() : _endTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        controller.text = pickedTime.format(context);
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Schedule', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: '제목',
              isTime: false,
              controller: _titleController,
              onSaved: (_) {},
              validator: (_) => null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: '내용',
              isTime: false,
              controller: _contentController,
              onSaved: (_) {},
              validator: (_) => null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: '보고자',
              isTime: false,
              controller: _creatorController,
              onSaved: (_) {},
              validator: (_) => null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: '담당자',
              isTime: false,
              controller: _assigneeController,
              onSaved: (_) {},
              validator: (_) => null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(context, _startTimeController, true),
                    child: AbsorbPointer(
                      child: CustomTextField(
                        label: 'Start Time',
                        isTime: true,
                        controller: _startTimeController,
                        onSaved: (_) {},
                        validator: (_) => null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(context, _endTimeController, false),
                    child: AbsorbPointer(
                      child: CustomTextField(
                        label: 'End Time',
                        isTime: true,
                        controller: _endTimeController,
                        onSaved: (_) {},
                        validator: (_) => null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ColorPicker(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Update Schedule',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
