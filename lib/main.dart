import 'package:flutter/material.dart';
import 'package:mobile_dev_project/screens/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Bloc/main_bloc.dart';
import 'Bloc/theme_bloc.dart';
import 'Screens/cards_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => MainBloc()),
      BlocProvider(create: (context) => ThemeBloc()),
    ], child: MaterialApp(
      title: 'Caft App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(), // Show LoginScreen initially
    ));
  }
}
