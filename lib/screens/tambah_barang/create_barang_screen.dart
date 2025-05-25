import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventaris/screens/tambah_barang/kategori_barang.dart';
import 'package:inventaris/screens/tambah_barang/image_picker_barang.dart';

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

  void _setImageFile(File? image) {
    setState(() {
      _imageFile = image;
    });
  }

  void _submitForm() async {
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
        if (_kategori == 'Barang') "namaBarang": _namaBarangController.text,
      };

      await FirebaseFirestore.instance.collection('barang').add(dataBaru);
      if (!mounted) return;
      Navigator.pop(context, dataBaru);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil ditambahkan')),
      );
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
                      ImagePickerBarang(
                        imageFile: _imageFile,
                        onImageSelected: _setImageFile,
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
                      KategoriBarang(
                        kategori: _kategori,
                        judulController: _judulController,
                        penerbitController: _penerbitController,
                        kelasController: _kelasController,
                        jurusanController: _jurusanController,
                        namaBarangController: _namaBarangController,
                      ),
                      TextFormField(
                        controller: _jumlahController,
                        decoration: const InputDecoration(labelText: 'Jumlah'),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Jumlah tidak boleh kosong'
                                    : null,
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
            FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _submitForm,
              child: const Icon(Icons.add, color: Colors.blue),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
