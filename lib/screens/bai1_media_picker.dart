import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class Bai1MediaPicker extends StatefulWidget {
  const Bai1MediaPicker({super.key});

  @override
  State<Bai1MediaPicker> createState() => _Bai1MediaPickerState();
}

class _Bai1MediaPickerState extends State<Bai1MediaPicker> {
  // Biến lưu trữ file ảnh hoặc video sau khi người dùng chọn
  File? _mediaFile;
  
  // Bộ điều khiển (controller) dùng để phát video
  VideoPlayerController? _videoController;
  
  // Đối tượng dùng để mở thư viện hoặc camera
  final ImagePicker _picker = ImagePicker();

  // Hàm dùng để xin quyền truy cập (Bộ nhớ hoặc Camera)
  Future<void> _requestPermission(Permission permission) async {
    // Nếu quyền bị từ chối, sẽ hiện hộp thoại hỏi người dùng cấp quyền
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  // Hàm chọn ảnh hoặc video từ Thư viện (Gallery)
  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    // 1. Xin quyền: Nếu là video thì xin quyền storage, ảnh thì xin quyền photos
    await _requestPermission(
      isVideo ? Permission.storage : Permission.photos,
    );

    // 2. Mở thư viện lên để chọn file
    final XFile? pickedFile = isVideo
        ? await _picker.pickVideo(source: source) // Chọn video
        : await _picker.pickImage(                 // Chọn ảnh
            source: source,
            imageQuality: 100, // Chất lượng ảnh 100%
            maxWidth: 1920,    // Chiều rộng tối đa
            maxHeight: 1080,   // Chiều cao tối đa
          );

    // 3. Xử lý sau khi người dùng chọn file xong
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path); // Lưu đường dẫn file vào biến
        
        // Kiểm tra xem file có phải là đuôi mp4 (video) không
        if (_mediaFile!.path.endsWith('.mp4')) {
          _videoController?.dispose(); // Xóa bộ nhớ video cũ (nếu có)
          
          // Nạp file video mới vào bộ điều khiển
          _videoController = VideoPlayerController.file(_mediaFile!);
          
          // Khởi tạo video, nạp xong thì cho tự động phát (play)
          _videoController!.initialize().then((_) {
            setState(() {}); // Báo cho giao diện cập nhật
            _videoController!.play();
          });
        } else {
          // Nếu không phải video (tức là ảnh) thì tắt bộ điều khiển video đi
          _videoController?.dispose();
          _videoController = null;
        }
      });
    } else {
      // Báo lỗi nếu người dùng bấm Hủy, không chọn gì cả
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chưa chọn file nào!')));
      }
    }
  }

  // Hàm mở Camera để Chụp ảnh hoặc Quay video
  Future<void> _captureMedia(bool isVideo) async {
    // 1. Xin quyền mở Camera, nếu là quay video thì xin thêm quyền Micro
    await _requestPermission(Permission.camera);
    if (isVideo) {
      await _requestPermission(Permission.microphone);
    }

    // 2. Mở Camera lên
    final XFile? capturedFile = isVideo
        ? await _picker.pickVideo(source: ImageSource.camera) // Quay video
        : await _picker.pickImage(source: ImageSource.camera); // Chụp ảnh

    // 3. Xử lý sau khi chụp/quay xong (Tương tự như lúc chọn từ thư viện)
    if (capturedFile != null) {
      setState(() {
        _mediaFile = File(capturedFile.path);
        
        if (isVideo) {
          _videoController?.dispose();
          _videoController = VideoPlayerController.file(_mediaFile!);
          _videoController!.initialize().then((_) {
            setState(() {});
            _videoController!.play();
          });
        } else {
          _videoController?.dispose();
          _videoController = null;
        }
      });
    } else {
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không có file nào được chụp/quay!')));
      }
    }
  }

  // Hàm dọn dẹp bộ nhớ khi thoát màn hình này
  @override
  void dispose() {
    _videoController?.dispose(); // Giải phóng video controller để tránh tràn RAM
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            
            // KHU VỰC HIỂN THỊ ẢNH / VIDEO
            // Cấu trúc IF-ELSE (dạng rút gọn: điều_kiện ? nếu_đúng : nếu_sai)
            _mediaFile == null
                ? const Text('Chưa chọn ảnh hoặc video.') // Chưa có file -> Hiện chữ
                : _videoController != null
                    ? (_videoController!.value.isInitialized
                        ? AspectRatio(
                            // Hiển thị khung video với tỷ lệ chuẩn
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          )
                        : const SizedBox(
                            // Khi video đang nạp, hiển thị vòng xoay tải
                            height: 300,
                            child: Center(child: CircularProgressIndicator()),
                          ))
                    : Image.file(_mediaFile!, height: 300), // Nếu là ảnh thì hiện ảnh

            const SizedBox(height: 20),
            
            // KHU VỰC CÁC NÚT BẤM
            ElevatedButton(
              onPressed: () => _pickMedia(ImageSource.gallery, false),
              child: const Text('Chọn ảnh từ Gallery'),
            ),
            ElevatedButton(
              onPressed: () => _captureMedia(false),
              child: const Text('Chụp ảnh từ Camera'),
            ),
            ElevatedButton(
              onPressed: () => _pickMedia(ImageSource.gallery, true),
              child: const Text('Chọn video từ Gallery'),
            ),
            ElevatedButton(
              onPressed: () => _captureMedia(true),
              child: const Text('Quay video từ Camera'),
            ),
          ],
        ),
      ),
    );
  }
}
