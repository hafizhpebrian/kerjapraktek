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
  String _asal = 'Sekolah';

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _namaBarangController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _penerbitController = TextEditingController();
  final TextEditingController _kelasController = TextEditingController();
  final TextEditingController _jurusanController = TextEditingController();

  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
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
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _pickImage(ImageSource.camera),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _pickImage(ImageSource.gallery),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.photo,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _imageFile == null
                              ? const Text('Belum ada gambar')
                              : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _imageFile!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _kategori,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Kategori',
                        ),
                        items:
                            ['Buku', 'Barang']
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() => _kategori = value!),
                      ),

                      if (_kategori == 'Buku') ...[
                        TextFormField(
                          controller: _judulController,
                          decoration: const InputDecoration(labelText: 'Judul'),
                        ),
                        TextFormField(
                          controller: _penerbitController,
                          decoration: const InputDecoration(
                            labelText: 'Penerbit',
                          ),
                        ),
                        TextFormField(
                          controller: _kelasController,
                          decoration: const InputDecoration(labelText: 'Kelas'),
                        ),
                        TextFormField(
                          controller: _jurusanController,
                          decoration: const InputDecoration(
                            labelText: 'Jurusan',
                          ),
                        ),
                      ],

                      if (_kategori == 'Barang') ...[
                        TextFormField(
                          controller: _namaBarangController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Barang',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama Barang tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ],

                      TextFormField(
                        controller: _jumlahController,
                        decoration: const InputDecoration(labelText: 'Jumlah'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      DropdownButtonFormField<String>(
                        value: _asal,
                        decoration: const InputDecoration(labelText: 'Pemilik'),
                        items:
                            ['Sekolah', 'Pemerintah']
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) => setState(() => _asal = value!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ...existing code...
            FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final dataBaru = {
                    "kategori": _kategori,
                    "judul": _judulController.text,
                    "jumlah": int.tryParse(_jumlahController.text) ?? 0,
                    "penerbit": _penerbitController.text,
                    "kelas": _kelasController.text,
                    "jurusan": _jurusanController.text,
                    "asal": _asal,
                    "imagePath": _imageFile?.path,
                    if (_kategori == 'Barang')
                      "namaBarang": _namaBarangController.text,
                  };
                  await FirebaseFirestore.instance
                      .collection('barang')
                      .add(dataBaru);
                  if (!mounted) return;
                  Navigator.pop(context, dataBaru);
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
