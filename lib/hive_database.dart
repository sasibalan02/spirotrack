import 'package:hive_flutter/hive_flutter.dart';

class HiveDatabase {
  static const String userBoxName = 'userBox';
  static const String reportsBoxName = 'reportsBox';
  static const String currentUserKey = 'currentUser';

  // Initialize Hive
  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(userBoxName);
    await Hive.openBox(reportsBoxName);
  }

  // Get user box
  static Box getUserBox() {
    return Hive.box(userBoxName);
  }

  // Get reports box
  static Box getReportsBox() {
    return Hive.box(reportsBoxName);
  }

  // Save user credentials and personal data
  // Key format: gmail_userData
  static Future<void> saveUserData(String gmail, String password, Map<String, dynamic> personalData) async {
    final box = getUserBox();

    Map<String, dynamic> userData = {
      'gmail': gmail,
      'password': password,
      ...personalData,
    };

    // Save user data with gmail as part of key
    await box.put('${gmail}_userData', userData);
  }

  // Set current logged-in user
  static Future<void> setCurrentUser(String gmail) async {
    final box = getUserBox();
    await box.put(currentUserKey, gmail);
  }

  // Get current logged-in user's gmail
  static String? getCurrentUserGmail() {
    final box = getUserBox();
    return box.get(currentUserKey);
  }

  // Get user data by gmail
  static Map<String, dynamic>? getUserDataByGmail(String gmail) {
    final box = getUserBox();
    final data = box.get('${gmail}_userData');
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Get current user's data
  static Map<String, dynamic>? getUserData() {
    String? gmail = getCurrentUserGmail();
    if (gmail != null) {
      return getUserDataByGmail(gmail);
    }
    return null;
  }

  // Update user data (only personal info, not credentials)
  static Future<void> updateUserData(Map<String, dynamic> updatedData) async {
    String? gmail = getCurrentUserGmail();
    if (gmail == null) return;

    final box = getUserBox();
    final existingData = getUserDataByGmail(gmail);

    if (existingData != null) {
      // Preserve gmail and password
      Map<String, dynamic> newData = {
        'gmail': existingData['gmail'],
        'password': existingData['password'],
        ...updatedData,
      };
      await box.put('${gmail}_userData', newData);
    }
  }

  // Check if user exists
  static bool isUserLoggedIn() {
    String? gmail = getCurrentUserGmail();
    return gmail != null;
  }

  // Verify credentials
  static bool verifyCredentials(String email, String password) {
    final userData = getUserDataByGmail(email);
    if (userData != null) {
      return userData['password'] == password;
    }
    return false;
  }

  // Login user
  static Future<bool> loginUser(String email, String password) async {
    if (verifyCredentials(email, password)) {
      await setCurrentUser(email);
      return true;
    }
    return false;
  }

  // Logout - Only remove current user reference, keep all data
  static Future<void> logout() async {
    final box = getUserBox();
    await box.delete(currentUserKey);
  }

  // ============== REPORT METHODS ==============

  // Save a report (linked to user's gmail)
  static Future<void> saveReport(Map<String, dynamic> reportData) async {
    String? userGmail = getCurrentUserGmail();
    if (userGmail == null) return;

    final box = getReportsBox();
    String timestamp = reportData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    String reportId = '${userGmail}_$timestamp';

    // Add gmail to report data
    reportData['userGmail'] = userGmail;

    await box.put(reportId, reportData);
  }

  // Get all reports for current user (sorted by date, newest first)
  static List<Map<String, dynamic>> getAllReports() {
    String? userGmail = getCurrentUserGmail();
    if (userGmail == null) return [];

    final box = getReportsBox();
    List<Map<String, dynamic>> reports = [];

    for (var key in box.keys) {
      final report = box.get(key);
      if (report != null) {
        Map<String, dynamic> reportMap = Map<String, dynamic>.from(report);
        // Only include reports for current user
        if (reportMap['userGmail'] == userGmail) {
          reports.add(reportMap);
        }
      }
    }

    // Sort by timestamp (newest first)
    reports.sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));

    return reports;
  }

  // Get last report for current user
  static Map<String, dynamic>? getLastReport() {
    final reports = getAllReports();
    return reports.isNotEmpty ? reports.first : null;
  }

  // Get report by ID
  static Map<String, dynamic>? getReportById(String reportId) {
    final box = getReportsBox();
    final report = box.get(reportId);
    if (report != null) {
      return Map<String, dynamic>.from(report);
    }
    return null;
  }

  // Delete a report
  static Future<void> deleteReport(String timestamp) async {
    String? userGmail = getCurrentUserGmail();
    if (userGmail == null) return;

    final box = getReportsBox();
    String reportId = '${userGmail}_$timestamp';
    await box.delete(reportId);
  }

  // Delete all reports for a specific user
  static Future<void> deleteAllReportsForUser(String userGmail) async {
    final box = getReportsBox();
    List<String> keysToDelete = [];

    for (var key in box.keys) {
      final report = box.get(key);
      if (report != null) {
        Map<String, dynamic> reportMap = Map<String, dynamic>.from(report);
        if (reportMap['userGmail'] == userGmail) {
          keysToDelete.add(key);
        }
      }
    }

    for (var key in keysToDelete) {
      await box.delete(key);
    }
  }

  // Delete all reports for current user
  static Future<void> deleteAllReports() async {
    String? userGmail = getCurrentUserGmail();
    if (userGmail != null) {
      await deleteAllReportsForUser(userGmail);
    }
  }
}