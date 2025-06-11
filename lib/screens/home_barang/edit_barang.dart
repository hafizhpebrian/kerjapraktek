import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventaris/screens/image_picker_barang.dart';

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
  late TextEditingController _jumlahController;

  late String _selectedAsal;
  final List<String> _asalOptions = ['Sekolah', 'Pemerintah'];

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
    _jumlahController = TextEditingController(
      text: widget.barang['jumlah'].toString(),
    );
    _selectedAsal = widget.barang['asal'] ?? 'Sekolah';

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
    _jumlahController.dispose();
    super.dispose();
  }

  void _updateBarang() async {
    if (_formKey.currentState!.validate()) {
      final updatedBarangFields = <String, dynamic>{
        'jumlah': int.tryParse(_jumlahController.text) ?? 0,
        'asal': _selectedAsal,
        'imagePath': _imageFile?.path ?? widget.barang['imagePath'],
      };

      if (widget.barang['kategori'] == 'Buku') {
        updatedBarangFields.addAll({
          'judul': _judulController.text,
          'kelas': _kelasController.text,
          'jurusan': _jurusanController.text,
          'penerbit': _penerbitController.text,
        });
      } else {
        updatedBarangFields.addAll({'namaBarang': _namaBarangController.text});
      }

      await FirebaseFirestore.instance
          .collection('barang')
          .doc(widget.documentId)
          .update(updatedBarangFields);

      DocumentSnapshot barangSnapshot =
          await FirebaseFirestore.instance
              .collection('barang')
              .doc(widget.documentId)
              .get();

      if (barangSnapshot.exists) {
        final fullUpdatedBarangData =
            barangSnapshot.data() as Map<String, dynamic>;

        // Update data 'barangDipinjam' di semua dokumen 'peminjaman' yang terkait
        QuerySnapshot peminjamanDocs =
            await FirebaseFirestore.instance
                .collection('peminjaman')
                .where('barangId_ref', isEqualTo: widget.documentId)
                .get();

        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (var doc in peminjamanDocs.docs) {
          batch.update(doc.reference, {
            'barangDipinjam': fullUpdatedBarangData,
          });
        }
        await batch.commit();
      }
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

  Widget _buildDropdownAsal() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: _selectedAsal,
        decoration: const InputDecoration(
          labelText: 'Asal',
          border: UnderlineInputBorder(),
        ),
        items:
            _asalOptions.map((asal) {
              return DropdownMenuItem<String>(value: asal, child: Text(asal));
            }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedAsal = value;
            });
          }
        },
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
                          _buildDropdownAsal(),
                        ] else ...[
                          _buildTextField(_namaBarangController, 'Nama Barang'),
                          _buildTextField(
                            _jumlahController,
                            'Jumlah',
                            isNumber: true,
                          ),
                          _buildDropdownAsal(),
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
