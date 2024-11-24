import 'package:flutter/material.dart';
import 'package:security/screens/calendar_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:security/utils/calenderPage/schedule_card.dart';
import 'utils/calenderPage/today_banner.dart';
import 'style/colors.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  runApp(
    MaterialApp(
      home: CalendarPage(),
    )
  );
}