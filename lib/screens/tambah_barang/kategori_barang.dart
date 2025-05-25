import 'package:flutter/material.dart';

class KategoriBarang extends StatelessWidget {
  final String kategori;
  final TextEditingController judulController;
  final TextEditingController penerbitController;
  final TextEditingController kelasController;
  final TextEditingController jurusanController;
  final TextEditingController namaBarangController;

  const KategoriBarang({
    Key? key,
    required this.kategori,
    required this.judulController,
    required this.penerbitController,
    required this.kelasController,
    required this.jurusanController,
    required this.namaBarangController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kategori == 'Buku') {
      return Column(
        children: [
          TextFormField(
            controller: judulController,
            decoration: const InputDecoration(labelText: 'Judul'),
          ),
          TextFormField(
            controller: penerbitController,
            decoration: const InputDecoration(labelText: 'Penerbit'),
          ),
          TextFormField(
            controller: kelasController,
            decoration: const InputDecoration(labelText: 'Kelas'),
          ),
          TextFormField(
            controller: jurusanController,
            decoration: const InputDecoration(labelText: 'Jurusan'),
          ),
        ],
      );
    } else {
      return TextFormField(
        controller: namaBarangController,
        decoration: const InputDecoration(labelText: 'Nama Barang'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Nama Barang tidak boleh kosong';
          }
          return null;
        },
      );
    }
  }
}
