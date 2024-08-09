import 'package:flutter/material.dart';
import 'package:space_pod/screens/home/home_page_screen.dart';
import 'package:space_pod/utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ConstantStrings.GALAXY,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: ConstantStrings.SIXTY_FOUR,
        scaffoldBackgroundColor: Colors.grey.shade900,
        primaryColor: Colors.grey.shade900,
      ),
      home: const HomePage(),
    );
  }
}
