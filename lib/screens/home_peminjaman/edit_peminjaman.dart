import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditPeminjamanScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String documentId;

  const EditPeminjamanScreen({
    super.key,
    required this.data,
    required this.documentId,
  });

  @override
  State<EditPeminjamanScreen> createState() => _EditPeminjamanScreenState();
}

class _EditPeminjamanScreenState extends State<EditPeminjamanScreen> {
  String kategoriGuru = 'Guru';
  String kategoriBarang = 'Buku';
  DateTime? tanggalPinjam;
  DateTime? tanggalKembali;

  final _namaController = TextEditingController();
  final _nomorIndukController = TextEditingController();
  final _emailController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _kelasController = TextEditingController();
  final _jurusanController = TextEditingController();
  final _jumlahController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final data = widget.data;

    kategoriGuru = data['kategori'] ?? 'Guru';
    tanggalPinjam = (data['tanggalPinjam'] as Timestamp?)?.toDate();
    tanggalKembali = (data['tanggalKembali'] as Timestamp?)?.toDate();
    _jumlahController.text = data['jumlahPinjam'].toString();

    if (kategoriGuru == 'Murid') {
      _namaController.text = data['nama'] ?? '';
      _kelasController.text = data['kelas'] ?? '';
      _jurusanController.text = data['jurusan'] ?? '';
    } else {
      _namaController.text = data['nama'] ?? '';
      _nomorIndukController.text = data['nomorInduk'] ?? '';
      _emailController.text = data['email'] ?? '';
      _nomorHpController.text = data['nomorHp'] ?? '';
      _jurusanController.text = data['jurusan'] ?? '';
    }

    kategoriBarang = data['kategoriBarang'] ?? 'Buku';
  }

  Future<void> _pilihTanggal(BuildContext context, bool isPinjam) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isPinjam
              ? (tanggalPinjam ?? DateTime.now())
              : (tanggalKembali ?? DateTime.now()),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? selectedDate,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat.yMMMMd().format(selectedDate)
                      : 'Pilih tanggal',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
        const Divider(color: Colors.black),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> updateData() async {
    try {
      final docId = widget.documentId;

      await FirebaseFirestore.instance
          .collection('peminjaman')
          .doc(docId)
          .update({
            'nama': _namaController.text,
            'nomorInduk': _nomorIndukController.text,
            'email': _emailController.text,
            'nomorHp': _nomorHpController.text,
            'kelas': _kelasController.text,
            'jurusan': _jurusanController.text,
            'jumlahPinjam': int.tryParse(_jumlahController.text) ?? 0,
            'tanggalPinjam': tanggalPinjam,
            'tanggalKembali': tanggalKembali,
            'kategori': kategoriGuru,
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil diperbarui')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final DocumentReference? barangRef =
        widget.data['barang_ref'] as DocumentReference?;

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: SafeArea(
        child: Column(
          children: [
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
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DropdownButton<String>(
                        value: kategoriGuru,
                        isExpanded: true,
                        underline: Container(height: 1, color: Colors.black),
                        items:
                            ['Guru', 'Murid']
                                .map(
                                  (k) => DropdownMenuItem(
                                    value: k,
                                    child: Text(k),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => kategoriGuru = val!),
                      ),
                      if (kategoriGuru == 'Siswa') ...[
                        _buildTextField("Nama", _namaController),
                        _buildTextField("Kelas", _kelasController),
                        _buildTextField("Jurusan", _jurusanController),
                      ] else ...[
                        _buildTextField("Nama", _namaController),
                        _buildTextField(
                          "Nomor Induk Yayasan",
                          _nomorIndukController,
                        ),
                        _buildTextField("Nomor HP", _nomorHpController),
                        _buildTextField("Email", _emailController),
                        _buildTextField("Jurusan", _jurusanController),
                      ],
                      _buildTextField(
                        "Jumlah Pinjam",
                        _jumlahController,
                        keyboardType: TextInputType.number,
                      ),
                      _buildDatePicker(
                        "Tanggal Peminjaman",
                        tanggalPinjam,
                        () => _pilihTanggal(context, true),
                      ),
                      _buildDatePicker(
                        "Tanggal Pengembalian",
                        tanggalKembali,
                        () => _pilihTanggal(context, false),
                      ),
                      const Divider(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "*Info buku/barang yang dipinjam*",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (barangRef != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: barangRef.snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (!snapshot.hasData ||
                                  !snapshot.data!.exists) {
                                return const Text(
                                  "Data barang/buku tidak ditemukan.",
                                );
                              }
                              final barang =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              if ((barang["kategori"] ?? "").toLowerCase() ==
                                  "buku") {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Judul Buku : ${barang["judul"] ?? "-"}",
                                    ),
                                    Text(
                                      "Penulis : ${barang["penulis"] ?? "-"}",
                                    ),
                                    Text(
                                      "Penerbit : ${barang["penerbit"] ?? "-"}",
                                    ),
                                    Text("Tahun : ${barang["tahun"] ?? "-"}"),
                                    Text("Kelas : ${barang["kelas"] ?? "-"}"),
                                    Text(
                                      "Jurusan : ${barang["jurusan"] ?? "-"}",
                                    ),
                                    Text("Jumlah : ${barang["jumlah"] ?? "-"}"),
                                    Text("Asal : ${barang["asal"] ?? "-"}"),
                                  ],
                                );
                              } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Nama Barang : ${barang["namaBarang"] ?? "-"}",
                                    ),
                                    Text("Tahun : ${barang["tahun"] ?? "-"}"),
                                    Text("Jumlah : ${barang["jumlah"] ?? "-"}"),
                                    Text("Asal : ${barang["asal"] ?? "-"}"),
                                  ],
                                );
                              }
                            },
                          ),
                        )
                      else
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Data barang/buku tidak ditemukan."),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: updateData,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.black,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
