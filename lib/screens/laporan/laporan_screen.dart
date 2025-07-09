import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color primaryColor = Colors.blueGrey;

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  String? _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Guru', 'Siswa'];
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, int>> getFrekuensiPengembalian() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('pengembalian').get();

    Map<String, int> frekuensi = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final kategori = data['kategori']?.toString().toLowerCase() ?? '';
      final barang = data['barangDipinjam'] as Map<String, dynamic>?;

      if (barang == null) continue;

      final nama = barang['namaBarang'] ?? barang['judul'] ?? 'Tanpa Nama';

      if (_selectedCategory == 'Guru' && kategori != 'guru') continue;
      if (_selectedCategory == 'Siswa' && kategori != 'siswa') continue;

      frekuensi[nama] = (frekuensi[nama] ?? 0) + 1;
    }

    return frekuensi;
  }

  Future<List<Map<String, dynamic>>> getBarangTerpopuler() async {
    final frekuensi = await getFrekuensiPengembalian();
    final List<Map<String, dynamic>> hasil = [];

    for (var entry in frekuensi.entries) {
      hasil.add({'nama': entry.key, 'jumlahPinjam': entry.value});
    }

    hasil.sort((a, b) => b['jumlahPinjam'].compareTo(a['jumlahPinjam']));
    return hasil;
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
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Cari laporan peminjaman',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const Icon(Icons.search, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: const Text('Pilih Kategori Laporan'),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items:
                      _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: getBarangTerpopuler(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data ?? [];

                    final filteredData =
                        data.where((item) {
                          return item['nama'].toString().toLowerCase().contains(
                            _searchText,
                          );
                        }).toList();

                    if (filteredData.isEmpty) {
                      return const Center(
                        child: Text(
                          "Tidak ada data peminjaman.",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final item = filteredData[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nama'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Kategori: ${_selectedCategory!}"),
                                ],
                              ),
                              Text(
                                "${item['jumlahPinjam']}x",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
