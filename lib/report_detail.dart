import 'package:flutter/material.dart';
import 'hive_database.dart';

class ReportDetailPage extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportDetailPage({super.key, required this.report});

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

  void _deleteReport(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Report'),
        content: Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      String timestamp = report['timestamp'] ?? '';
      await HiveDatabase.deleteReport(timestamp);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String status = report['status'] ?? 'N/A';
    Color statusColor = _getStatusColor(status);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 70, 151, 218),
        title: Text(
          "Report Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () => _deleteReport(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Information Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 2,
                    blurRadius: 8,
                    color: Colors.black12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Test Information",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15),

                  // Date, Time and Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report['date'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            report['time'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),

                  Divider(height: 30, color: Colors.grey[300]),

                  // Device Name
                  Row(
                    children: [
                      Icon(
                        Icons.bluetooth,
                        color: const Color.fromARGB(255, 70, 151, 218),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Device: ${report['deviceName'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Readings Section
            Text(
              "Spirometry Readings",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 15),

            // Readings Grid Container
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 2,
                    blurRadius: 8,
                    color: Colors.black12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // First Row - FVC and PEF
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadingGridItem(
                          'FVC',
                          report['FVC']?.toDouble() ?? 0.0,
                          'L',
                          Colors.blue,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: _buildReadingGridItem(
                          'PEF',
                          report['PEF']?.toDouble() ?? 0.0,
                          'L/min',
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  // Second Row - FEV1 and FEV1/FVC
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadingGridItem(
                          'FEV1',
                          report['FEV1']?.toDouble() ?? 0.0,
                          'L',
                          Colors.orange,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: _buildReadingGridItem(
                          'FEV1/FVC',
                          report['FEV1_FVC']?.toDouble() ?? 0.0,
                          '%',
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingGridItem(String label, double value, String unit, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),

          // Value with unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toStringAsFixed(1),
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
          SizedBox(height: 15),

          // Graph
          _buildMiniGraph(value, unit == '%' ? value : (value * 20), color),
        ],
      ),
    );
  }

  Widget _buildMiniGraph(double value, double percentage, Color color) {
    // Normalize percentage to 0-100
    double normalizedPercentage = percentage.clamp(0.0, 100.0);

    return Column(
      children: [
        // Graph Bar
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Filled portion
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: (80 * normalizedPercentage / 100),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              // Value text on top
              if (normalizedPercentage > 10)
                Positioned(
                  bottom: 5,
                  child: Text(
                    '${normalizedPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: normalizedPercentage > 50 ? Colors.white : color,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),

        // Reference line
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text('50', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text('100', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }
}