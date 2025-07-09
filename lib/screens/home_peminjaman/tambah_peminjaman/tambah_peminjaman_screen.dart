import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'kategori_peminjaman.dart';

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
  String _kategoriPeminjam = 'Guru';
  String _kategoriBarang = 'Buku';
  String? userRole;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nomorIndukController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomorHpController = TextEditingController();
  final TextEditingController _jurusanController = TextEditingController();
  final TextEditingController _kelasController = TextEditingController();
  final TextEditingController _jumlahPinjamController = TextEditingController();
  final TextEditingController _tanggalPinjamController =
      TextEditingController();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _penerbitController = TextEditingController();
  final TextEditingController _kelasBarangController = TextEditingController();
  final TextEditingController _jurusanBarangController =
      TextEditingController();
  final TextEditingController _jumlahBarangController = TextEditingController();
  final TextEditingController _asalController = TextEditingController();
  final TextEditingController _namaBarangController = TextEditingController();

  DateTime? _tanggalPinjam;

  @override
  void initState() {
    super.initState();
    _getUserRole();

    _namaController.addListener(() {
      if (_kategoriPeminjam == 'Guru' && _namaController.text.isNotEmpty) {
        _fetchGuruData(_namaController.text);
      }
    });
  }

  Future<void> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        userRole = doc.data()?['role'];
      });
    }
  }

  Future<void> _fetchGuruData(String namaGuru) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('guru')
            .where('nama', isEqualTo: namaGuru)
            .limit(1)
            .get();
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      _jurusanController.text = data['jurusan'] ?? '';
      _nomorIndukController.text = data['nomorInduk'] ?? '';
      _emailController.text = data['email'] ?? '';
      _nomorHpController.text = data['nomorHp'] ?? '';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _tanggalPinjam != null) {
      final existingLoans =
          await FirebaseFirestore.instance
              .collection('peminjaman')
              .where('email', isEqualTo: _emailController.text.trim())
              .where('status', isEqualTo: 'dipinjam')
              .get();

      if (existingLoans.docs.length >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maksimal peminjaman adalah 3 barang/buku'),
          ),
        );
        return;
      }

      DocumentReference? guruRef;
      if (_kategoriPeminjam == 'Guru') {
        final query =
            await FirebaseFirestore.instance
                .collection('guru')
                .where('nama', isEqualTo: _namaController.text)
                .limit(1)
                .get();
        if (query.docs.isNotEmpty) {
          guruRef = query.docs.first.reference;
        }
      }

      final data = {
        "uid": FirebaseAuth.instance.currentUser?.uid,
        "kategori": _kategoriPeminjam,
        "nama": _namaController.text,
        "nomorInduk": _nomorIndukController.text,
        "email": _emailController.text,
        "nomorHp": _nomorHpController.text,
        "jurusan": _jurusanController.text,
        if (_kategoriPeminjam == 'Siswa') "kelas": _kelasController.text,
        "jumlahPinjam": int.tryParse(_jumlahPinjamController.text) ?? 0,
        "tanggalPinjam": Timestamp.fromDate(_tanggalPinjam!),
        "createdAt": FieldValue.serverTimestamp(),
        "status": "dipinjam",
        if (guruRef != null) "guru_ref": guruRef,
        if (widget.documentId != null)
          "barang_ref": FirebaseFirestore.instance
              .collection('barang')
              .doc(widget.documentId),
        "barangDipinjam": widget.barang ?? _buildBarangData(),
      };

      await FirebaseFirestore.instance.collection('peminjaman').add(data);

      if (!mounted) return;
      Navigator.pop(context, data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data peminjaman berhasil ditambahkan')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal pinjam')),
      );
    }
  }

  Map<String, dynamic> _buildBarangData() {
    return _kategoriBarang == 'Buku'
        ? {
          "kategori": "Buku",
          "judul": _judulController.text,
          "penerbit": _penerbitController.text,
          "kelas": _kelasBarangController.text,
          "jurusan": _jurusanBarangController.text,
          "jumlah": int.tryParse(_jumlahBarangController.text) ?? 0,
          "asal": _asalController.text,
        }
        : {
          "kategori": "Barang",
          "namaBarang": _namaBarangController.text,
          "jumlah": int.tryParse(_jumlahBarangController.text) ?? 0,
          "asal": _asalController.text,
        };
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
        if (isPinjam) _tanggalPinjam = picked;
      });
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator:
            (value) =>
                value == null || value.isEmpty ? 'Tidak boleh kosong' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWakabid = userRole == 'wakabidsarpras';
    final peminjamOptions = isWakabid ? ['Guru', 'Siswa'] : ['Guru'];

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
                      DropdownButtonFormField<String>(
                        value: _kategoriPeminjam,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Kategori Peminjam',
                        ),
                        items:
                            peminjamOptions
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _kategoriPeminjam = value!;
                            if (_kategoriPeminjam == 'Guru') {
                              _kelasController.clear();
                              if (_namaController.text.isNotEmpty) {
                                _fetchGuruData(_namaController.text);
                              }
                            } else if (_kategoriPeminjam == 'Siswa') {
                              _nomorIndukController.clear();
                              _nomorHpController.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      KategoriPeminjaman(
                        kategori: _kategoriPeminjam,
                        namaController: _namaController,
                        jurusanController: _jurusanController,
                        kelasController: _kelasController,
                        nomorIndukController: _nomorIndukController,
                        emailController: _emailController,
                        nomorHpController: _nomorHpController,
                        jumlahPinjamController: _jumlahPinjamController,
                        tanggalPinjamController: _tanggalPinjamController,
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
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.barang != null) ...[
                        if (widget.barang!['kategori'] == 'Buku') ...[
                          Text("Judul : ${widget.barang!['judul']}"),
                          Text("Penulis : ${widget.barang!['penulis']}"),
                          Text("Penerbit : ${widget.barang!['penerbit']}"),
                          Text("Tahun : ${widget.barang!['tahun']}"),
                          Text("Kelas : ${widget.barang!['kelas']}"),
                          Text("Jurusan : ${widget.barang!['jurusan']}"),
                          Text("Jumlah : ${widget.barang!['jumlah']}"),
                          Text("Asal : ${widget.barang!['asal']}"),
                        ] else ...[
                          Text("Nama Barang : ${widget.barang!['namaBarang']}"),
                          Text("Tahun : ${widget.barang!['tahun']}"),
                          Text("Jumlah : ${widget.barang!['jumlah']}"),
                          Text("Asal : ${widget.barang!['asal']}"),
                        ],
                      ] else ...[
                        DropdownButtonFormField<String>(
                          value: _kategoriBarang,
                          decoration: const InputDecoration(
                            labelText: 'Pilih Kategori Barang',
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
                              (value) =>
                                  setState(() => _kategoriBarang = value!),
                        ),
                        const SizedBox(height: 8),
                        if (_kategoriBarang == 'Buku') ...[
                          _buildTextField('Judul', _judulController),
                          _buildTextField('Penerbit', _penerbitController),
                          _buildTextField('Kelas', _kelasBarangController),
                          _buildTextField('Jurusan', _jurusanBarangController),
                          _buildTextField(
                            'Jumlah',
                            _jumlahBarangController,
                            isNumber: true,
                          ),
                        ] else ...[
                          _buildTextField('Nama Barang', _namaBarangController),
                          _buildTextField(
                            'Jumlah',
                            _jumlahBarangController,
                            isNumber: true,
                          ),
                        ],
                        DropdownButtonFormField<String>(
                          value:
                              _asalController.text.isNotEmpty
                                  ? _asalController.text
                                  : null,
                          decoration: const InputDecoration(labelText: 'Asal'),
                          items:
                              ['Pemerintah', 'Sekolah']
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) =>
                                  setState(() => _asalController.text = value!),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Silakan pilih asal barang'
                                      : null,
                        ),
                      ],
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
                child: const Icon(Icons.add, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
