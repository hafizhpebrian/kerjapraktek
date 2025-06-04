import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class EditProfileScreen extends StatefulWidget {
  final String email;
  const EditProfileScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;

  File? _imageFile;
  String? _photoUrl;
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = user?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _namaController.text = data['nama'] ?? '';
          _noHpController.text = data['no_hp'] ?? '';
          _photoUrl = data['photoUrl'];
        });
      }
    }
  }

  Future<void> _showImagePicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImagePicker().pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() {
                    _imageFile = File(picked.path);
                    _isChanged = true;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() {
                    _imageFile = File(picked.path);
                    _isChanged = true;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadImage(File image) async {
    final uid = user?.uid;
    if (uid == null) {
      print("Upload dibatalkan: UID null");
      return null;
    }

    if (!image.existsSync()) {
      print("File tidak ditemukan: ${image.path}");
      return null;
    }

    try {
      final ref = FirebaseStorage.instance.ref().child('profile_photos/$uid.jpg');
      print("Mengupload ke path: profile_photos/$uid.jpg");
      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      print("URL berhasil didapat: $url");
      return url;
    } catch (e) {
      print("Upload error: $e");
      throw e; // diteruskan ke catch di _simpanData
    }
  }

  Future<void> _simpanData() async {
    if (_formKey.currentState!.validate()) {
      final uid = user?.uid;
      String? photoUrl = _photoUrl;

      try {
        if (_imageFile != null) {
          photoUrl = await _uploadImage(_imageFile!);
        }

        if (uid != null) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'nama': _namaController.text,
            'no_hp': _noHpController.text,
            'photoUrl': photoUrl,
          }, SetOptions(merge: true));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.blue;

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showImagePicker(context),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (_photoUrl != null ? NetworkImage(_photoUrl!) : null) as ImageProvider?,
                child: _imageFile == null && _photoUrl == null
                    ? const Icon(Icons.person, size: 50, color: primaryColor)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _namaController.text.isNotEmpty ? _namaController.text : '...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildTextField("nama", _namaController),
                      _readOnlyField("email", widget.email),
                      _buildTextField("no handphone", _noHpController),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isChanged ? Colors.white : Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: _isChanged ? _simpanData : null,
              child: const Text(
                'simpan',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: enabled
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.blue),
                  onPressed: () {
                    controller.clear();
                    setState(() => _isChanged = true);
                  },
                )
              : null,
        ),
        onChanged: (_) => setState(() => _isChanged = true),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label wajib diisi';
          }
          return null;
        },
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
