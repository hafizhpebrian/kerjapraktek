import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:inventaris/screens/home_peminjaman/edit_peminjaman.dart';

class PeminjamanActionIcons extends StatelessWidget {
  final Map<String, dynamic> data;
  final String documentId;

  const PeminjamanActionIcons({
    Key? key,
    required this.data,
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
    final tanggalPinjam = (data['tanggalPinjam'] as Timestamp?)?.toDate();
    final tanggalKembali = (data['tanggalKembali'] as Timestamp?)?.toDate();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data["nama"] ?? "Detail Peminjaman",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Column(),
                if (data["kategori"] != null)
                  Text("Kategori: ${data["kategori"]}"),
                if (data["nama"] != null) Text("Nama: ${data["nama"]}"),
                if (data["jurusan"] != null)
                  Text("Jurusan: ${data["jurusan"]}"),
                if (data["kelas"] != null && data["kategori"] == "Murid")
                  Text("Kelas: ${data["kelas"]}"),
                if (data["jumlahPinjam"] != null)
                  Text("Jumlah Pinjam: ${data["jumlahPinjam"]}"),
                if (tanggalPinjam != null)
                  Text(
                    "Tanggal Pinjam: ${DateFormat.yMMMd().format(tanggalPinjam)}",
                  ),
                if (tanggalKembali != null)
                  Text(
                    "Tanggal Kembali: ${DateFormat.yMMMd().format(tanggalKembali)}",
                  ),

                const SizedBox(height: 16),
                Text(
                  "*Info barang yang dipinjam*",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                if (data["barangDipinjam"] != null)
                  Builder(
                    builder: (context) {
                      final barang =
                          data["barangDipinjam"] as Map<String, dynamic>;
                      if ((barang["kategori"] ?? "").toLowerCase() == "buku") {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Judul Buku : ${barang["judul"] ?? "-"}"),
                            Text("Penerbit : ${barang["penerbit"] ?? "-"}"),
                            Text("Kelas : ${barang["kelas"] ?? "-"}"),
                            Text("Jumlah : ${barang["jumlah"] ?? "-"}"),
                            Text(
                              "Sisa Buku : ${(barang["jumlah"] ?? 0) - (data["jumlahPinjam"] ?? 0)}",
                            ),
                            Text("Asal : ${barang["asal"] ?? "-"}"),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Nama Barang : ${barang["namaBarang"] ?? "-"}",
                            ),
                            Text("Jumlah : ${barang["jumlah"] ?? "-"}"),
                            Text(
                              "Sisa Barang : ${(barang["jumlah"] ?? 0) - (data["jumlahPinjam"] ?? 0)}",
                            ),
                            Text("Asal : ${barang["asal"] ?? "-"}"),
                          ],
                        );
                      }
                    },
                  ),

                const SizedBox(height: 20),
                const Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text("Hapus Peminjaman"),
                                content: const Text(
                                  "Yakin ingin menghapus data ini?",
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("Batal"),
                                    onPressed: () => Navigator.pop(ctx, false),
                                  ),
                                  TextButton(
                                    child: const Text("Hapus"),
                                    onPressed: () => Navigator.pop(ctx, true),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          await FirebaseFirestore.instance
                              .collection('peminjaman')
                              .doc(documentId)
                              .delete();
                          Navigator.pop(ctx);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.purple),
                      onPressed: () {
                        Navigator.pop(ctx); // tutup dialog dulu
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditPeminjamanScreen(
                                  documentId: documentId,
                                  data: data,
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

  Widget _buildAction(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        IconButton(icon: Icon(icon, color: color, size: 28), onPressed: onTap),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
