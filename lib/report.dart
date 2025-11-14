 import 'package:flutter/material.dart';
import 'hive_database.dart';
import 'report_detail.dart';

class ReportBody extends StatefulWidget {
  const ReportBody({super.key});

  @override
  State<ReportBody> createState() => _ReportBodyState();
}

class _ReportBodyState extends State<ReportBody> {
  List<Map<String, dynamic>> reports = [];
  Set<String> selectedReports = {};
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    setState(() {
      reports = HiveDatabase.getAllReports();
    });
  }

  void _toggleSelection(String timestamp) {
    setState(() {
      if (selectedReports.contains(timestamp)) {
        selectedReports.remove(timestamp);
      } else {
        selectedReports.add(timestamp);
      }
      
      if (selectedReports.isEmpty) {
        isSelectionMode = false;
      }
    });
  }

  void _deleteSelectedReports() async {
    if (selectedReports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select reports to delete'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Reports'),
        content: Text(
          'Are you sure you want to delete ${selectedReports.length} report(s)?'
        ),
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
      for (String timestamp in selectedReports) {
        await HiveDatabase.deleteReport(timestamp);
      }
      
      setState(() {
        selectedReports.clear();
        isSelectionMode = false;
      });
      
      _loadReports();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reports deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelSelection() {
    setState(() {
      selectedReports.clear();
      isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom AppBar for selection mode
        if (isSelectionMode)
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: _cancelSelection,
                ),
                SizedBox(width: 10),
                Text(
                  '${selectedReports.length} selected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteSelectedReports,
                ),
              ],
            ),
          ),
        
        // Report List
        Expanded(
          child: reports.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    return _buildReportCard(reports[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'No Reports Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Connect a device and take a test',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    String timestamp = report['timestamp'] ?? '';
    bool isSelected = selectedReports.contains(timestamp);

    return GestureDetector(
      onLongPress: () {
        setState(() {
          isSelectionMode = true;
          selectedReports.add(timestamp);
        });
      },
      onTap: () {
        if (isSelectionMode) {
          _toggleSelection(timestamp);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailPage(report: report),
            ),
          ).then((_) => _loadReports());
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              spreadRadius: 1,
              blurRadius: 5,
              color: Colors.black12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      if (isSelectionMode)
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            isSelected 
                              ? Icons.check_circle 
                              : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                        ),
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
                    ],
                  ),
                  Text(
                    report['status'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(report['status'] ?? 'N/A'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
}