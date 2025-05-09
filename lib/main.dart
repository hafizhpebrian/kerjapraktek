import 'package:flutter/material.dart';
import 'package:inventaris/screen/screen_login.dart';
import 'package:inventaris/screen/screen_registrasi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ScreenLogin(),
    );
  }
}
