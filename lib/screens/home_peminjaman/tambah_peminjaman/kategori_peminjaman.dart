import 'package:flutter/material.dart';

class KategoriPeminjaman extends StatelessWidget {
  final String kategori;
  final TextEditingController namaController;
  final TextEditingController jurusanController;
  final TextEditingController kelasController;
  final TextEditingController nomorIndukController;
  final TextEditingController emailController;
  final TextEditingController nomorHpController;
  final TextEditingController jumlahPinjamController;
  final TextEditingController tanggalPinjamController;
  final Function onSelectTanggal;

  const KategoriPeminjaman({
    Key? key,
    required this.kategori,
    required this.namaController,
    required this.jurusanController,
    required this.kelasController,
    required this.nomorIndukController,
    required this.emailController,
    required this.nomorHpController,
    required this.jumlahPinjamController,
    required this.tanggalPinjamController,
    required this.onSelectTanggal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (kategori == 'Guru') ...[
          _buildTextField('Nama Guru', namaController),
          _buildTextField('Nomor Induk Yayasan', nomorIndukController),
          _buildTextField('Email', emailController),
          _buildTextField('Nomor HP', nomorHpController),
          _buildTextField('Jurusan', jurusanController),
        ] else ...[
          _buildTextField('Nama Siswa', namaController),
          _buildTextField('Kelas', kelasController),
          _buildTextField('Jurusan', jurusanController),
          _buildTextField('Email', emailController),
        ],
        _buildTextField(
          'Jumlah Pinjam',
          jumlahPinjamController,
          isNumber: true,
        ),
        GestureDetector(
          onTap: () => onSelectTanggal(context, tanggalPinjamController, true),
          child: AbsorbPointer(
            child: _buildTextField('Tanggal Pinjam', tanggalPinjamController),
          ),
        ),
      ],
    );
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
}
