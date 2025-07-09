import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PengembalianDetailDialog {
  static void show(BuildContext context, Map<String, dynamic> data) {
    final tanggalPinjam = (data['tanggalPinjam'] as Timestamp?)?.toDate();
    final tanggalKembali = (data['tanggalKembali'] as Timestamp?)?.toDate();
    final returnedAt = (data['returnedAt'] as Timestamp?)?.toDate();

    String? barangId;
    if (data["barang_ref"] != null && data["barang_ref"] is DocumentReference) {
      barangId = (data["barang_ref"] as DocumentReference).id;
    } else if (data["barangId"] != null) {
      barangId = data["barangId"];
    }

    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Detail Pengembalian",
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
                              (data["guru_ref"] as DocumentReference)
                                  .snapshots(),
                          builder: (context, snapshot) {
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
                                  "Nomor Induk: ${guru["nomorInduk"] ?? "-"}",
                                ),
                                Text("Nomor HP: ${guru["nomorHp"] ?? "-"}"),
                              ],
                            );
                          },
                        ),
                    ] else ...[
                      Text("Nama: ${data["nama"] ?? "-"}"),
                      Text("Kelas: ${data["kelas"] ?? "-"}"),
                      Text("Jurusan: ${data["jurusan"] ?? "-"}"),
                      Text("Email: ${data["email"] ?? "-"}"),
                    ],
                    Text("Jumlah Pinjam: ${data["jumlahPinjam"] ?? "-"}"),
                    if (tanggalPinjam != null)
                      Text(
                        "Tanggal Pinjam: ${DateFormat.yMMMd().format(tanggalPinjam)}",
                      ),
                    if (tanggalKembali != null)
                      Text(
                        "Tanggal Kembali: ${DateFormat.yMMMd().format(tanggalKembali)}",
                      ),
                    if (returnedAt != null)
                      Text(
                        "Dikembalikan: ${DateFormat.yMMMd().format(returnedAt)}",
                      ),

                    const SizedBox(height: 16),
                    const Text(
                      "*Info barang yang dipinjam*",
                      style: TextStyle(fontStyle: FontStyle.italic),
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
                          if (!snapshot.hasData || !snapshot.data!.exists) {
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

                          // Jumlah setelah dikembalikan (sudah diupdate di koleksi barang)
                          final total = jumlah;

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
                                Text("Jumlah : $total"),
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
                                Text("Jumlah Sekarang: $total"),
                                Text("Asal: ${barang["asal"] ?? "-"}"),
                              ],
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
