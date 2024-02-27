import 'package:flutter/material.dart';

import 'ui/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHESS APP',
      theme: ThemeData(
        primaryColor: Colors.green,
        secondaryHeaderColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
}
