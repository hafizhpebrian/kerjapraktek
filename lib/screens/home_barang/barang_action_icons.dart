import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventaris/screens/home_barang/edit_barang.dart';
import 'dart:io';

class BarangActionIcons extends StatelessWidget {
  final Map<String, dynamic> barang;
  final String documentId;

  const BarangActionIcons({
    Key? key,
    required this.barang,
    required this.documentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.blue),
          onPressed: () => _showDetailDialog(context),
        ),
        const SizedBox(height: 2),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditBarang(
                  documentId: documentId,
                  barang: barang,
                ),
              ),
            );
          },
        ), // Optional: tambahkan aksi nanti
        const SizedBox(height: 2),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.blue),
          onPressed: () => _confirmDelete(context),
        ),
      ],
    );
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              "Detail ${barang["kategori"] == "Buku" ? "Buku" : "Barang"}",
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (barang['imagePath'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(barang['imagePath']),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (barang["kategori"] == "Buku") ...[
                    if (barang["judul"] != null)
                      Text("Judul: ${barang["judul"]}"),
                    if (barang["penerbit"] != null)
                      Text("Penerbit: ${barang["penerbit"]}"),
                    if (barang["kelas"] != null)
                      Text("Kelas: ${barang["kelas"]}"),
                    if (barang["jurusan"] != null)
                      Text("Jurusan: ${barang["jurusan"]}"),
                    Text("Jumlah: ${barang["jumlah"]}"),
                    if (barang["asal"] != null) Text("Asal: ${barang["asal"]}"),
                  ] else ...[
                    if (barang["namaBarang"] != null)
                      Text("Nama Barang: ${barang["namaBarang"]}"),
                    Text("Jumlah: ${barang["jumlah"]}"),
                    if (barang["asal"] != null) Text("Asal: ${barang["asal"]}"),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Tutup"),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Hapus Data'),
            content: const Text('Yakin ingin menghapus data ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('barang')
          .doc(documentId)
          .delete();
    }
  }
}
