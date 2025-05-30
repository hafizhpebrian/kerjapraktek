import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventaris/screens/tambah_peminjaman/kategori_peminjaman.dart';

class TambahPeminjamanScreen extends StatefulWidget {
  final Map<String, dynamic>? barang;
  final String? documentId;

  const TambahPeminjamanScreen({Key? key, this.barang, this.documentId})
    : super(key: key);

  @override
  State<TambahPeminjamanScreen> createState() => _TambahPeminjamanScreenState();
}

class _TambahPeminjamanScreenState extends State<TambahPeminjamanScreen> {
  final _formKey = GlobalKey<FormState>();
  String _kategori = 'Guru';

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jurusanController = TextEditingController();
  final TextEditingController _kelasController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _tanggalPinjamController =
      TextEditingController();
  final TextEditingController _tanggalKembaliController =
      TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "kategori": _kategori,
        "nama": _namaController.text,
        "jurusan": _jurusanController.text,
        if (_kategori == 'Murid') "kelas": _kelasController.text,
        "jumlah": int.tryParse(_jumlahController.text) ?? 0,
        "tanggalPinjam": _tanggalPinjamController.text,
        "tanggalKembali": _tanggalKembaliController.text,
        "barangDipinjam": widget.barang ?? {},
      };

      await FirebaseFirestore.instance.collection('peminjaman').add(data);
      if (!mounted) return;
      Navigator.pop(context, data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data peminjaman berhasil ditambahkan')),
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Image.asset(
                    'assets/logo.png', // Ganti dengan path asset sebenarnya
                    height: 40,
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _kategori,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Kategori',
                        ),
                        items:
                            ['Guru', 'Murid']
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
                      const SizedBox(height: 16),
                      KategoriPeminjaman(
                        kategori: _kategori,
                        namaController: _namaController,
                        jurusanController: _jurusanController,
                        kelasController: _kelasController,
                        jumlahController: _jumlahController,
                        tanggalPinjamController: _tanggalPinjamController,
                        tanggalKembaliController: _tanggalKembaliController,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          "*Info buku/barang yang dipinjam*",
                          style: TextStyle(
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.barang != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.barang!['kategori'] == 'Buku') ...[
                              if (widget.barang!['judul'] != null)
                                Text("Judul : ${widget.barang!['judul']}"),
                              if (widget.barang!['penerbit'] != null)
                                Text(
                                  "Penerbit : ${widget.barang!['penerbit']}",
                                ),
                              if (widget.barang!['kelas'] != null)
                                Text("Kelas : ${widget.barang!['kelas']}"),
                              if (widget.barang!['jurusan'] != null)
                                Text("Jurusan : ${widget.barang!['jurusan']}"),
                              Text("Jumlah : ${widget.barang!['jumlah']}"),
                              if (widget.barang!['asal'] != null)
                                Text("Asal : ${widget.barang!['asal']}"),
                            ] else ...[
                              if (widget.barang!['namaBarang'] != null)
                                Text(
                                  "Nama Barang : ${widget.barang!['namaBarang']}",
                                ),
                              Text("Jumlah : ${widget.barang!['jumlah']}"),
                              if (widget.barang!['asal'] != null)
                                Text("Asal : ${widget.barang!['asal']}"),
                            ],
                          ],
                        )
                      else
                        const Text("Tidak ada barang dipilih."),
                    ],
                  ),
                ),
              ),
            ),

            // Floating Action Button
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: _submitForm,
                child: const Icon(Icons.add, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
