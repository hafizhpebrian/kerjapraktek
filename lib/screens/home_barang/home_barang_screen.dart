import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventaris/screens/home_barang/barang_action_icons.dart';
import 'package:inventaris/screens/home_barang/tambah_barang/tambah_barang_screen.dart';

class HomeBarangScreen extends StatefulWidget {
  const HomeBarangScreen({Key? key}) : super(key: key);

  @override
  State<HomeBarangScreen> createState() => _HomeBarangScreenState();
}

class _HomeBarangScreenState extends State<HomeBarangScreen> {
  final Color primaryColor = Colors.blueGrey;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String? userRole;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
    getUserRole();
  }

  Future<void> getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        userRole = doc.data()?['role'] ?? 'user';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
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
                      return const Center(
                        child: Text(
                          'Belum ada data barang',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final docs =
                        snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final nama =
                              (data['namaBarang'] ?? '')
                                  .toString()
                                  .toLowerCase();
                          final judul =
                              (data['judul'] ?? '').toString().toLowerCase();
                          final kategori =
                              (data['kategori'] ?? '').toString().toLowerCase();
                          return nama.contains(_searchText) ||
                              judul.contains(_searchText) ||
                              kategori.contains(_searchText);
                        }).toList();

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ditemukan barang yang cocok.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

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
                            maxHeight: 130,
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
                              (barang['imagePath'] != null &&
                                      File(barang['imagePath']).existsSync())
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
                                    barang["kategori"] == "Buku"
                                        ? Icons.book
                                        : Icons.chair,
                                    size: 40,
                                    color: primaryColor,
                                  ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
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
                                      if (barang["judul"] != null &&
                                          barang["judul"].isNotEmpty)
                                        Text("Judul : ${barang["judul"]}"),
                                      Text(
                                        "Penerbit : ${barang["penerbit"] ?? '-'}",
                                      ),
                                      Text("Kelas : ${barang["kelas"] ?? '-'}"),
                                      Text("Jumlah : ${barang["jumlah"]}"),
                                    ] else ...[
                                      if (barang["namaBarang"] != null &&
                                          barang["namaBarang"].isNotEmpty)
                                        Text(
                                          "Nama Barang : ${barang["namaBarang"]}",
                                        ),
                                      Text("Jumlah : ${barang["jumlah"]}"),
                                      Text("Asal : ${barang["asal"] ?? '-'}"),
                                    ],
                                  ],
                                ),
                              ),
                              BarangActionIcons(
                                barang: barang,
                                documentId: documentId,
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
              if (userRole == 'wakabidsarpras')
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TambahBarangScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add, color: Colors.black),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
