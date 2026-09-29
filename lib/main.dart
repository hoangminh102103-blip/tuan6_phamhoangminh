import 'package:flutter/material.dart';
import 'screens/bai1_media_picker.dart';
import 'screens/bai2_photo_capture.dart';
import 'screens/bai3_5_telephony.dart';
import 'screens/bai4_video_recorder.dart';
import 'screens/bai6_audio_player.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuan 6 - Multimedia',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Bai1MediaPicker(),
    const Bai2PhotoCapture(),
    const Bai35Telephony(),
    const Bai4VideoRecorder(),
    const Bai6AudioPlayer(),
  ];

  final List<String> _titles = [
    'Bài 1: Media Picker',
    'Bài 2: Photo Capture',
    'Bài 3 & 5: SMS & Contacts',
    'Bài 4: Video Recorder',
    'Bài 6: Audio Player',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu Bài Tập',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Bài 1: Media Picker'),
              selected: _currentIndex == 0,
              onTap: () {
                setState(() => _currentIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Bài 2: Photo Capture'),
              selected: _currentIndex == 1,
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone),
              title: const Text('Bài 3 & 5: SMS & Contacts'),
              selected: _currentIndex == 2,
              onTap: () {
                setState(() => _currentIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_call),
              title: const Text('Bài 4: Video Recorder'),
              selected: _currentIndex == 3,
              onTap: () {
                setState(() => _currentIndex = 3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack),
              title: const Text('Bài 6: Audio Player'),
              selected: _currentIndex == 4,
              onTap: () {
                setState(() => _currentIndex = 4);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
    );
  }
}
