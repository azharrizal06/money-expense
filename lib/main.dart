import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_expense/home/home_screen.dart';

import 'home/bycalender.dart';
// import 'package:money_expense/DB helper/db_helper.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // resetDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeScreen(),
    );
  }
}
