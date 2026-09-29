import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Bai6AudioPlayer extends StatefulWidget {
  const Bai6AudioPlayer({super.key});

  @override
  State<Bai6AudioPlayer> createState() => _Bai6AudioPlayerState();
}

class _Bai6AudioPlayerState extends State<Bai6AudioPlayer> {
  late AudioPlayer _audioPlayer;
  int _currentSongIndex = 0;
  bool _isPlaying = false;

  final List<String> _songs = [
    'audios/sample1.mp3',
    'audios/sample2.mp3',
    'audios/sample3.mp3',
  ];

  final List<String> _songTitles = ['sample1', 'sample2', 'sample3'];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if(mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _nextSong();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSong() async {
    await _audioPlayer.play(AssetSource(_songs[_currentSongIndex]));
    setState(() {
      _isPlaying = true;
    });
  }

  Future<void> _pauseSong() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _stopSong() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  void _nextSong() {
    setState(() {
      if (_currentSongIndex < _songs.length - 1) {
        _currentSongIndex++;
      } else {
        _currentSongIndex = 0;
      }
      _stopSong();
      _playSong();
    });
  }

  void _previousSong() {
    setState(() {
      if (_currentSongIndex > 0) {
        _currentSongIndex--;
      } else {
        _currentSongIndex = _songs.length - 1;
      }
      _stopSong();
      _playSong();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _songTitles[_currentSongIndex],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 40),
                onPressed: _previousSong,
              ),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 40,
                ),
                onPressed: () {
                  if (_isPlaying) {
                    _pauseSong();
                  } else {
                    _playSong();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.stop, size: 40),
                onPressed: _stopSong,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 40),
                onPressed: _nextSong,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Lưu ý: Bạn cần phải có các file mp3 mẫu trong thư mục assets/audios/ để phát được.',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          )
        ],
      ),
    );
  }
}

