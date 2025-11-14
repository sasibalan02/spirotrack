import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permissions_page.dart';
import 'home.dart';

class SuccessfulCmdPage extends StatefulWidget {
  const SuccessfulCmdPage({super.key});

  @override
  State<SuccessfulCmdPage> createState() => _SuccessfulCmdPageState();
}

class _SuccessfulCmdPageState extends State<SuccessfulCmdPage> {
  @override
  void initState() {
    super.initState();
    // Simulate success video duration (3 seconds)
    Future.delayed(Duration(seconds: 3), () async {
      if (mounted) {
        // Check if permissions are already granted
        bool permissionsGranted = await _checkPermissions();

        if (permissionsGranted) {
          // Permissions already granted, go directly to home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else {
          // Permissions not granted, show permissions page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PermissionsPage(),
            ),
          );
        }
      }
    });
  }

  Future<bool> _checkPermissions() async {
    final bluetoothStatus = await Permission.bluetoothScan.status;
    final locationStatus = await Permission.locationWhenInUse.status;

    return bluetoothStatus.isGranted && locationStatus.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 120,
              color: Colors.green,
            ),
            SizedBox(height: 30),
            Text(
              "Account Created Successfully!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Welcome to SpiroTrack",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              color: const Color.fromARGB(255, 70, 151, 218),
            ),
          ],
        ),
      ),
    );
  }
}