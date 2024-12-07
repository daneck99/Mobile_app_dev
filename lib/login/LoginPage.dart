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
      appBar: AppBar(
        title: const Text('로그인'),
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formkey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                onChanged: (value) {
                  password = value;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        saving = true;
                      });

                      final currentUser =
                      await _authentication.signInWithEmailAndPassword(
                          email: email, password: password);
      
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

                      String errorMessage = '';
                      if (e.code == 'invalid-credential') {
                        errorMessage = '로그인에 실패하였습니다. 다시 시도해주세요.';
                      } else {
                        errorMessage = '로그인에 실패하였습니다. 다시 시도해주세요.';
                      }

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('오류'),
                          content: Text(errorMessage),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('확인'),
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
                  child: Text('로그인')),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('계정이 없다면?'),
                  TextButton(
                    child: Text('회원가입'),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()));
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
