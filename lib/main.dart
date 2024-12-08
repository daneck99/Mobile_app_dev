import 'package:flutter/material.dart';
import 'package:security/screens/calendar_page.dart';
import 'package:security/screens/taskList_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:security/widgets//calenderPage/schedule_card.dart';
import 'widgets//calenderPage/today_banner.dart';
import 'style/colors.dart';
import 'package:security/widgets/homePage/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'splash_screen.dart';
import 'package:flutter/rendering.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintSizeEnabled = false; // Ensure this is false

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  runApp(
    MaterialApp(
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            return SplashScreen();
          }
      ),
    )
  );
}