import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerBarang extends StatelessWidget {
  final File? imageFile;
  final Function(File?) onImageSelected;

  const ImagePickerBarang({
    Key? key,
    required this.imageFile,
    required this.onImageSelected,
  }) : super(key: key);

  Future<void> _showPicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Kamera'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      onImageSelected(File(pickedFile.path));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeri'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      onImageSelected(File(pickedFile.path));
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _showPicker(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add_a_photo, color: Colors.blue),
          ),
        ),
        const SizedBox(width: 12),
        imageFile == null
            ? const Text('Belum ada gambar')
            : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                imageFile!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
      ],
    );
  }
}
