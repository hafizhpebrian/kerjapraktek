import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditGuruScreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> guruData;

  const EditGuruScreen({
    Key? key,
    required this.documentId,
    required this.guruData,
  }) : super(key: key);

  @override
  State<EditGuruScreen> createState() => _EditGuruScreenState();
}

class _EditGuruScreenState extends State<EditGuruScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _nomorIndukController;
  late TextEditingController _emailController;
  late TextEditingController _nomorHpController;
  late TextEditingController _jurusanController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(
      text: widget.guruData['nama'] ?? '',
    );
    _nomorIndukController = TextEditingController(
      text: widget.guruData['nomorInduk'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.guruData['email'] ?? '',
    );
    _nomorHpController = TextEditingController(
      text: widget.guruData['nomorHp'] ?? '',
    );
    _jurusanController = TextEditingController(
      text: widget.guruData['jurusan'] ?? '',
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nomorIndukController.dispose();
    _emailController.dispose();
    _nomorHpController.dispose();
    _jurusanController.dispose();
    super.dispose();
  }

  Future<void> _updateGuru() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('guru')
          .doc(widget.documentId)
          .update({
            'nama': _namaController.text,
            'nomorInduk': _nomorIndukController.text,
            'email': _emailController.text,
            'nomorHp': _nomorHpController.text,
            'jurusan': _jurusanController.text,
          });
      if (mounted) Navigator.pop(context);
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
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
    const primaryColor = Colors.blueGrey;

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
                        Center(
                          child: Text(
                            "Guru",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(_namaController, 'Nama Guru'),
                        _buildTextField(
                          _nomorIndukController,
                          'Nomor Induk Yayasan',
                        ),
                        _buildTextField(
                          _emailController,
                          'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildTextField(
                          _nomorHpController,
                          'Nomor handphone',
                          keyboardType: TextInputType.phone,
                        ),
                        _buildTextField(_jurusanController, 'Jurusan'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _updateGuru,
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
      ),
    );
  }
}
