import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'report.dart';
import 'profile.dart';
import 'edit_profile.dart';
import 'device.dart';
import 'exercise.dart';
import 'hive_database.dart';
import 'report_detail.dart';
import 'main.dart'; // Import main.dart to access SplashVideoPage
import 'permissions_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int currentIndex = 0;
  late Map<String, dynamic> profileData;
  bool _checkingPermissions = false;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load profile data from Hive database
    profileData = HiveDatabase.getUserData() ?? {
      'name': 'Guest',
      'age': 0,
      'uid': '00000',
      'gender': 'Male',
      'height': '0 cm',
      'weight': '0 kg',
    };

    // Check permissions when HomePage loads
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app comes back to foreground, check permissions
    if (state == AppLifecycleState.resumed && !_checkingPermissions) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    if (_checkingPermissions) return;

    setState(() {
      _checkingPermissions = true;
    });

    final bluetoothStatus = await Permission.bluetoothScan.status;
    final locationStatus = await Permission.locationWhenInUse.status;

    setState(() {
      _checkingPermissions = false;
    });

    // If permissions are not granted, navigate to permissions page without animation
    if (!bluetoothStatus.isGranted || !locationStatus.isGranted) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => PermissionsPage()),
              (route) => false,
        );
      }
    }
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    // If we're not on the home tab (index 0), go back to home tab
    if (currentIndex != 0) {
      setState(() {
        currentIndex = 0;
      });
      return false; // Don't exit the app
    }

    // If we're on home tab, show exit confirmation with double-tap
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > Duration(seconds: 2)) {
      _lastBackPressTime = now;

      // Show snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.grey[800],
        ),
      );
      return false; // Don't exit yet
    }

    // If pressed back twice within 2 seconds, exit the app
    return true;
  }

  Widget _getCurrentBody() {
    switch (currentIndex) {
      case 0:
        return HomeBody(
          name: profileData['name'] ?? 'Guest',
          age: profileData['age'] ?? 0,
          uid: profileData['uid'] ?? '00000',
        );
      case 1:
        return ReportBody();
      case 2:
        return DeviceBody();
      case 3:
        return ExerciseBody();
      case 4:
        return ProfileBody(profileData: profileData);
      default:
        return HomeBody(
          name: profileData['name'] ?? 'Guest',
          age: profileData['age'] ?? 0,
          uid: profileData['uid'] ?? '00000',
        );
    }
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HiveDatabase.logout();

      if (mounted) {
        // Navigate to SplashVideoPage (which will then go to AccountPage)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SplashVideoPage()),
              (route) => false,
        );
      }
    }
  }

  List<Widget>? _getAppBarActions() {
    if (currentIndex == 4) {
      return [
        PopupMenuButton<String>(
          icon: Icon(Icons.menu, color: Colors.white),
          onSelected: (String value) async {
            if (value == 'edit_profile') {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(profileData: profileData),
                ),
              );
              if (result != null) {
                setState(() {
                  profileData = result;
                });
                // Update Hive database
                await HiveDatabase.updateUserData(result);
              }
            } else if (value == 'logout') {
              _logout();
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: 'edit_profile',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.grey[700]),
                    SizedBox(width: 10),
                    Text('Edit Profile'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.grey[700]),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ];
          },
        ),
      ];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Handle back button press
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 70, 151, 218),
          title: Text(
            "SPIROTRACK",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          automaticallyImplyLeading: false, // Remove back arrow
          actions: _getAppBarActions(),
        ),
        body: _getCurrentBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          backgroundColor: Colors.grey[200],
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Report'),
            BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'Device'),
            BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center), label: 'Exercise'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// HomeBody with fixed overflow issue
class HomeBody extends StatefulWidget {
  final String name;
  final int age;
  final String uid;

  const HomeBody({super.key, required this.name, required this.age, required this.uid});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  Map<String, dynamic>? lastReport;

  @override
  void initState() {
    super.initState();
    _loadLastReport();
  }

  void _loadLastReport() {
    setState(() {
      lastReport = HiveDatabase.getLastReport();
    });
  }

  Color getReadingColor(String title) {
    switch (title.toUpperCase()) {
      case 'FVC':
        return Colors.blue;
      case 'PEF':
        return Colors.green;
      case 'FEV1':
        return Colors.orange;
      case 'FEV1/FVC':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          // User info container - FIXED OVERFLOW
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  spreadRadius: 2,
                  blurRadius: 10,
                  color: Colors.black26,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            height: 120,
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - Name and UID (with Expanded to prevent overflow)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "UID: ${widget.uid}",
                        style: TextStyle(fontSize: 20),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                // Right side - Age
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("age", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    Text(widget.age.toString(),
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          // Readings grid container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 2,
                    blurRadius: 10,
                    color: Colors.black26,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title block
                  Text(
                    "Last Readings",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15),

                  if (lastReport != null) ...[
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: readingsblock(
                              context,
                              "FVC",
                              (lastReport!["FVC"] ?? 0.0).toDouble(),
                              "L",
                              getReadingColor("FVC"),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: readingsblock(
                              context,
                              "PEF",
                              (lastReport!["PEF"] ?? 0.0).toDouble(),
                              "L/min",
                              getReadingColor("PEF"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: readingsblock(
                              context,
                              "FEV1",
                              (lastReport!["FEV1"] ?? 0.0).toDouble(),
                              "L",
                              getReadingColor("FEV1"),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: readingsblock(
                              context,
                              "FEV1/FVC",
                              (lastReport!["FEV1_FVC"] ?? 0.0).toDouble(),
                              "%",
                              getReadingColor("FEV1/FVC"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    // View Report Button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportDetailPage(report: lastReport!),
                            ),
                          );
                        },
                        child: Text(
                          "View Report",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.insert_chart_outlined,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 15),
                            Text(
                              "No readings available",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Connect a device to start testing",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget readingsblock(
    BuildContext context,
    String title,
    double value,
    String unit,
    Color readingColor,
    ) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.all(Radius.circular(10)),
      border: Border.all(color: Colors.grey[300]!, width: 1),
      boxShadow: [
        BoxShadow(
          spreadRadius: 1,
          blurRadius: 5,
          color: Colors.black12,
          offset: Offset(0, 2),
        ),
      ],
    ),
    padding: EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            color: readingColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          unit,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}