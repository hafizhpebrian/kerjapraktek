import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventaris/screens/home_barang/edit_barang.dart';
import 'package:inventaris/screens/tambah_peminjaman/tambah_peminjaman_screen.dart';

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
    return IconButton(
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blue),
      onPressed: () => _showDetailDialog(context),
    );
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      barang["kategori"] == "Buku"
                          ? (barang["judul"] ?? "Detail Buku")
                          : (barang["namaBarang"] ?? "Detail Barang"),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (barang['imagePath'] != null &&
                    File(barang['imagePath']).existsSync()) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(barang['imagePath']),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      barang["kategori"] == "Buku"
                          ? [
                            Text("Judul: ${barang["judul"]}"),
                            Text("Penerbit: ${barang["penerbit"]}"),
                            Text("Kelas: ${barang["kelas"]}"),
                            Text("Jurusan: ${barang["jurusan"]}"),
                            Text("Jumlah: ${barang["jumlah"]}"),
                            Text("Asal: ${barang["asal"]}"),
                          ]
                          : [
                            Text("Nama Barang: ${barang["namaBarang"]}"),
                            Text("Jumlah: ${barang["jumlah"]}"),
                            Text("Asal: ${barang["asal"]}"),
                          ],
                ),
                const SizedBox(height: 20),
                const Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 28,
                      ),
                      tooltip: 'Hapus',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Hapus Data'),
                                content: const Text(
                                  'Yakin ingin menghapus data ini?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
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
                          Navigator.of(ctx).pop();
                        }
                      },
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.assignment,
                        color: Colors.blue,
                        size: 28,
                      ),
                      tooltip: 'Pinjam',
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => TambahPeminjamanScreen(
                                  barang: barang,
                                  documentId: documentId,
                                ),
                          ),
                        );
                      },
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.purple,
                        size: 28,
                      ),
                      tooltip: 'Edit',
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => EditBarang(
                                  documentId: documentId,
                                  barang: barang,
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
