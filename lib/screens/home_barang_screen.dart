import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inventaris/screens/create_barang_screen.dart';

class HomeBarangScreen extends StatefulWidget {
  const HomeBarangScreen({Key? key}) : super(key: key);

  @override
  State<HomeBarangScreen> createState() => _HomeBarangScreenState();
}

class _HomeBarangScreenState extends State<HomeBarangScreen> {
  final Color primaryColor = Colors.blue;
  final List<Map<String, dynamic>> barangList = [
    {
      "nama": "Kursi",
      "jumlah": 40,
      "dipinjam": 30,
      "sisa": 10,
      "milik": "Pemerintah",
      "icon": Icons.chair,
    },
  ];

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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                child: ListView.builder(
                  itemCount: barangList.length,
                  itemBuilder: (context, index) {
                    final barang = barangList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
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
                          // Tampilkan gambar jika ada, jika tidak tampilkan icon
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
                              : Icon(barang["icon"] ?? Icons.inventory, size: 40, color: primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  barang["nama"] ?? (barang["kategori"] ?? "-"),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (barang.containsKey("judul") && (barang["judul"] ?? "").isNotEmpty)
                                  Text("Judul : ${barang["judul"]}"),
                                Text("Jumlah : ${barang["jumlah"]}"),
                                Text("Dipinjam : ${barang["dipinjam"]}"),
                                Text("Sisa ${barang["nama"] == 'Buku' ? 'Buku' : 'Barang'} : ${barang["sisa"] ?? ((barang["jumlah"] ?? 0) - (barang["dipinjam"] ?? 0))}"),
                                if (barang.containsKey("milik"))
                                  Text("Milik : ${barang["milik"]}"),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info_outline, color: Colors.blue),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text("Detail ${barang["nama"] ?? barang["kategori"]}"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
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
                                          if (barang.containsKey("judul"))
                                            Text("Judul: ${barang["judul"]}"),
                                          Text("Jumlah: ${barang["jumlah"]}"),
                                          Text("Dipinjam: ${barang["dipinjam"]}"),
                                          Text("Sisa: ${barang["sisa"] ?? ((barang["jumlah"] ?? 0) - (barang["dipinjam"] ?? 0))}"),
                                          if (barang.containsKey("milik"))
                                            Text("Milik: ${barang["milik"]}"),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Tutup"),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              const Icon(Icons.edit, color: Colors.blue),
                              const SizedBox(height: 5),
                              const Icon(Icons.delete, color: Colors.blue),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TambahBarangScreen(),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      // Tambahkan data baru ke list, hitung sisa otomatis
                      barangList.add({
                        ...result,
                        "nama": result["kategori"] == "Buku" ? "Buku" : (result["judul"] ?? "Barang"),
                        "sisa": (result["jumlah"] ?? 0) - (result["dipinjam"] ?? 0),
                        "icon": result["kategori"] == "Buku" ? Icons.book : Icons.chair,
                      });
                    });
                  }
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