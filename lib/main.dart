import 'package:flutter/material.dart';
import 'package:security/calendar_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'schedule_card.dart';
import 'today_banner.dart';
import 'colors.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  runApp(
    MaterialApp(
      home: CalendarPage(),
    )
  );
}