import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../style/colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool isTime;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final TextEditingController? controller; // 컨트롤러 추가

  const CustomTextField({
    super.key,
    required this.label,
    required this.isTime,
    required this.onSaved,
    required this.validator,
    this.controller, // 컨트롤러 초기화
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w300,
          ),
        ),
        SizedBox(height: 8), // 텍스트와 입력 필드 사이 간격
        TextFormField(
          controller: controller, // 컨트롤러 추가
          onSaved: onSaved,
          validator: validator,
          cursorColor: Colors.grey,
          maxLines: isTime ? 1 : null, // 시간이면 한 줄만
          keyboardType: isTime ? TextInputType.number : TextInputType.multiline,
          inputFormatters: isTime
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
            contentPadding: EdgeInsets.all(12),
            hintStyle: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            hintText: "Type in your text",
          ),
        ),
      ],
    );
  }
}
