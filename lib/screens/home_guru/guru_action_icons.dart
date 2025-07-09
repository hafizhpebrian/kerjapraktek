import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventaris/screens/home_guru/edit_guru.dart';

class GuruActionIcons extends StatelessWidget {
  final Map<String, dynamic> guru;
  final String documentId;

  const GuruActionIcons({
    Key? key,
    required this.guru,
    required this.documentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.blueGrey,
      ),
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
                    const Text(
                      "Detail Guru",
                      style: TextStyle(
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

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nama Guru: ${guru["nama"] ?? '-'}"),
                    Text("Nomor Induk Yayasan: ${guru["nomorInduk"] ?? '-'}"),
                    Text("Email: ${guru["email"] ?? '-'}"),
                    Text("Nomor HP: ${guru["nomorHp"] ?? '-'}"),
                    Text("Jurusan: ${guru["jurusan"] ?? '-'}"),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.purple),
                      tooltip: 'Edit',
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => EditGuruScreen(
                                  documentId: documentId,
                                  guruData: guru,
                                ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Hapus',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Hapus Guru'),
                                content: const Text(
                                  'Yakin ingin menghapus data guru ini?',
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
                          try {
                            // Pindahkan ke riwayat_guru
                            await FirebaseFirestore.instance
                                .collection('riwayat_guru')
                                .doc(documentId)
                                .set(guru);

                            // Hapus dari koleksi utama
                            await FirebaseFirestore.instance
                                .collection('guru')
                                .doc(documentId)
                                .delete();

                            Navigator.of(ctx).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Data guru dipindahkan ke riwayat',
                                ),
                              ),
                            );
                          } catch (e) {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menghapus data: $e'),
                              ),
                            );
                          }
                        }
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
