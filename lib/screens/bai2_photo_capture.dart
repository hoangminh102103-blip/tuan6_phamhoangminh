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
  // Biến lưu trữ file ảnh
  File? _imageFile;
  
  // Công cụ dùng để mở Camera hoặc Thư viện
  final ImagePicker _picker = ImagePicker();

  // Hàm xin quyền truy cập
  Future<void> _requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  // Hàm lấy ảnh từ thư viện
  Future<void> _pickImageFromGallery() async {
    await _requestPermission(Permission.photos); // Xin quyền truy cập thư viện ảnh
    
    // Mở thư viện cho người dùng chọn ảnh
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    // Nếu có chọn ảnh thì cập nhật lại giao diện
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Hàm chụp ảnh mới từ Camera
  Future<void> _captureImageFromCamera() async {
    await _requestPermission(Permission.camera); // Xin quyền dùng máy ảnh
    
    // Bật camera cho người dùng chụp
    final XFile? capturedFile = await _picker.pickImage(source: ImageSource.camera);
    
    // Nếu chụp xong thì lưu đường dẫn lại
    if (capturedFile != null) {
      setState(() {
        _imageFile = File(capturedFile.path);
      });
    }
  }

  // Hàm phóng to ảnh (Chuyển sang màn hình mới)
  void _showFullScreenPreview(BuildContext context) {
    if (_imageFile != null) {
      // Dùng Navigator.push để mở sang một trang (route) mới
      Navigator.push(
        context,
        MaterialPageRoute(
          // Trỏ tới class FullScreenImage ở bên dưới
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
          // Nếu chưa có ảnh thì báo chữ, có rồi thì hiển thị ảnh
          _imageFile == null
              ? const Text('Chưa có ảnh nào được chọn.')
              : GestureDetector( // Gói ảnh vào GestureDetector để bắt sự kiện click
                  onTap: () => _showFullScreenPreview(context), // Click vào ảnh thì phóng to
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

// Đây là màn hình riêng để hiển thị ảnh Full HD (Phóng to)
class FullScreenImage extends StatelessWidget {
  final File imageFile; // Nhận truyền file ảnh từ màn hình trước sang
  const FullScreenImage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xem trước')),
      body: Center(
        // InteractiveViewer cho phép dùng 2 ngón tay để zoom (phóng to/thu nhỏ) ảnh
        child: InteractiveViewer(
          child: Image.file(imageFile),
        ),
      ),
    );
  }
}
