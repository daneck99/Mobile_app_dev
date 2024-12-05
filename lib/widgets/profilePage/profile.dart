// profile.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../login/LoginPage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = "";
  String _enrollDate = "";
  String _photoUrl = "";
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// 사용자의 프로필 정보를 Firestore에서 로드하는 메서드
  Future<void> _loadProfile() async {
    setState(() {
      loading = true;
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('사용자').doc(user.uid).get();
        if (doc.exists) {
          Timestamp timestamp = doc['계정 생성일'] ?? Timestamp.now();
          DateTime enrollDateTime = timestamp.toDate();
          String formattedDate = DateFormat('yyyy-MM-dd').format(enrollDateTime);

          setState(() {
            _name = doc['이름'] ?? '';
            _enrollDate = formattedDate;
            _photoUrl = doc['photo'] ?? '';
          });
        }
      }
    } catch (e) {
      print("프로필 로드 에러: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필을 불러오는 중 에러가 발생했습니다.')),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  /// 프로필 정보를 업데이트하는 메서드
  Future<void> _updateProfile(String name, String enrollDate, File? imageFile) async {
    setState(() {
      loading = true;
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? photoUrl = _photoUrl;
        if (imageFile != null) {
          // 프로필 사진 업로드
          Reference storageRef = _storage.ref().child('profile_images').child('${user.uid}.png');
          UploadTask uploadTask = storageRef.putFile(imageFile);
          TaskSnapshot snapshot = await uploadTask;
          photoUrl = await snapshot.ref.getDownloadURL();
        }

        // Firestore 업데이트
        await _firestore.collection('사용자').doc(user.uid).update({
          '이름': name,
          '계정 생성일': DateFormat('yyyy-MM-dd').parse(enrollDate), // 문자열을 DateTime으로 변환
          'photo': photoUrl,
        });

        setState(() {
          _name = name;
          _enrollDate = enrollDate;
          _photoUrl = photoUrl ?? _photoUrl;
          if (imageFile != null) {
            _profileImage = imageFile;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필이 성공적으로 업데이트되었습니다.')),
        );
      }
    } catch (e) {
      print("프로필 업데이트 에러: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필을 업데이트하는 중 에러가 발생했습니다.')),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  /// 프로필 수정 다이얼로그를 표시하는 메서드
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
                    child: _profileImage != null
                        ? ClipOval(
                      child: Image.file(
                        _profileImage!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                        : (_photoUrl.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: _photoUrl,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 50,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) => CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage("assets/profile.png"),
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage("assets/profile.png"),
                      ),
                    )
                        : CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage("assets/profile.png"),
                    )),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: '이름'),
                ),
                TextField(
                  controller: enrollDateController,
                  decoration: InputDecoration(labelText: '등록일 (YYYY-MM-DD)'),
                  keyboardType: TextInputType.datetime,
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
              onPressed: () async {
                String updatedName = nameController.text.trim();
                String updatedEnrollDate = enrollDateController.text.trim();

                // 입력값 검증
                if (updatedName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('이름을 입력해주세요.')),
                  );
                  return;
                }
                if (updatedEnrollDate.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('등록일을 입력해주세요.')),
                  );
                  return;
                }
                // 날짜 형식 검증
                try {
                  DateFormat('yyyy-MM-dd').parseStrict(updatedEnrollDate);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('등록일 형식이 올바르지 않습니다. (YYYY-MM-DD)')),
                  );
                  return;
                }

                await _updateProfile(updatedName, updatedEnrollDate, _profileImage);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// 로그아웃을 처리하는 메서드
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      child: Scaffold(
        appBar: AppBar(
          title: Text('프로필 페이지'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  // 이미지 표시 로직 수정
                  _profileImage != null || _photoUrl.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: _photoUrl,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : imageProvider,
                    ),
                    placeholder: (context, url) => CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage("assets/profile.png"),
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage("assets/profile.png"),
                    ),
                  )
                      : CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/profile.png"),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
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
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _logout,
                    child: Text('로그아웃'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _showEditDialog,
                    child: Text('프로필 설정'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // 추가적인 UI 요소가 필요하다면 여기에 추가
            ],
          ),
        ),
      ),
    );
  }
}
