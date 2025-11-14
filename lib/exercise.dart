import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'hive_database.dart';

class ExerciseBody extends StatelessWidget {
  const ExerciseBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: [
        // First Container - Suggested Exercise (based on FVC)
        _buildSuggestedExercise(context),
        SizedBox(height: 15),

        // Second Container - Breathing Exercise
        _buildBreathingExercise(context),
        SizedBox(height: 15),

        // Third Container - Games
        _buildGames(context),
      ],
    );
  }

  // First Container - Suggested Exercise (selects video based on last FVC reading)
  Widget _buildSuggestedExercise(BuildContext context) {
    // Get last report to determine FVC value
    Map<String, dynamic>? lastReport = HiveDatabase.getLastReport();

    String videoPath;
    String exerciseLevel;

    if (lastReport != null) {
      double fvc = (lastReport['FVC'] ?? 0).toDouble();

      // Select video based on FVC value
      if (fvc > 1500) {
        videoPath = 'assets/videos/hard.mp4';
        exerciseLevel = 'Hard';
      } else if (fvc > 1200 && fvc <= 1500) {
        videoPath = 'assets/videos/medium.mp4';
        exerciseLevel = 'Medium';
      } else {
        videoPath = 'assets/videos/easy.mp4';
        exerciseLevel = 'Easy';
      }
    } else {
      // Default to medium difficulty if no test taken yet
      videoPath = 'assets/videos/medium.mp4';
      exerciseLevel = 'Recommended';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            spreadRadius: 1,
            blurRadius: 5,
            color: Colors.black12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Suggested Exercise",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                if (lastReport != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getLevelColor(exerciseLevel).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '$exerciseLevel Level',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getLevelColor(exerciseLevel),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerPage(
                    title: "Suggested Exercise ($exerciseLevel)",
                    videoUrl: videoPath,
                  ),
                ),
              );
            },
            child: Container(
              height: 200,
              width: double.infinity,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage('assets/images/suggest.jpg'),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (lastReport == null)
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: Text(
                'Default recommendation - Take a test for personalized exercises',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Second Container - Breathing Exercise
  Widget _buildBreathingExercise(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            spreadRadius: 1,
            blurRadius: 5,
            color: Colors.black12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Breathing Exercise",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 15),

          // Easy Level
          _buildExerciseRow(context, "Easy", "assets/images/easy.jpg", "assets/videos/easy.mp4", Colors.green),
          SizedBox(height: 10),

          // Medium Level
          _buildExerciseRow(context, "Medium", "assets/images/medium.jpg", "assets/videos/medium.mp4", Colors.orange),
          SizedBox(height: 10),

          // Hard Level
          _buildExerciseRow(context, "Hard", "assets/images/hard.jpg", "assets/videos/hard.mp4", Colors.red),
        ],
      ),
    );
  }

  Widget _buildExerciseRow(BuildContext context, String level, String imagePath, String videoUrl, Color color) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerPage(
              title: "$level Breathing Exercise",
              videoUrl: videoUrl,
            ),
          ),
        );
      },
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            // Image Section
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 15),
            // Text Section
            Expanded(
              child: Text(
                level,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color),
            SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  // Third Container - Games
  Widget _buildGames(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            spreadRadius: 1,
            blurRadius: 5,
            color: Colors.black12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              "Games",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GamesGridPage(),
                ),
              );
            },
            child: Container(
              height: 200,
              width: double.infinity,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage('assets/images/games.jpg'),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.games_outlined,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Video Player Page with actual video playback
class VideoPlayerPage extends StatefulWidget {
  final String title;
  final String videoUrl;

  const VideoPlayerPage({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showPlayButton = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoUrl);
      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      // Add listener to handle video end
      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration) {
          _controller.seekTo(Duration.zero);
          _controller.pause();
          setState(() {
            _showPlayButton = true;
          });
        }
      });
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playVideo() {
    setState(() {
      _showPlayButton = false;
    });
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 70, 151, 218),
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          height: 300,
          width: double.infinity,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: _hasError
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.white70,
                ),
                SizedBox(height: 15),
                Text(
                  "Video not found",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
              : !_isInitialized
              ? Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
              : Stack(
            children: [
              // Video Player
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              ),

              // Play Button Overlay (only shows when not playing)
              if (_showPlayButton)
                Center(
                  child: GestureDetector(
                    onTap: _playVideo,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // Progress Bar at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: const Color.fromARGB(255, 70, 151, 218),
                    bufferedColor: Colors.white30,
                    backgroundColor: Colors.white10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Games Grid Page
class GamesGridPage extends StatelessWidget {
  const GamesGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> games = [
      {"name": "Game 1", "image": "game1.jpg", "video": "assets/videos/game1.mp4"},
      {"name": "Game 2", "image": "game2.jpg", "video": "assets/videos/game2.mp4"},
      {"name": "Game 3", "image": "game3.jpg", "video": "assets/videos/game3.mp4"},
      {"name": "Game 4", "image": "game4.jpg", "video": "assets/videos/game4.mp4"},
      {"name": "Game 5", "image": "game5.jpg", "video": "assets/videos/game5.mp4"},
      {"name": "Game 6", "image": "game6.jpg", "video": "assets/videos/game6.mp4"},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 70, 151, 218),
        title: Text(
          "Games",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerPage(
                      title: games[index]["name"]!,
                      videoUrl: games[index]["video"]!,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 1,
                      blurRadius: 5,
                      color: Colors.black12,
                      offset: Offset(0, 2),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage('assets/images/${games[index]["image"]}'),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 50,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      games[index]["name"]!,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}