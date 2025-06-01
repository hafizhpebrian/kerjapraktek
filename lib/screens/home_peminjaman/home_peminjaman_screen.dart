import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventaris/screens/tambah_peminjaman/tambah_peminjaman_screen.dart';

class HomePeminjamanScreen extends StatefulWidget {
  const HomePeminjamanScreen({Key? key}) : super(key: key);

  @override
  State<HomePeminjamanScreen> createState() => _HomePeminjamanScreenState();
}

class _HomePeminjamanScreenState extends State<HomePeminjamanScreen> {
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
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "cari peminjam",
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
                          .collection('peminjaman')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "Belum ada data peminjaman",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final data = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        final kategori = item['kategori'] ?? '';
                        final nama = item['nama'] ?? '';
                        final jurusan = item['jurusan'] ?? '';
                        final jumlahPinjam = item['jumlahPinjam'] ?? 0;
                        final tanggalPinjam =
                            (item['tanggalPinjam'] as Timestamp?)?.toDate();
                        final tanggalKembali =
                            (item['tanggalKembali'] as Timestamp?)?.toDate();

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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$kategori - $nama',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Jurusan: $jurusan'),
                              if (kategori == 'Murid')
                                Text('Kelas: ${item['kelas'] ?? ''}'),
                              Text('JumlahPinjam: $jumlahPinjam'),
                              if (tanggalPinjam != null)
                                Text(
                                  'Peminjaman: ${DateFormat.yMMMd().format(tanggalPinjam)}',
                                ),
                              if (tanggalKembali != null)
                                Text(
                                  'Pengembalian: ${DateFormat.yMMMd().format(tanggalKembali)}',
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TambahPeminjamanScreen(),
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
