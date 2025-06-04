import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UbahPassword extends StatefulWidget {
  final String email;
  const UbahPassword({required this.email});

  @override
  State<UbahPassword> createState() => _UbahPasswordState();
}

class _UbahPasswordState extends State<UbahPassword> {
  final TextEditingController passwordController = TextEditingController();

  Future<void> updatePassword() async {
    try {
      final user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.email,
        password: 'TEMPORARY_PASSWORD_HERE',
      ))
          .user;

      await user!.updatePassword(passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password berhasil diubah')));

      // Sign out user after change
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ubah Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password baru'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updatePassword,
              child: Text('Ubah Password'),
            ),
          ],
        ),
      ),
    );
  }
}
