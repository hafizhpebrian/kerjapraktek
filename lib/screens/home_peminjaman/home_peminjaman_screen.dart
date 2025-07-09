import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventaris/screens/home_peminjaman/tambah_peminjaman/tambah_peminjaman_screen.dart';
import 'package:inventaris/screens/home_peminjaman/peminjaman_action_icons.dart';
import 'package:inventaris/screens/home_peminjaman/pengembalian_detail_dialog.dart';

extension StringCasingExtension on String {
  String capitalizeWords() {
    return split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                  : '',
        )
        .join(' ');
  }
}

class HomePeminjamanScreen extends StatefulWidget {
  const HomePeminjamanScreen({Key? key}) : super(key: key);

  @override
  State<HomePeminjamanScreen> createState() => _HomePeminjamanScreenState();
}

class _HomePeminjamanScreenState extends State<HomePeminjamanScreen> {
  final Color primaryColor = Colors.blueGrey;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String? userRole;
  int _selectedIndex = 0;

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
                        hintText: "Cari peminjam...",
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
                      _selectedIndex == 0
                          ? (userRole == 'wakabidsarpras'
                              ? FirebaseFirestore.instance
                                  .collection('peminjaman')
                                  .snapshots()
                              : FirebaseFirestore.instance
                                  .collection('peminjaman')
                                  .where(
                                    'uid',
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser?.uid,
                                  )
                                  .snapshots())
                          : (userRole == 'wakabidsarpras'
                              ? FirebaseFirestore.instance
                                  .collection('pengembalian')
                                  .snapshots()
                              : FirebaseFirestore.instance
                                  .collection('pengembalian')
                                  .where(
                                    'uid',
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser?.uid,
                                  )
                                  .snapshots()),

                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          _selectedIndex == 0
                              ? "Belum ada data peminjaman"
                              : "Belum ada data pengembalian",
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final item = docs[index];
                        final data = item.data() as Map<String, dynamic>;

                        if (_selectedIndex == 0) {
                          final kategori = data['kategori'] ?? '';
                          final nama = data['nama'] ?? '';
                          final jurusan = data['jurusan'] ?? '';
                          final jumlahPinjam = data['jumlahPinjam'] ?? 0;
                          final tanggalPinjam =
                              (data['tanggalPinjam'] as Timestamp?)?.toDate();

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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${kategori.toString().capitalizeWords()} - ${nama.toString().capitalizeWords()}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Jurusan: ${jurusan.toString().capitalizeWords()}',
                                      ),
                                      Text('Jumlah Pinjam: $jumlahPinjam'),
                                      if (tanggalPinjam != null)
                                        Text(
                                          'Peminjaman: ${DateFormat.yMMMd().format(tanggalPinjam)}',
                                        ),
                                      const Text(
                                        'Status: Dipinjam',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PeminjamanActionIcons(
                                  data: data,
                                  documentId: item.id,
                                ),
                              ],
                            ),
                          );
                        } else {
                          final tanggalPinjam =
                              (data['tanggalPinjam'] as Timestamp?)?.toDate();
                          final tanggalKembali =
                              (data['tanggalKembali'] as Timestamp?)?.toDate();
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${(data["kategori"] ?? "")} - ${(data["nama"] ?? "")}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Jurusan: ${data["jurusan"] ?? "-"}',
                                      ),
                                      Text(
                                        'Jumlah Pinjam: ${data["jumlahPinjam"] ?? "-"}',
                                      ),
                                      if (tanggalPinjam != null)
                                        Text(
                                          'Peminjaman: ${DateFormat.yMMMd().format(tanggalPinjam)}',
                                        ),
                                      if (tanggalKembali != null)
                                        Text(
                                          'Pengembalian: ${DateFormat.yMMMd().format(tanggalKembali)}',
                                        ),
                                      const Text(
                                        'Status: Dikembalikan',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.blueGrey,
                                  ),
                                  onPressed: () {
                                    PengembalianDetailDialog.show(
                                      context,
                                      data,
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _selectedIndex = 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_return,
                            color:
                                _selectedIndex == 0
                                    ? Colors.blueGrey
                                    : Colors.black,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Peminjaman',
                            style: TextStyle(
                              color:
                                  _selectedIndex == 0
                                      ? Colors.blueGrey
                                      : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TambahPeminjamanScreen(),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add, size: 28, color: Colors.black),
                          SizedBox(height: 4),
                          Text(
                            'Tambah',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _selectedIndex = 1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_turned_in,
                            color:
                                _selectedIndex == 1
                                    ? Colors.blueGrey
                                    : Colors.black,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pengembalian',
                            style: TextStyle(
                              color:
                                  _selectedIndex == 1
                                      ? Colors.blueGrey
                                      : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
