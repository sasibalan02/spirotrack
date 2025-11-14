import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'hive_database.dart';
import 'account.dart';
import 'home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.initHive();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: SizedBox.shrink(),
            );
          }

          // If user is logged in, go to home directly
          if (snapshot.data == true) {
            return HomePage();
          }

          // If user is not logged in, show video preloader
          return VideoPreloaderPage();
        },
      ),
    );
  }

  Future<bool> _checkUserLoggedIn() async {
    return HiveDatabase.isUserLoggedIn();
  }
}

// Video Preloader Page
class VideoPreloaderPage extends StatefulWidget {
  const VideoPreloaderPage({super.key});

  @override
  State<VideoPreloaderPage> createState() => _VideoPreloaderPageState();
}

class _VideoPreloaderPageState extends State<VideoPreloaderPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAndPlayVideo();
  }

  Future<void> _initializeAndPlayVideo() async {
    _controller = VideoPlayerController.asset('assets/videos/popupvideo.mp4');

    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
      }
    } catch (e) {
      print('Error initializing video: $e');
      // If video fails, navigate to account page anyway
      _navigateToAccount();
    }

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration && mounted) {
        _navigateToAccount();
      }
    });
  }

  void _navigateToAccount() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AccountPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitialized
          ? SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      )
          : Container(color: Colors.black),
    );
  }
}