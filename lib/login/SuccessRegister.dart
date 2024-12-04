import 'package:flutter/material.dart';

class SuccessRegisterPage extends StatelessWidget {
  const SuccessRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('회원가입에 성공하셨습니다!',
                style: TextStyle(
                  fontSize: 20,
                )
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            }, child: const Text('로그인'))
          ],
        ),
      ),
    );
  }
}
