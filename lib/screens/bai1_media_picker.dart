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

  Future<void> _requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    await _requestPermission(
      isVideo ? Permission.storage : Permission.photos,
    );

    final XFile? pickedFile = isVideo
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(
            source: source,
            imageQuality: 100,
            maxWidth: 1920,
            maxHeight: 1080,
          );

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
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
            const SnackBar(content: Text('No media selected')));
      }
    }
  }

  Future<void> _captureMedia(bool isVideo) async {
    await _requestPermission(Permission.camera);
    if (isVideo) {
      await _requestPermission(Permission.microphone);
    }

    final XFile? capturedFile = isVideo
        ? await _picker.pickVideo(source: ImageSource.camera)
        : await _picker.pickImage(source: ImageSource.camera);

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
            const SnackBar(content: Text('No media captured')));
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
            _mediaFile == null
                ? const Text('Chưa chọn ảnh hoặc video.')
                : _videoController != null
                    ? (_videoController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          )
                        : const SizedBox(
                            height: 300,
                            child: Center(child: CircularProgressIndicator()),
                          ))
                    : Image.file(_mediaFile!, height: 300),
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

