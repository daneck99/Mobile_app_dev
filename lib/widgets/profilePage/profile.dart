import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '/widgets/common/bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = "홍길동";
  String _enrollDate = "2023-01-01";
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  void _showEditDialog() {
    TextEditingController nameController = TextEditingController(text: _name);
    TextEditingController enrollDateController = TextEditingController(text: _enrollDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('프로필 수정'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _profileImage = File(pickedFile.path);
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : AssetImage("assets/profile.png") as ImageProvider,
                    child: Icon(Icons.camera_alt, size: 30, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: '이름'),
                ),
                TextField(
                  controller: enrollDateController,
                  decoration: InputDecoration(labelText: '등록일'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('확인'),
              onPressed: () {
                setState(() {
                  _name = nameController.text;
                  _enrollDate = enrollDateController.text;
                });
                Navigator.of(context).pop();
              },
            ),
            CustomBottomNavBar(selectedIndex: 3, onTap: (int ) {  },),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 페이지'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : AssetImage("assets/profile.png") as ImageProvider,
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '등록일: $_enrollDate',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _showEditDialog,
              child: Text('프로필 설정'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
