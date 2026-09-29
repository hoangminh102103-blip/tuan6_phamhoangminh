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
  File? _videoFile;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();

  Future<void> _requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  // Chọn video từ Thư viện
  Future<void> _pickVideoFromGallery() async {
    await _requestPermission(Permission.photos);
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      _loadVideo(File(pickedFile.path));
    }
  }

  // Quay video từ Camera
  Future<void> _recordVideoFromCamera() async {
    await _requestPermission(Permission.camera);     
    await _requestPermission(Permission.microphone); 
    
    final XFile? recordedFile = await _picker.pickVideo(source: ImageSource.camera);
    
    if (recordedFile != null) {
      _loadVideo(File(recordedFile.path));
    }
  }

  // Nạp file video vào Trình phát
  void _loadVideo(File videoFile) {
    setState(() {
      _videoFile = videoFile;
      _videoController?.dispose(); 
      
      _videoController = VideoPlayerController.file(_videoFile!)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  // Hàm quyết định hiển thị nút Play hay Pause
  IconData _getPlayPauseIcon() {
    if (_videoController!.value.isPlaying) {
      return Icons.pause;
    } else {
      return Icons.play_arrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Dùng if-else thuần thay cho toán tử điều kiện (ternary)
            if (_videoController != null && _videoController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
            else
              Container(
                height: 200,
                alignment: Alignment.center,
                child: const Text('Chưa có video nào được chọn.'),
              ),
              
            const SizedBox(height: 20),
            
            if (_videoController != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                        }
                      });
                    },
                    child: Icon(_getPlayPauseIcon()),
                  ),
                ],
              ),
              
            const SizedBox(height: 20),
            
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
