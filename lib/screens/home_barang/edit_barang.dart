import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventaris/screens/tambah_barang/image_picker_barang.dart'; // Pastikan path sesuai struktur proyekmu

class EditBarang extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> barang;

  const EditBarang({Key? key, required this.documentId, required this.barang})
    : super(key: key);

  @override
  State<EditBarang> createState() => _EditBarangState();
}

class _EditBarangState extends State<EditBarang> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _judulController;
  late TextEditingController _kelasController;
  late TextEditingController _jurusanController;
  late TextEditingController _penerbitController;
  late TextEditingController _namaBarangController;
  late TextEditingController _asalController;
  late TextEditingController _jumlahController;

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(
      text: widget.barang['judul'] ?? '',
    );
    _kelasController = TextEditingController(
      text: widget.barang['kelas'] ?? '',
    );
    _jurusanController = TextEditingController(
      text: widget.barang['jurusan'] ?? '',
    );
    _penerbitController = TextEditingController(
      text: widget.barang['penerbit'] ?? '',
    );
    _namaBarangController = TextEditingController(
      text: widget.barang['namaBarang'] ?? '',
    );
    _asalController = TextEditingController(text: widget.barang['asal'] ?? '');
    _jumlahController = TextEditingController(
      text: widget.barang['jumlah'].toString(),
    );

    // Inisialisasi gambar jika sudah ada sebelumnya
    if (widget.barang['imagePath'] != null) {
      final file = File(widget.barang['imagePath']);
      if (file.existsSync()) {
        _imageFile = file;
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _kelasController.dispose();
    _jurusanController.dispose();
    _penerbitController.dispose();
    _namaBarangController.dispose();
    _asalController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  void _updateBarang() async {
    if (_formKey.currentState!.validate()) {
      final data = <String, dynamic>{
        'jumlah': int.tryParse(_jumlahController.text) ?? 0,
        'imagePath': _imageFile?.path ?? widget.barang['imagePath'],
      };

      if (widget.barang['kategori'] == 'Buku') {
        data.addAll({
          'judul': _judulController.text,
          'kelas': _kelasController.text,
          'jurusan': _jurusanController.text,
          'penerbit': _penerbitController.text,
          'asal': _asalController.text,
        });
      } else {
        data.addAll({
          'namaBarang': _namaBarangController.text,
          'asal': _asalController.text,
        });
      }

      await FirebaseFirestore.instance
          .collection('barang')
          .doc(widget.documentId)
          .update(data);

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(),
        ),
        validator:
            (value) =>
                (value == null || value.isEmpty) ? 'Tidak boleh kosong' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBuku = widget.barang['kategori'] == 'Buku';
    const primaryColor = Colors.blue;

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        ImagePickerBarang(
                          imageFile: _imageFile,
                          onImageSelected: (file) {
                            setState(() {
                              _imageFile = file;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            isBuku ? "Buku" : "Barang",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isBuku) ...[
                          _buildTextField(_judulController, 'Judul'),
                          _buildTextField(_penerbitController, 'Penerbit'),
                          _buildTextField(_kelasController, 'Kelas'),
                          _buildTextField(_jurusanController, 'Jurusan'),
                          _buildTextField(
                            _jumlahController,
                            'Jumlah',
                            isNumber: true,
                          ),
                          _buildTextField(_asalController, 'Asal'),
                        ] else ...[
                          _buildTextField(_namaBarangController, 'Nama Barang'),
                          _buildTextField(
                            _jumlahController,
                            'Jumlah',
                            isNumber: true,
                          ),
                          _buildTextField(_asalController, 'Asal'),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _updateBarang,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
