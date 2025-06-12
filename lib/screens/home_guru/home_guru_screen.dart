import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventaris/screens/tambah_guru/tambah_guru.dart';
import 'package:inventaris/screens/home_guru/guru_action_icons.dart';

class HomeGuruScreen extends StatefulWidget {
  const HomeGuruScreen({Key? key}) : super(key: key);

  @override
  State<HomeGuruScreen> createState() => _HomeGuruScreenState();
}

class _HomeGuruScreenState extends State<HomeGuruScreen> {
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

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Colors.blue;
    return Scaffold(
      backgroundColor: backgroundColor,
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
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Cari guru...",
                        suffixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
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
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance.collection('guru').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Belum ada data guru',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final filteredDocs =
                        snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final nama =
                              (data['nama'] ?? '').toString().toLowerCase();
                          final jurusan =
                              (data['jurusan'] ?? '').toString().toLowerCase();
                          return nama.contains(_searchText) ||
                              jurusan.contains(_searchText);
                        }).toList();

                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final id = doc.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.school, size: 36),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Nama Guru: ${data['nama'] ?? '-'}"),
                                    Text("Jurusan : ${data['jurusan'] ?? '-'}"),
                                    Text(
                                      "Nomor induk yayasan : ${data['nomorInduk'] ?? '-'}",
                                    ),
                                    Text(
                                      "Nomor handphone : ${data['nomorHp'] ?? '-'}",
                                    ),
                                  ],
                                ),
                              ),
                              GuruActionIcons(guru: data, documentId: id),
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
                    MaterialPageRoute(builder: (_) => const TambahGuruScreen()),
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
