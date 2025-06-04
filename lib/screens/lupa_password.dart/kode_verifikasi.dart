import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventaris/screens/lupa_password.dart/ubah_password.dart';

class KodeVerifikasi extends StatefulWidget {
  final String email;
  const KodeVerifikasi({required this.email});

  @override
  State<KodeVerifikasi> createState() => _KodeVerifikasiState();
}

class _KodeVerifikasiState extends State<KodeVerifikasi> {
  final TextEditingController otpController = TextEditingController();
  String? error;

  Future<void> verifyOtp() async {
    final doc = await FirebaseFirestore.instance.collection('password_reset').doc(widget.email).get();

    if (!doc.exists) {
      setState(() => error = 'Kode tidak ditemukan.');
      return;
    }

    final data = doc.data();
    final kodeBenar = data?['otp'];
    final timestamp = data?['timestamp'];

    // Opsional: Expired check (5 menit)
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - timestamp > 300000) {
      setState(() => error = 'Kode sudah kadaluarsa');
      return;
    }

    if (otpController.text.trim() == kodeBenar) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UbahPassword(email: widget.email),
        ),
      );
    } else {
      setState(() => error = 'Kode salah');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verifikasi Kode')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Kode OTP'),
            ),
            if (error != null)
              Text(error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyOtp,
              child: Text('Verifikasi'),
            ),
          ],
        ),
      ),
    );
  }
}
