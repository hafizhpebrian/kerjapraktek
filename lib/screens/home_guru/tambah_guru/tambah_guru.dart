import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahGuruScreen extends StatefulWidget {
  const TambahGuruScreen({Key? key}) : super(key: key);

  @override
  State<TambahGuruScreen> createState() => _TambahGuruScreenState();
}

class _TambahGuruScreenState extends State<TambahGuruScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nomorIndukController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomorHpController = TextEditingController();
  final TextEditingController _jurusanController = TextEditingController();

  String _kategori = 'Guru';

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final docRef = FirebaseFirestore.instance.collection('guru').doc();

      final dataGuru = {
        "kategori": _kategori,
        "nama": _namaController.text,
        "nomorInduk": _nomorIndukController.text,
        "email": _emailController.text,
        "nomorHp": _nomorHpController.text,
        "jurusan": _jurusanController.text,
        "createdAt": FieldValue.serverTimestamp(),
      };

      try {
        await docRef.set(dataGuru);
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data guru berhasil ditambahkan')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menambahkan data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Image.asset('assets/logo.png', width: 50),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _kategori,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: _namaController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Guru',
                              ),
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Nama tidak boleh kosong'
                                          : null,
                            ),
                            TextFormField(
                              controller: _nomorIndukController,
                              decoration: const InputDecoration(
                                labelText: 'Nomor Induk Yayasan',
                              ),
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Nomor Induk tidak boleh kosong'
                                          : null,
                            ),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Email tidak boleh kosong'
                                          : null,
                            ),
                            TextFormField(
                              controller: _nomorHpController,
                              decoration: const InputDecoration(
                                labelText: 'Nomor handphone',
                              ),
                              keyboardType: TextInputType.phone,
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Nomor HP tidak boleh kosong'
                                          : null,
                            ),
                            TextFormField(
                              controller: _jurusanController,
                              decoration: const InputDecoration(
                                labelText: 'Jurusan',
                              ),
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Jurusan tidak boleh kosong'
                                          : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FloatingActionButton(
                    onPressed: _submitForm,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
