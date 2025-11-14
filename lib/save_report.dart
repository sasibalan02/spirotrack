import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'hive_database.dart';
import 'package:intl/intl.dart';
import 'home.dart';

class SaveReportPage extends StatefulWidget {
  final BluetoothDevice device;

  const SaveReportPage({super.key, required this.device});

  @override
  State<SaveReportPage> createState() => _SaveReportPageState();
}

class _SaveReportPageState extends State<SaveReportPage> {
  String _connectionState = 'Connecting...';
  List<String> _receivedData = [];
  BluetoothCharacteristic? _targetCharacteristic;
  StreamSubscription? _dataSubscription;
  StreamSubscription? _connectionSubscription;
  bool _isListening = false;

  // ESP32 UUIDs
  static const String serviceUUID = "12345678-1234-5678-1234-56789abcdef0";
  static const String characteristicUUID = "abcdef12-3456-7890-abcd-ef1234567890";

  // Parsed spirometry values
  Map<String, dynamic>? _latestReport;
  bool _showSaveButton = false;

  @override
  void initState() {
    super.initState();
    _listenToConnectionState();
    _discoverServicesAndListen();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  void _listenToConnectionState() {
    _connectionSubscription = widget.device.connectionState.listen((state) {
      if (mounted) {
        setState(() {
          _connectionState = state == BluetoothConnectionState.connected
              ? 'Connected'
              : 'Disconnected';
        });
      }
    });
  }

  Future<void> _discoverServicesAndListen() async {
    try {
      setState(() {
        _connectionState = 'Discovering services...';
      });

      await Future.delayed(Duration(seconds: 1));

      List<BluetoothService> services = await widget.device.discoverServices();

      print('Total services found: ${services.length}');

      BluetoothService? targetService;
      for (var service in services) {
        print('Service UUID: ${service.uuid.toString()}');
        if (service.uuid.toString().toLowerCase() == serviceUUID.toLowerCase()) {
          targetService = service;
          print('✓ Found target service!');
          break;
        }
      }

      if (targetService == null) {
        setState(() {
          _connectionState = 'Service not found. Expected: $serviceUUID';
        });
        return;
      }

      for (var characteristic in targetService.characteristics) {
        print('Characteristic UUID: ${characteristic.uuid.toString()}');
        if (characteristic.uuid.toString().toLowerCase() == characteristicUUID.toLowerCase()) {
          _targetCharacteristic = characteristic;
          print('✓ Found target characteristic!');
          await _startListening();
          return;
        }
      }

      setState(() {
        _connectionState = 'Characteristic not found. Expected: $characteristicUUID';
      });

    } catch (e) {
      print('Error discovering services: $e');
      setState(() {
        _connectionState = 'Error: $e';
      });
    }
  }

  Future<void> _startListening() async {
    if (_targetCharacteristic == null) return;

    try {
      print('Starting to listen for notifications...');

      _dataSubscription = _targetCharacteristic!.lastValueStream.listen(
            (value) {
          print('📡 Received ${value.length} bytes');
          if (value.isNotEmpty) {
            String data = String.fromCharCodes(value);
            print('📩 Data: $data');

            if (mounted) {
              setState(() {
                String timestamp = DateTime.now().toString().substring(11, 19);
                _receivedData.insert(0, '$timestamp: $data');

                if (_receivedData.length > 50) {
                  _receivedData.removeLast();
                }

                // Parse the spirometry data
                _parseSpirometryData(data);
              });
            }
          }
        },
        onError: (error) {
          print('❌ Stream error: $error');
        },
        cancelOnError: false,
      );

      await Future.delayed(Duration(milliseconds: 300));
      await _targetCharacteristic!.setNotifyValue(true);
      print('✓ Notifications enabled!');

      setState(() {
        _isListening = true;
        _connectionState = 'Connected - Waiting for test data';
      });

    } catch (e) {
      print('❌ Error in _startListening: $e');
      if (mounted) {
        setState(() {
          _connectionState = 'Error: $e';
          _isListening = false;
        });
      }
    }
  }

  void _parseSpirometryData(String data) {
    // Expected format: "FEV1: 2500 mL, FVC: 3200 mL, PEF: 120 L/min, Ratio: 78.12%"
    try {
      RegExp fev1Regex = RegExp(r'FEV1:\s*(\d+)\s*mL');
      RegExp fvcRegex = RegExp(r'FVC:\s*(\d+)\s*mL');
      RegExp pefRegex = RegExp(r'PEF:\s*(\d+)\s*L/min');
      RegExp ratioRegex = RegExp(r'Ratio:\s*([\d.]+)%');

      var fev1Match = fev1Regex.firstMatch(data);
      var fvcMatch = fvcRegex.firstMatch(data);
      var pefMatch = pefRegex.firstMatch(data);
      var ratioMatch = ratioRegex.firstMatch(data);

      if (fev1Match != null && fvcMatch != null && pefMatch != null && ratioMatch != null) {
        double fev1 = int.parse(fev1Match.group(1)!).toDouble(); // Keep in mL
        double fvc = int.parse(fvcMatch.group(1)!).toDouble();   // Keep in mL
        double pef = int.parse(pefMatch.group(1)!).toDouble();
        double ratio = double.parse(ratioMatch.group(1)!);

        DateTime now = DateTime.now();
        String date = DateFormat('dd/MM/yyyy').format(now);
        String time = DateFormat('HH:mm:ss').format(now);
        String timestamp = now.millisecondsSinceEpoch.toString();

        // Determine status based on FVC value with UPDATED thresholds
        String status = _determineStatus(fvc);

        setState(() {
          _latestReport = {
            'FEV1': fev1,
            'FVC': fvc,
            'PEF': pef,
            'FEV1_FVC': ratio,
            'date': date,
            'time': time,
            'timestamp': timestamp,
            'status': status,
            'deviceName': widget.device.platformName.isNotEmpty
                ? widget.device.platformName
                : 'Unknown Device',
          };
          _showSaveButton = true;
          _connectionState = 'Test Complete - Ready to Save';
        });

        print('✅ Parsed Report: $_latestReport');
      }
    } catch (e) {
      print('Error parsing spirometry data: $e');
    }
  }

  // UPDATED status determination logic
  String _determineStatus(double fvc) {
    if (fvc > 1500) return 'Excellent';
    if (fvc > 1200 && fvc <= 1500) return 'Good';
    if (fvc > 900 && fvc <= 1200) return 'Better';
    if (fvc <= 900) return 'Poor';
    // For values between 800 and 900
    return 'Better';
  }

  Future<void> _saveReport() async {
    if (_latestReport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No test data to save'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await HiveDatabase.saveReport(_latestReport!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Small delay to show the success message, then navigate to home
        await Future.delayed(Duration(milliseconds: 1500));

        if (mounted) {
          // Navigate to HomePage and remove all previous routes
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
                (route) => false,
          );
        }
      }
    } catch (e) {
      print('Error saving report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearData() {
    setState(() {
      _receivedData.clear();
      _latestReport = null;
      _showSaveButton = false;
      _connectionState = 'Connected - Waiting for test data';
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'better':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceName = widget.device.platformName.isNotEmpty
        ? widget.device.platformName
        : 'Unknown Device';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 70, 151, 218),
        title: Text(
          "Spirometry Test",
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
            // Device Info Header
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 5,
                    color: Colors.black12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _connectionState.contains('Connected')
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth,
                    color: _connectionState.contains('Connected')
                        ? Colors.green
                        : Colors.grey,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deviceName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          _connectionState,
                          style: TextStyle(
                            fontSize: 12,
                            color: _connectionState.contains('Connected')
                                ? Colors.green
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isListening)
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fiber_manual_record,
                        color: Colors.green,
                        size: 12,
                      ),
                    ),
                ],
              ),
            ),

            // Test Results Display
            if (_latestReport != null)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      // Status Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_latestReport!['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _getStatusColor(_latestReport!['status']),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 60,
                              color: _getStatusColor(_latestReport!['status']),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Test Status: ${_latestReport!['status']}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(_latestReport!['status']),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${_latestReport!['date']} at ${_latestReport!['time']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Results Grid
                      Text(
                        'Spirometry Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: _buildResultCard(
                              'FEV1',
                              _latestReport!['FEV1'].toStringAsFixed(0),
                              'mL',
                              Colors.orange,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildResultCard(
                              'FVC',
                              _latestReport!['FVC'].toStringAsFixed(0),
                              'mL',
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildResultCard(
                              'PEF',
                              _latestReport!['PEF'].toStringAsFixed(0),
                              'L/min',
                              Colors.green,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _buildResultCard(
                              'FEV1/FVC',
                              _latestReport!['FEV1_FVC'].toStringAsFixed(1),
                              '%',
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.air,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 20),
                      Text(
                        _isListening
                            ? 'Ready for Test'
                            : 'Connecting...',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _isListening
                            ? 'Blow into the spirometer to start'
                            : 'Please wait...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_isListening) ...[
                        SizedBox(height: 30),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: const Color.fromARGB(255, 70, 151, 218),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  if (_showSaveButton) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveReport,
                        icon: Icon(Icons.save),
                        label: Text('Save Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _clearData,
                        icon: Icon(Icons.refresh),
                        label: Text('New Test'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 70, 151, 218),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(
                            color: const Color.fromARGB(255, 70, 151, 218),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ] else
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          _isListening
                              ? 'Waiting for spirometer data...'
                              : 'Connecting to device...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String label, String value, String unit, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
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
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(width: 5),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}