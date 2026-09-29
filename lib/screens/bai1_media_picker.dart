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
  File? _mediaFile;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();

  // Hàm xin quyền truy cập
  Future<void> _requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  // Chọn ảnh hoặc video từ Thư viện
  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    if (isVideo) {
      await _requestPermission(Permission.storage);
    } else {
      await _requestPermission(Permission.photos);
    }

    final XFile? pickedFile;
    if (isVideo) {
      pickedFile = await _picker.pickVideo(source: source);
    } else {
      pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100,
        maxWidth: 1920,
        maxHeight: 1080,
      );
    }

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile!.path);
        
        if (_mediaFile!.path.endsWith('.mp4')) {
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
            const SnackBar(content: Text('Chưa chọn file nào!')));
      }
    }
  }

  // Mở Camera để chụp ảnh hoặc quay video
  Future<void> _captureMedia(bool isVideo) async {
    await _requestPermission(Permission.camera);
    if (isVideo) {
      await _requestPermission(Permission.microphone);
    }

    final XFile? capturedFile;
    if (isVideo) {
      capturedFile = await _picker.pickVideo(source: ImageSource.camera);
    } else {
      capturedFile = await _picker.pickImage(source: ImageSource.camera);
    }

    if (capturedFile != null) {
      setState(() {
        _mediaFile = File(capturedFile!.path);
        
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
            const SizedBox(height: 30),
            
      
            if (_mediaFile == null)
              const Text('Chưa chọn ảnh hoặc video.')
            else if (_videoController != null)
              if (_videoController!.value.isInitialized)
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
              else
                const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                )
            else
              Image.file(_mediaFile!, height: 300),

            const SizedBox(height: 20),
            
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
