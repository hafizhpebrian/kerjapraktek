import 'package:flutter/material.dart';

class KategoriPeminjaman extends StatelessWidget {
  final String kategori;
  final TextEditingController namaController;
  final TextEditingController jurusanController;
  final TextEditingController kelasController;
  final TextEditingController jumlahPinjamController;
  final TextEditingController tanggalPinjamController;
  final TextEditingController tanggalKembaliController;
  final void Function(BuildContext, TextEditingController, bool)
  onSelectTanggal;

  const KategoriPeminjaman({
    super.key,
    required this.kategori,
    required this.namaController,
    required this.jurusanController,
    required this.kelasController,
    required this.jumlahPinjamController,
    required this.tanggalPinjamController,
    required this.tanggalKembaliController,
    required this.onSelectTanggal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: namaController,
          decoration: const InputDecoration(labelText: 'Nama'),
          validator:
              (value) =>
                  (value == null || value.isEmpty)
                      ? 'Nama tidak boleh kosong'
                      : null,
        ),
        TextFormField(
          controller: jurusanController,
          decoration: const InputDecoration(labelText: 'Jurusan'),
        ),
        if (kategori == 'Murid')
          TextFormField(
            controller: kelasController,
            decoration: const InputDecoration(labelText: 'Kelas'),
          ),
        TextFormField(
          controller: jumlahPinjamController,
          decoration: const InputDecoration(labelText: 'Jumlah pinjam'),
          keyboardType: TextInputType.number,
          validator:
              (value) =>
                  (value == null || value.isEmpty)
                      ? 'Jumlah tidak boleh kosong'
                      : null,
        ),
        TextFormField(
          controller: tanggalPinjamController,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Tanggal Pinjam',
            suffixIcon: Icon(
              Icons.calendar_today,
            ), // Ganti prefixIcon ke suffixIcon
          ),
          onTap: () => onSelectTanggal(context, tanggalPinjamController, true),
          validator:
              (value) =>
                  (value == null || value.isEmpty)
                      ? 'Tanggal pinjam wajib diisi'
                      : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: tanggalKembaliController,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Tanggal Kembali',
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap:
              () => onSelectTanggal(context, tanggalKembaliController, false),
          validator:
              (value) =>
                  (value == null || value.isEmpty)
                      ? 'Tanggal kembali wajib diisi'
                      : null,
        ),
      ],
    );
  }
}
