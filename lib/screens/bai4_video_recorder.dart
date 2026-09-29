import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class Bai4VideoRecorder extends StatefulWidget {
  const Bai4VideoRecorder({super.key});

  @override
  State<Bai4VideoRecorder> createState() => _Bai4VideoRecorderState();
}

class _Bai4VideoRecorderState extends State<Bai4VideoRecorder> {
  // Biến lưu trữ file video
  File? _videoFile;
  
  // Trình điều khiển để phát video
  VideoPlayerController? _videoController;
  
  final ImagePicker _picker = ImagePicker();

  // Hàm xin quyền
  Future<void> _requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  // Hàm chọn video có sẵn từ Thư viện
  Future<void> _pickVideoFromGallery() async {
    await _requestPermission(Permission.photos);
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      _loadVideo(File(pickedFile.path)); // Gửi file video vào hàm _loadVideo để nạp
    }
  }

  // Hàm quay một video mới từ Camera
  Future<void> _recordVideoFromCamera() async {
    await _requestPermission(Permission.camera);     // Xin quyền Camera
    await _requestPermission(Permission.microphone); // Xin quyền Micro để thu âm
    
    final XFile? recordedFile = await _picker.pickVideo(source: ImageSource.camera);
    
    if (recordedFile != null) {
      _loadVideo(File(recordedFile.path));
    }
  }

  // Hàm chung dùng để NẠP file video vào Trình phát
  void _loadVideo(File videoFile) {
    setState(() {
      _videoFile = videoFile;
      _videoController?.dispose(); // Xóa video cũ nếu có đang phát
      
      // Tạo controller mới nạp file video vừa chọn
      _videoController = VideoPlayerController.file(_videoFile!)
        ..initialize().then((_) {
          // Khi nạp xong thì báo UI cập nhật lại và tự động bấm Play
          setState(() {});
          _videoController!.play();
        });
    });
  }

  // Hàm dọn rác khi thoát màn hình
  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Nếu có controller và đã nạp (initialize) thành công thì mới hiện VideoPlayer
            _videoController != null && _videoController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  )
                : Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const Text('Chưa có video nào được chọn.'),
                  ),
            const SizedBox(height: 20),
            
            // CÁC NÚT ĐIỀU KHIỂN PLAY/PAUSE (Chỉ hiện khi đã nạp video)
            if (_videoController != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Nếu đang phát thì ấn vào sẽ Pause, và ngược lại
                        _videoController!.value.isPlaying
                            ? _videoController!.pause()
                            : _videoController!.play();
                      });
                    },
                    // Đổi icon Play/Pause tương ứng
                    child: Icon(
                      _videoController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            
            // CÁC NÚT CHỌN/QUAY VIDEO
            ElevatedButton(
              onPressed: _pickVideoFromGallery,
              child: const Text('Chọn video từ Gallery'),
            ),
            ElevatedButton(
              onPressed: _recordVideoFromCamera,
              child: const Text('Quay video từ Camera'),
            ),
          ],
        ),
      ),
    );
  }
}
