import 'package:flutter/material.dart';
import 'package:school_net_mobil_app/screen/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SchoolNet',
      debugShowCheckedModeBanner: false, 
      home: const LoginScreen(), 
    );
  }
}  
