import 'package:flutter/material.dart';
import 'package:security/login/RegisterPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:security/widgets/homePage/home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // 밝은 회색
      body: const LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool saving = false;
  final _authentication = FirebaseAuth.instance;
  final _formkey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: saving,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                    color: Color(0xFF333333), // 짙은 회색
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Email',
                  style: TextStyle(
                    color: Color(0xFF333333), // 짙은 회색
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  style: const TextStyle(color: Color(0xFF333333)), // 짙은 회색
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white, // 흰색 배경
                    hintText: 'Enter your Email',
                    hintStyle: const TextStyle(color: Color(0xFFAAAAAA)), // 연한 회색
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCCCCCC)), // 연한 테두리
                    ),
                  ),
                  onChanged: (value) {
                    email = value;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Password',
                  style: TextStyle(
                    color: Color(0xFF333333), // 짙은 회색
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  obscureText: true,
                  style: const TextStyle(color: Color(0xFF333333)), // 짙은 회색
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white, // 흰색 배경
                    hintText: 'Enter your Password',
                    hintStyle: const TextStyle(color: Color(0xFFAAAAAA)), // 연한 회색
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: const Color(0xFFCCCCCC)), // 연한 테두리
                    ),
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2), // 진한 블루
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      setState(() {
                        saving = true;
                      });

                      final currentUser = await _authentication.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      if (currentUser.user != null) {
                        _formkey.currentState!.reset();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      }

                      setState(() {
                        saving = false;
                      });
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        saving = false;
                      });

                      String errorMessage = '로그인에 실패하였습니다. 다시 시도해주세요.';
                      if (e.code == 'user-not-found') {
                        errorMessage = '등록되지 않은 사용자입니다.';
                      } else if (e.code == 'wrong-password') {
                        errorMessage = '비밀번호가 틀렸습니다.';
                      }

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('오류'),
                          content: Text(errorMessage),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('확인'),
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      setState(() {
                        saving = false;
                      });
                      print('Unexpected error: $e');
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account?',
                      style: TextStyle(color: Color(0xFF333333)), // 짙은 회색
                    ),
                    TextButton(
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Color(0xFF4A90E2)), // 진한 블루
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
