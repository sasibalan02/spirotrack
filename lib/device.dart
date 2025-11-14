import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'save_report.dart';

class DeviceBody extends StatefulWidget {
  const DeviceBody({Key? key}) : super(key: key);

  @override
  State<DeviceBody> createState() => _DeviceBodyState();
}

class _DeviceBodyState extends State<DeviceBody> with WidgetsBindingObserver {
  bool _isBluetoothOn = false;
  bool _isLocationOn = false;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkServices();
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _checkTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkServices();
    }
  }

  void _startPeriodicCheck() {
    _checkTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _checkServices();
    });
  }

  Future<void> _checkServices() async {
    final bluetoothStatus = await Permission.bluetooth.serviceStatus;
    final locationStatus = await Permission.location.serviceStatus;

    if (mounted) {
      setState(() {
        _isBluetoothOn = bluetoothStatus.isEnabled;
        _isLocationOn = locationStatus.isEnabled;
      });
    }
  }

  void _openBluetoothSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
  }

  void _openLocationSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.location);
  }

  void _navigateToBluetoothDevices() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BluetoothDevicesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool bothServicesOn = _isBluetoothOn && _isLocationOn;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          SizedBox(height: 10),

          // Illustration
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phone_android,
              size: 50,
              color: const Color.fromARGB(255, 70, 151, 218),
            ),
          ),
          SizedBox(height: 15),

          Text(
            'Before you send items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),

          Text(
            'Turn on wireless services',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20),

          // ListView with services
          Expanded(
            child: ListView(
              children: [
                _buildServiceItem(
                  icon: Icons.location_on,
                  title: 'Location',
                  description: 'For device discovery',
                  isOn: _isLocationOn,
                  onTap: _openLocationSettings,
                ),
                SizedBox(height: 12),

                _buildServiceItem(
                  icon: Icons.bluetooth,
                  title: 'Bluetooth',
                  description: 'For connecting devices',
                  isOn: _isBluetoothOn,
                  onTap: _openBluetoothSettings,
                ),
              ],
            ),
          ),

          Spacer(),

          // Next Button (Medium Size)
          Center(
            child: SizedBox(
              width: 200,
              height: 45,
              child: ElevatedButton(
                onPressed: bothServicesOn ? _navigateToBluetoothDevices : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bothServicesOn
                      ? const Color.fromARGB(255, 70, 151, 218)
                      : Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: Text(
                  'NEXT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isOn,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!, width: 1),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: isOn ? Colors.green : Colors.grey[600],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),

          if (isOn)
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.green,
                size: 20,
              ),
            )
          else
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 122, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text(
                'Turn on',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Bluetooth Devices Page - REMOVED BottomNavigationBar
class BluetoothDevicesPage extends StatefulWidget {
  const BluetoothDevicesPage({Key? key}) : super(key: key);

  @override
  State<BluetoothDevicesPage> createState() => _BluetoothDevicesPageState();
}

class _BluetoothDevicesPageState extends State<BluetoothDevicesPage> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _scanResults.clear();
    });

    try {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          _scanResults = results;
        });
      });

      await Future.delayed(Duration(seconds: 10));
      await FlutterBluePlus.stopScan();
    } catch (e) {
      print('Error scanning: $e');
    }

    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: Duration(seconds: 15));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SaveReportPage(device: device),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 70, 151, 218),
        title: Text(
          "SPIROTRACK",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(height: 30),

            Icon(
              Icons.bluetooth,
              size: 60,
              color: const Color.fromARGB(255, 70, 151, 218),
            ),
            SizedBox(height: 15),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Devices',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  IconButton(
                    onPressed: _isScanning ? null : _startScan,
                    icon: Icon(
                      Icons.refresh,
                      color: _isScanning
                          ? Colors.grey
                          : const Color.fromARGB(255, 70, 151, 218),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            if (_isScanning)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color.fromARGB(255, 70, 151, 218),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Scanning...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: _scanResults.isEmpty && !_isScanning
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bluetooth_disabled,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 15),
                    Text(
                      'No devices found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap refresh to scan again',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                itemCount: _scanResults.length,
                itemBuilder: (context, index) {
                  final result = _scanResults[index];
                  final device = result.device;
                  final deviceName = device.platformName.isNotEmpty
                      ? device.platformName
                      : 'Unknown Device';

                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
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
                        Icon(
                          Icons.bluetooth,
                          color: const Color.fromARGB(255, 70, 151, 218),
                          size: 30,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deviceName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                device.remoteId.toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _connectToDevice(device),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 70, 151, 218),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          child: Text(
                            'Connect',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // ✅ REMOVED bottomNavigationBar completely
    );
  }
}