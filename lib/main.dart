import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo/data/data.dart';
import 'package:todo/screens/home/home.dart';

const taskBoxName = 'tasks';
Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<Task>(taskBoxName);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: primaryColor),
  );
  runApp(const MyApp());
}

final Color primaryColor = Color(0xff794cFF);
final Color secondaryTextColor = Color(0xffAFBED0);
final Color normalPriority = Color(0xffF09819);
final Color lowPriority = Color(0xff3BE1f1);
final Color hightPriority = primaryColor;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = Color(0xff1D2830);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: secondaryTextColor),
          iconColor: secondaryTextColor,
          border: InputBorder.none,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          TextTheme(titleLarge: TextStyle(fontWeight: FontWeight.bold)),
        ),
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          primaryContainer: Color(0xfff5c0aff),
          surface: Color(0xffff3f5f8),
          onSurface: primaryTextColor,
          onSurfaceVariant: primaryTextColor,
          secondary: primaryColor,
          onSecondary: Colors.white,
        ),
      ),
      home: HomeScreen(),
    );
  }
}
