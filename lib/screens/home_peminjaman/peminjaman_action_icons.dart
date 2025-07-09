import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.blueGrey,
      ),
      onPressed: () => _showDetailDialog(context),
    );
  }

  void _showDetailDialog(BuildContext context) {
    final tanggalPinjam = (data['tanggalPinjam'] as Timestamp?)?.toDate();
    final tanggalKembali = (data['tanggalKembali'] as Timestamp?)?.toDate();

    String? barangId;
    if (data["barang_ref"] != null && data["barang_ref"] is DocumentReference) {
      barangId = (data["barang_ref"] as DocumentReference).id;
    } else if (data["barangId"] != null) {
      barangId = data["barangId"];
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Detail Peminjaman",
                          style: TextStyle(
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

                  if (data["kategori"] != null)
                    Text("Kategori: ${data["kategori"]}"),

                  if (data["kategori"] == "Guru") ...[
                    if (data["guru_ref"] != null &&
                        data["guru_ref"] is DocumentReference)
                      StreamBuilder<DocumentSnapshot>(
                        stream:
                            (data["guru_ref"] as DocumentReference).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Text("Data guru tidak ditemukan.");
                          }

                          final guru =
                              snapshot.data!.data() as Map<String, dynamic>;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Nama: ${guru["nama"] ?? "-"}"),
                              Text("Email: ${guru["email"] ?? "-"}"),
                              Text(
                                "Nomor Induk Yayasan: ${guru["nomorInduk"] ?? "-"}",
                              ),
                              Text("Nomor HP: ${guru["nomorHp"] ?? "-"}"),
                            ],
                          );
                        },
                      ),
                  ] else if (data["kategori"] == "Siswa") ...[
                    Text("Nama: ${data["nama"] ?? "-"}"),
                    Text("Kelas: ${data["kelas"] ?? "-"}"),
                    Text("Jurusan: ${data["jurusan"] ?? "-"}"),
                    Text("Email: ${data["email"] ?? "-"}"),
                  ],

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
                  const Text(
                    "*Info barang yang dipinjam*",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (barangId != null)
                    StreamBuilder<DocumentSnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('barang')
                              .doc(barangId)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (!snapshot.hasData ||
                            !snapshot.data!.exists) {
                          return const Text("Data barang tidak ditemukan.");
                        }

                        final barang =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final jumlah =
                            (barang["jumlah"] ?? 0) is int
                                ? barang["jumlah"]
                                : int.tryParse(barang["jumlah"].toString()) ??
                                    0;
                        final jumlahPinjam =
                            (data["jumlahPinjam"] ?? 0) is int
                                ? data["jumlahPinjam"]
                                : int.tryParse(
                                      data["jumlahPinjam"].toString(),
                                    ) ??
                                    0;
                        final sisa = jumlah - jumlahPinjam;

                        if ((barang["kategori"] ?? "").toLowerCase() ==
                            "buku") {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Judul Buku: ${barang["judul"] ?? "-"}"),
                              Text("Penulis: ${barang["penulis"] ?? "-"}"),
                              Text("Penerbit: ${barang["penerbit"] ?? "-"}"),
                              Text("Tahun: ${barang["tahun"] ?? "-"}"),
                              Text("Kelas: ${barang["kelas"] ?? "-"}"),
                              Text("Jurusan: ${barang["jurusan"] ?? "-"}"),
                              Text("Jumlah: $jumlah"),
                              Text("Sisa Buku: $sisa"),
                              Text("Asal: ${barang["asal"] ?? "-"}"),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nama Barang: ${barang["namaBarang"] ?? "-"}",
                              ),
                              Text("Tahun: ${barang["tahun"] ?? "-"}"),
                              Text("Jumlah: $jumlah"),
                              Text("Sisa Barang: $sisa"),
                              Text("Asal: ${barang["asal"] ?? "-"}"),
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
                        tooltip: "Hapus (Soft Delete)",
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text("Hapus Peminjaman"),
                                  content: const Text(
                                    "Yakin ingin menghapus data ini?",
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text("Batal"),
                                      onPressed:
                                          () => Navigator.pop(ctx, false),
                                    ),
                                    TextButton(
                                      child: const Text("Hapus"),
                                      onPressed: () => Navigator.pop(ctx, true),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm == true) {
                            try {
                              data['deletedAt'] = FieldValue.serverTimestamp();

                              await FirebaseFirestore.instance
                                  .collection('riwayat_peminjaman')
                                  .doc(documentId)
                                  .set(data);

                              await FirebaseFirestore.instance
                                  .collection('peminjaman')
                                  .doc(documentId)
                                  .delete();

                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Data dipindahkan ke riwayat"),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gagal menghapus: $e")),
                              );
                            }
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.assignment_turned_in,
                          color: Colors.green,
                        ),
                        tooltip: "Kembalikan",
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('pengembalian')
                                .add({
                                  ...data,
                                  'status': 'dikembalikan',
                                  'returnedAt': Timestamp.now(),
                                });

                            await FirebaseFirestore.instance
                                .collection('peminjaman')
                                .doc(documentId)
                                .delete();

                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Barang berhasil dikembalikan'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal mengembalikan barang: $e'),
                              ),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.purple),
                        tooltip: "Edit",
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => EditPeminjamanScreen(
                                    data: data,
                                    documentId: documentId,
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
          ),
        );
      },
    );
  }
}
