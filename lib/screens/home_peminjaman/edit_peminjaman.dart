import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditPeminjamanScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String documentId;

  const EditPeminjamanScreen({
    Key? key,
    required this.data,
    required this.documentId,
  }) : super(key: key);

  @override
  State<EditPeminjamanScreen> createState() => _EditPeminjamanScreenState();
}

class _EditPeminjamanScreenState extends State<EditPeminjamanScreen> {
  final _formKey = GlobalKey<FormState>();

  String? kategori;
  String? nama;
  String? jurusan;
  int? jumlahPinjam;
  DateTime? tanggalPinjam;
  DateTime? tanggalKembali;

  String? barangKategori;
  String? judul;
  String? penerbit;
  String? kelas;
  String? jurusanBuku;
  int? jumlahBarang;
  String? asal;

  @override
  void initState() {
    super.initState();
    final data = widget.data;

    kategori = data['kategori'];
    nama = data['nama'];
    jurusan = data['jurusan'];
    jumlahPinjam = data['jumlahPinjam'];
    tanggalPinjam = (data['tanggalPinjam'] as Timestamp).toDate();
    tanggalKembali = (data['tanggalKembali'] as Timestamp).toDate();

    final barang = data['barangDipinjam'] ?? {};
    barangKategori = barang['kategori'];
    if (barangKategori == 'Buku') {
      judul = barang['judul'];
      penerbit = barang['penerbit'];
      kelas = barang['kelas'];
      jurusanBuku = barang['jurusan'];
      jumlahBarang = barang['jumlah'];
      asal = barang['asal'];
    } else {
      judul = barang['namaBarang'];
      jumlahBarang = barang['jumlah'];
      asal = barang['asal'];
    }
  }

  Future<void> _selectDate(BuildContext context, bool isPinjam) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPinjam ? tanggalPinjam! : tanggalKembali!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isPinjam) {
          tanggalPinjam = picked;
        } else {
          tanggalKembali = picked;
        }
      });
    }
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(border: InputBorder.none),
      value: selectedValue,
      hint: Text(hint),
      onChanged: onChanged,
      items:
          items.map((value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
    );
  }

  Widget _buildTextField(
    String label,
    String? initialValue,
    Function(String) onChanged,
  ) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.clear),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.all(16),
                width: 330,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildDropdown(
                          "Pilih Kategori",
                          ['Guru', 'Murid'],
                          kategori,
                          (val) => setState(() => kategori = val),
                        ),
                        _buildTextField("Nama Guru", nama, (val) => nama = val),
                        _buildTextField(
                          "Jurusan",
                          jurusan,
                          (val) => jurusan = val,
                        ),
                        _buildTextField(
                          "Jumlah",
                          jumlahPinjam?.toString(),
                          (val) => jumlahPinjam = int.tryParse(val),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Tanggal Peminjaman: ${DateFormat.yMd().format(tanggalPinjam!)}",
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context, true),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Tanggal Pengembalian: ${DateFormat.yMd().format(tanggalKembali!)}",
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context, false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '"Info buku/barang yang dipinjam"',
                          style: TextStyle(color: Colors.blue),
                        ),
                        _buildDropdown(
                          "Pilih Kategori",
                          ['Buku', 'Barang'],
                          barangKategori,
                          (val) => setState(() => barangKategori = val),
                        ),
                        if (barangKategori == 'Buku') ...[
                          _buildTextField("Judul", judul, (val) => judul = val),
                          _buildTextField(
                            "Penerbit",
                            penerbit,
                            (val) => penerbit = val,
                          ),
                          _buildTextField("Kelas", kelas, (val) => kelas = val),
                          _buildTextField(
                            "Jurusan",
                            jurusanBuku,
                            (val) => jurusanBuku = val,
                          ),
                        ] else ...[
                          _buildTextField(
                            "Nama Barang",
                            judul,
                            (val) => judul = val,
                          ),
                        ],
                        _buildTextField(
                          "Jumlah",
                          jumlahBarang?.toString(),
                          (val) => jumlahBarang = int.tryParse(val),
                        ),
                        _buildDropdown(
                          "Pemilik",
                          ['Sekolah', 'Pemerintah'],
                          asal,
                          (val) => setState(() => asal = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.check, color: Colors.blue),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
