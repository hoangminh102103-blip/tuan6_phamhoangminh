import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Bai6AudioPlayer extends StatefulWidget {
  const Bai6AudioPlayer({super.key});

  @override
  State<Bai6AudioPlayer> createState() => _Bai6AudioPlayerState();
}

class _Bai6AudioPlayerState extends State<Bai6AudioPlayer> {
  // Đối tượng chính để xử lý âm thanh (phát, dừng, nạp nhạc)
  late AudioPlayer _audioPlayer;
  
  // Lưu số thứ tự của bài hát đang được chọn
  int _currentSongIndex = 0;
  
  // Trạng thái cờ (đang phát nhạc hay không?)
  bool _isPlaying = false;

  // Danh sách đường dẫn file nhạc nằm trong thư mục assets
  final List<String> _songs = [
    'audios/sample1.mp3',
    'audios/sample2.mp3',
    'audios/sample3.mp3',
  ];

  // Danh sách tên bài hát để hiển thị ra màn hình
  final List<String> _songTitles = ['Bài hát 1', 'Bài hát 2', 'Bài hát 3'];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Khởi tạo trình phát nhạc

    // Lắng nghe sự kiện: Nhạc đang chạy hay đang bị dừng?
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if(mounted) {
        setState(() {
          // Nếu trạng thái của loa đang là "playing" -> gán _isPlaying = true
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Lắng nghe sự kiện: Bài hát đã chạy xong (kết thúc bài)
    _audioPlayer.onPlayerComplete.listen((event) {
      _nextSong(); // Nếu chạy xong bài thì tự động nhảy sang bài tiếp theo
    });
  }

  // Hàm xóa bộ nhớ khi thoát màn hình
  @override
  void dispose() {
    _audioPlayer.dispose(); // Giải phóng AudioPlayer để không chạy ngầm gây hao pin
    super.dispose();
  }

  // Hàm PHÁT NHẠC
  Future<void> _playSong() async {
    // Nguồn nhạc lấy từ Asset (AssetSource). Hàm play sẽ yêu cầu file mp3
    await _audioPlayer.play(AssetSource(_songs[_currentSongIndex]));
    setState(() {
      _isPlaying = true;
    });
  }

  // Hàm TẠM DỪNG NHẠC (Pause)
  Future<void> _pauseSong() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  // Hàm DỪNG HẲN NHẠC (Stop) - Nếu phát lại sẽ phát từ đầu bài
  Future<void> _stopSong() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  // Hàm BÀI TIẾP THEO (Next)
  void _nextSong() {
    setState(() {
      // Nếu chưa phải bài cuối cùng -> tăng index lên 1 (chuyển bài)
      if (_currentSongIndex < _songs.length - 1) {
        _currentSongIndex++;
      } else {
        // Nếu đang ở bài cuối cùng thì vòng lại bài đầu tiên (index = 0)
        _currentSongIndex = 0;
      }
      _stopSong(); // Dừng bài cũ đang phát (nếu có)
      _playSong(); // Phát bài mới
    });
  }

  // Hàm LÙI LẠI BÀI TRƯỚC (Previous)
  void _previousSong() {
    setState(() {
      // Nếu đang không phải bài đầu tiên -> lùi index xuống 1
      if (_currentSongIndex > 0) {
        _currentSongIndex--;
      } else {
        // Nếu đang ở bài đầu thì lùi thẳng về bài cuối cùng
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
          // Hiển thị tên bài hát dựa vào biến _currentSongIndex
          Text(
            _songTitles[_currentSongIndex],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // KHU VỰC CÁC NÚT ĐIỀU KHIỂN NHẠC
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nút lùi bài
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 40),
                onPressed: _previousSong,
              ),
              // Nút Play / Pause (Chuyển đổi linh hoạt)
              IconButton(
                icon: Icon(
                  // Nếu _isPlaying là true thì hiện nút Pause, ngược lại hiện nút Play
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 40,
                ),
                onPressed: () {
                  if (_isPlaying) {
                    _pauseSong(); // Đang phát thì ấn vào sẽ Pause
                  } else {
                    _playSong();  // Đang tắt thì ấn vào sẽ Play
                  }
                },
              ),
              // Nút Dừng hẳn (Stop)
              IconButton(
                icon: const Icon(Icons.stop, size: 40),
                onPressed: _stopSong,
              ),
              // Nút Tới bài sau (Next)
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
