import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inventaris/screens/create_barang_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeBarangScreen extends StatefulWidget {
  const HomeBarangScreen({Key? key}) : super(key: key);

  @override
  State<HomeBarangScreen> createState() => _HomeBarangScreenState();
}

class _HomeBarangScreenState extends State<HomeBarangScreen> {
  final Color primaryColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "cari barang",
                        fillColor: Colors.white,
                        filled: true,
                        suffixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('barang')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('Belum ada data barang'));
                    }
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final barang = doc.data() as Map<String, dynamic>;
                        final documentId = doc.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(
                            minHeight: 0,
                            maxHeight: 150,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              barang['imagePath'] != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(barang['imagePath']),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : Icon(
                                    (barang["kategori"] == "Buku")
                                        ? Icons.book
                                        : Icons.chair,
                                    size: 40,
                                    color: primaryColor,
                                  ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      barang["kategori"] == "Buku"
                                          ? "Buku"
                                          : (barang["namaBarang"] ?? "Barang"),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (barang["kategori"] == "Buku") ...[
                                      if (barang.containsKey("judul") &&
                                          (barang["judul"] ?? "").isNotEmpty)
                                        Text("Judul : ${barang["judul"]}"),
                                      Text(
                                        "Penerbit : ${barang["penerbit"] ?? '-'}",
                                      ),
                                      Text("Kelas : ${barang["kelas"] ?? '-'}"),
                                      Text("Jumlah : ${barang["jumlah"]}"),
                                    ] else ...[
                                      if (barang.containsKey("namaBarang") &&
                                          (barang["namaBarang"] ?? "")
                                              .isNotEmpty)
                                        Text(
                                          "Nama Barang : ${barang["namaBarang"]}",
                                        ),
                                      Text("Jumlah : ${barang["jumlah"]}"),
                                    ],
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (_) => AlertDialog(
                                              title: Text(
                                                "Detail ${barang["kategori"] == "Buku" ? "Buku" : "Barang"}",
                                              ),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (barang['imagePath'] !=
                                                        null)
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        child: Image.file(
                                                          File(
                                                            barang['imagePath'],
                                                          ),
                                                          width: 100,
                                                          height: 100,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    if (barang["kategori"] ==
                                                        "Buku") ...[
                                                      if (barang.containsKey(
                                                        "judul",
                                                      ))
                                                        Text(
                                                          "Judul: ${barang["judul"]}",
                                                        ),
                                                      if (barang.containsKey(
                                                        "penerbit",
                                                      ))
                                                        Text(
                                                          "Penerbit: ${barang["penerbit"]}",
                                                        ),
                                                      if (barang.containsKey(
                                                        "kelas",
                                                      ))
                                                        Text(
                                                          "Kelas: ${barang["kelas"]}",
                                                        ),
                                                      if (barang.containsKey(
                                                        "jurusan",
                                                      ))
                                                        Text(
                                                          "Jurusan: ${barang["jurusan"]}",
                                                        ),
                                                      Text(
                                                        "Jumlah: ${barang["jumlah"]}",
                                                      ),
                                                      if (barang.containsKey(
                                                        "asal",
                                                      ))
                                                        Text(
                                                          "Asal: ${barang["asal"]}",
                                                        ),
                                                    ] else ...[
                                                      if (barang.containsKey(
                                                        "namaBarang",
                                                      ))
                                                        Text(
                                                          "Nama Barang: ${barang["namaBarang"]}",
                                                        ),
                                                      Text(
                                                        "Jumlah: ${barang["jumlah"]}",
                                                      ),
                                                      if (barang.containsKey(
                                                        "asal",
                                                      ))
                                                        Text(
                                                          "Asal: ${barang["asal"]}",
                                                        ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text("Tutup"),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 2),
                                  const Icon(Icons.edit, color: Colors.blue),
                                  const SizedBox(height: 2),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text('Hapus Data'),
                                              content: const Text(
                                                'Yakin ingin menghapus data ini?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text('Batal'),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
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
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TambahBarangScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.add, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
