import 'package:flutter/material.dart';
import 'package:mobile_dev_project/screens/login_screen.dart'; // Import your LoginScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caft App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(), // Show LoginScreen initially
    );
  }
}
