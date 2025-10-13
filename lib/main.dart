import 'package:do3things/Screens/MainScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Do 3 Things',
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}
