import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Bai2PhotoCapture extends StatefulWidget {
  const Bai2PhotoCapture({super.key});

  @override
  State<Bai2PhotoCapture> createState() => _Bai2PhotoCaptureState();
}

class _Bai2PhotoCaptureState extends State<Bai2PhotoCapture> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  Future<void> _pickImageFromGallery() async {
    await _requestPermission(Permission.photos);
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _captureImageFromCamera() async {
    await _requestPermission(Permission.camera);
    final XFile? capturedFile = await _picker.pickImage(source: ImageSource.camera);
    if (capturedFile != null) {
      setState(() {
        _imageFile = File(capturedFile.path);
      });
    }
  }

  void _showFullScreenPreview(BuildContext context) {
    if (_imageFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImage(imageFile: _imageFile!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _imageFile == null
              ? const Text('Chưa có ảnh nào được chọn.')
              : GestureDetector(
                  onTap: () => _showFullScreenPreview(context),
                  child: Image.file(_imageFile!, height: 300),
                ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImageFromGallery,
            child: const Text('Chọn ảnh từ Gallery'),
          ),
          ElevatedButton(
            onPressed: _captureImageFromCamera,
            child: const Text('Chụp ảnh từ Camera'),
          ),
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final File imageFile;
  const FullScreenImage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xem trước')),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(imageFile),
        ),
      ),
    );
  }
}

