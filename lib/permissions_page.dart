import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  bool bluetoothGranted = false;
  bool locationGranted = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final bluetoothStatus = await Permission.bluetoothScan.status;
    final locationStatus = await Permission.locationWhenInUse.status;

    setState(() {
      bluetoothGranted = bluetoothStatus.isGranted;
      locationGranted = locationStatus.isGranted;
    });

    // Auto-navigate if both permissions are granted
    if (bluetoothGranted && locationGranted) {
      _navigateToHome();
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      isLoading = true;
    });

    // Request Bluetooth permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    setState(() {
      bluetoothGranted = statuses[Permission.bluetoothScan]?.isGranted ?? false;
      locationGranted = statuses[Permission.locationWhenInUse]?.isGranted ?? false;
      isLoading = false;
    });

    // Check if all permissions are granted
    if (bluetoothGranted && locationGranted) {
      _navigateToHome();
    } else {
      _showPermissionDeniedDialog();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permissions Required'),
        content: Text(
          'Bluetooth and Location permissions are required to connect to spirometer devices. Please grant permissions in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30),

              // Icon
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 70, 151, 218).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bluetooth_searching,
                  size: 50,
                  color: const Color.fromARGB(255, 70, 151, 218),
                ),
              ),
              SizedBox(height: 25),

              // Title
              Text(
                "Permissions Required",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),

              // Description
              Text(
                "SpiroTrack needs Bluetooth and Location permissions to connect with your spirometer device.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // Permission Items
              _buildPermissionItem(
                icon: Icons.bluetooth,
                title: "Bluetooth",
                description: "Connect with spirometer",
                granted: bluetoothGranted,
              ),
              SizedBox(height: 15),

              _buildPermissionItem(
                icon: Icons.location_on,
                title: "Location",
                description: "For device discovery",
                granted: locationGranted,
              ),
              SizedBox(height: 35),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _requestPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 70, 151, 218),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    "Grant Permissions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required bool granted,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: granted ? Colors.green : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            spreadRadius: 1,
            blurRadius: 4,
            color: Colors.black12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: granted
                  ? Colors.green.withOpacity(0.1)
                  : const Color.fromARGB(255, 70, 151, 218).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: granted ? Colors.green : const Color.fromARGB(255, 70, 151, 218),
              size: 24,
            ),
          ),
          SizedBox(width: 12),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (granted) ...[
                      SizedBox(width: 6),
                      Icon(Icons.check_circle, color: Colors.green, size: 18),
                    ],
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}