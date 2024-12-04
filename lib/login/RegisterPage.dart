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
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
              TextFormField(
                decoration: const InputDecoration(labelText: '이름'),
                onChanged: (value) {
                  userName = value;
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
                      final newUser =
                      await _authentication.createUserWithEmailAndPassword(
                          email: email, password: password);
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
                            MaterialPageRoute(
                                builder: (context) => SuccessRegisterPage()));
                      }
                      setState(() {
                        saving = false;
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Text('회원가입')),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('이미 계정이 있다면?'),
                  TextButton(
                    child: Text('로그인'),
                    onPressed: () {
                      Navigator.pop(context);
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
