import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahBarangScreen extends StatefulWidget {
  const TambahBarangScreen({Key? key}) : super(key: key);

  @override
  State<TambahBarangScreen> createState() => _TambahBarangScreenState();
}

class _TambahBarangScreenState extends State<TambahBarangScreen> {
  final _formKey = GlobalKey<FormState>();

  String _kategori = 'Buku';
  String _pemilik = 'Sekolah';

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _dipinjamController = TextEditingController();
  final TextEditingController _penerbitController = TextEditingController();
  final TextEditingController _kelasController = TextEditingController();
  final TextEditingController _jurusanController = TextEditingController();

  File? _imageFile;

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue;

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/logo.png',
                    height: 30,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      GestureDetector(
                        onTap: _pickImageFromCamera,
                        child: _imageFile == null
                            ? const Icon(Icons.image, size: 40, color: Colors.blue)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _imageFile!,
                                  width: 40,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Dropdown kategori
                      DropdownButtonFormField<String>(
                        value: _kategori,
                        decoration: const InputDecoration(labelText: 'Pilih Kategori'),
                        items: ['Buku', 'Barang']
                            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                            .toList(),
                        onChanged: (value) => setState(() => _kategori = value!),
                      ),

                      if (_kategori == 'Buku') ...[
                        TextFormField(
                          controller: _judulController,
                          decoration: const InputDecoration(labelText: 'Judul'),
                        ),
                        TextFormField(
                          controller: _penerbitController,
                          decoration: const InputDecoration(labelText: 'Penerbit'),
                        ),
                        TextFormField(
                          controller: _kelasController,
                          decoration: const InputDecoration(labelText: 'Kelas'),
                        ),
                        TextFormField(
                          controller: _jurusanController,
                          decoration: const InputDecoration(labelText: 'Jurusan'),
                        ),
                      ],

                      TextFormField(
                        controller: _jumlahController,
                        decoration: const InputDecoration(labelText: 'Jumlah'),
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        controller: _dipinjamController,
                        decoration: const InputDecoration(labelText: 'Dipinjam'),
                        keyboardType: TextInputType.number,
                      ),

                      DropdownButtonFormField<String>(
                        value: _pemilik,
                        decoration: const InputDecoration(labelText: 'Pemilik'),
                        items: ['Sekolah', 'Pemerintah']
                            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                            .toList(),
                        onChanged: (value) => setState(() => _pemilik = value!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await FirebaseFirestore.instance.collection('barang').add({
                    "kategori": _kategori,
                    "judul": _judulController.text,
                    "jumlah": int.tryParse(_jumlahController.text) ?? 0,
                    "dipinjam": int.tryParse(_dipinjamController.text) ?? 0,
                    "penerbit": _penerbitController.text,
                    "kelas": _kelasController.text,
                    "jurusan": _jurusanController.text,
                    "pemilik": _pemilik,
                    "imagePath": _imageFile?.path,
                  });
                  if (!mounted) return; // Tambahkan ini
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data berhasil ditambahkan')),
                  );
                }
              },
              child: const Icon(Icons.add, color: Colors.blue),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}