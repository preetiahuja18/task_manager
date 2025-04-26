import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/home_screen.dart';
import 'package:task_app/task_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title:'Task App',
        home: HomeScreen(),
      ),
    );
  }
}

