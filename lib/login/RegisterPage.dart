import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:security/login/SuccessRegister.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: const RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool saving = false;
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String userName = '';

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: saving,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Email',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  style: const TextStyle(color: Color(0xFF333333)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter your Email',
                    hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
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
                    color: Color(0xFF333333),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  obscureText: true,
                  style: const TextStyle(color: Color(0xFF333333)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter your Password',
                    hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                    ),
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Name',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  style: const TextStyle(color: Color(0xFF333333)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter your Name',
                    hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                    ),
                  ),
                  onChanged: (value) {
                    userName = value;
                  },
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
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

                      final newUser = await _authentication.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      await FirebaseFirestore.instance.collection('사용자').doc(newUser.user!.uid).set({
                        '이름': userName,
                        'email': email,
                        '계정 생성일': FieldValue.serverTimestamp(),
                      });

                      if (newUser.user != null) {
                        _formKey.currentState!.reset();
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SuccessRegisterPage()),
                        );
                      }

                      setState(() {
                        saving = false;
                      });
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        saving = false;
                      });

                      String errorMessage = '회원가입에 실패하였습니다. 다시 시도해주세요.';

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
                      print('회원가입 오류: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('회원가입 중 오류가 발생했습니다.')),
                      );
                    }
                  },
                  child: const Text(
                    'Sign Up',
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
                      'Already have an account?',
                      style: TextStyle(color: Color(0xFF333333)),
                    ),
                    TextButton(
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Color(0xFF4A90E2)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
