import 'package:flutter/material.dart';
import 'package:security/screens/calendar_page.dart';
import 'package:security/screens/taskList_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:security/widgets/calenderPage/schedule_card.dart';
import 'widgets/calenderPage/today_banner.dart';
import 'map/map_page.dart';
import 'style/colors.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  runApp(
    MaterialApp(
      home: TaskListScreen(),
    )
  );
}