import 'package:flutter/material.dart';

class ExerciseBody extends StatelessWidget {
  const ExerciseBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: [
        // First Container - Suggested Exercise
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

  // First Container - Suggested Exercise
  Widget _buildSuggestedExercise(BuildContext context) {
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
              "Suggested Exercise",
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
                  builder: (context) => VideoPlayerPage(
                    title: "Suggested Exercise",
                    videoUrl: "suggested_exercise_video.mp4",
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
                  image: AssetImage('assets/suggested_exercise.jpg'),
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
        ],
      ),
    );
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
          _buildExerciseRow(context, "Easy", "easy_breathing.jpg", "easy_video.mp4", Colors.green),
          SizedBox(height: 10),
          
          // Medium Level
          _buildExerciseRow(context, "Medium", "medium_breathing.jpg", "medium_video.mp4", Colors.orange),
          SizedBox(height: 10),
          
          // Hard Level
          _buildExerciseRow(context, "Hard", "hard_breathing.jpg", "hard_video.mp4", Colors.red),
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
                  image: AssetImage('assets/$imagePath'),
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
                  image: AssetImage('assets/games.jpg'),
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

// Video Player Page
class VideoPlayerPage extends StatelessWidget {
  final String title;
  final String videoUrl;

  const VideoPlayerPage({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 70, 151, 218),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Video Player",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      videoUrl,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              "Video content will be displayed here",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
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
      {"name": "Game 1", "image": "game1.jpg", "video": "game1_video.mp4"},
      {"name": "Game 2", "image": "game2.jpg", "video": "game2_video.mp4"},
      {"name": "Game 3", "image": "game3.jpg", "video": "game3_video.mp4"},
      {"name": "Game 4", "image": "game4.jpg", "video": "game4_video.mp4"},
      {"name": "Game 5", "image": "game5.jpg", "video": "game5_video.mp4"},
      {"name": "Game 6", "image": "game6.jpg", "video": "game6_video.mp4"},
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
                    image: AssetImage('assets/${games[index]["image"]}'),
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