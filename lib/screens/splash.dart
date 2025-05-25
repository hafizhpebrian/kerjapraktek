import 'package:flutter/material.dart';
import 'dart:async';
import 'package:inventaris/provider/wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Setelah 2 detik, pindah ke Wrapper (atau halaman utama)
    Timer(const Duration(seconds: 2), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const Wrapper()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // warna biru muda sesuai gambar
      body: Center(
        child: Image.asset(
          'assets/logo.png', // ganti sesuai nama file logo kamu di assets
          width: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
