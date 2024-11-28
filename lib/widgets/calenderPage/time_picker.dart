import 'package:flutter/material.dart';

class TimePickerUtil {
  static Future<TimeOfDay?> showTimePickerDialog(
      BuildContext context, {
        required TimeOfDay initialTime,
        bool use24HourFormat = false,
      }) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: use24HourFormat, // 24시간 형식 여부
          ),
          child: child!,
        );
      },
    );
  }
}
