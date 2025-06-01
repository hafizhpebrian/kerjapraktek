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
  final TextEditingController _jumlahPinjamController = TextEditingController();
  final TextEditingController _tanggalPinjamController =
      TextEditingController();
  final TextEditingController _tanggalKembaliController =
      TextEditingController();

  DateTime? _tanggalPinjam;
  DateTime? _tanggalKembali;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_tanggalPinjam == null || _tanggalKembali == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih tanggal pinjam dan kembali'),
          ),
        );
        return;
      }

      final data = {
        "kategori": _kategori,
        "nama": _namaController.text,
        "jurusan": _jurusanController.text,
        if (_kategori == 'Murid') "kelas": _kelasController.text,
        "jumlahPinjam": int.tryParse(_jumlahPinjamController.text) ?? 0,
        "tanggalPinjam": Timestamp.fromDate(_tanggalPinjam!),
        "tanggalKembali": Timestamp.fromDate(_tanggalKembali!),
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

  Future<void> _selectTanggal(
    BuildContext context,
    TextEditingController controller,
    bool isPinjam,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        if (isPinjam) {
          _tanggalPinjam = picked;
        } else {
          _tanggalKembali = picked;
        }
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
                  Image.asset('assets/logo.png', height: 40),
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
                        jumlahPinjamController: _jumlahPinjamController,
                        tanggalPinjamController: _tanggalPinjamController,
                        tanggalKembaliController: _tanggalKembaliController,
                        onSelectTanggal: _selectTanggal,
                      ),

                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          widget.barang == null
                              ? "*Info buku/barang yang dipinjam*"
                              : widget.barang!['kategori'] == 'Buku'
                              ? "*Info buku yang dipinjam*"
                              : "*Info barang yang dipinjam*",
                          style: const TextStyle(
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
