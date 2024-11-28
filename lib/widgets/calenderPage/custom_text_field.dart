import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../style/colors.dart';
import 'package:security/widgets/calenderPage/time_picker.dart'; // TimePicker import
class CustomTextField extends StatefulWidget {
  final String label;
  final bool isTime;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.isTime,
    required this.onSaved,
    required this.validator,
    this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8), // 텍스트와 입력 필드 사이 간격
        TextFormField(
          readOnly: widget.isTime, // 시간 입력 필드는 읽기 전용
          controller: widget.controller,
          onSaved: widget.onSaved,
          validator: widget.validator,
          cursorColor: Colors.grey,
          maxLines: widget.isTime ? 1 : null,
          keyboardType:
          widget.isTime ? TextInputType.none : TextInputType.multiline,
          inputFormatters: widget.isTime
              ? [
            FilteringTextInputFormatter.digitsOnly,
          ]
              : [],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade200,
            contentPadding: const EdgeInsets.all(12),
            hintStyle: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            hintText: widget.label == "Start Time" || widget.label == "End Time"
                ? "Select Time"
                : "Type in your text",
          ),
          onTap: widget.isTime
              ? () async {
            final TimeOfDay? pickedTime = await TimePickerUtil
                .showTimePickerDialog(
              context,
              initialTime: TimeOfDay.now(),
              use24HourFormat: true,
            );

            if (pickedTime != null) {
              setState(() {
                widget.controller?.text = pickedTime.format(context);
              });
            }
          }
              : null,
        ),
      ],
    );
  }
}
