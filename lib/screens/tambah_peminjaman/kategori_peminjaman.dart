import 'package:flutter/material.dart';

class KategoriPeminjaman extends StatelessWidget {
  final String kategori;
  final TextEditingController namaController;
  final TextEditingController jurusanController;
  final TextEditingController kelasController;
  final TextEditingController jumlahController;
  final TextEditingController tanggalPinjamController;
  final TextEditingController tanggalKembaliController;

  const KategoriPeminjaman({
    super.key,
    required this.kategori,
    required this.namaController,
    required this.jurusanController,
    required this.kelasController,
    required this.jumlahController,
    required this.tanggalPinjamController,
    required this.tanggalKembaliController,
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
          controller: jumlahController,
          decoration: const InputDecoration(labelText: 'Jumlah'),
          keyboardType: TextInputType.number,
          validator:
              (value) =>
                  (value == null || value.isEmpty)
                      ? 'Jumlah tidak boleh kosong'
                      : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: tanggalPinjamController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Tanggal Peminjaman',
            suffixIcon: Icon(Icons.calendar_today, color: Colors.blue[300]),
            border: const UnderlineInputBorder(),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              tanggalPinjamController.text =
                  "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
            }
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: tanggalKembaliController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Tanggal Pengembalian',
            suffixIcon: Icon(Icons.calendar_today, color: Colors.blue[300]),
            border: const UnderlineInputBorder(),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              tanggalKembaliController.text =
                  "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
            }
          },
        ),
      ],
    );
  }
}
