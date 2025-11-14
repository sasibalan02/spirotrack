import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'successfull_cmd.dart';
import 'hive_database.dart';
import 'dart:math';

class PersonalInfoPage extends StatefulWidget {
  final String gmail;
  final String password;

  const PersonalInfoPage({super.key, required this.gmail, required this.password});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String selectedGender = "Male";
  bool isFormComplete = false;

  @override
  void initState() {
    super.initState();
    nameController.addListener(_checkFormCompletion);
    dobController.addListener(_checkFormCompletion);
    heightController.addListener(_checkFormCompletion);
    weightController.addListener(_checkFormCompletion);
    phoneController.addListener(_checkFormCompletion);

    // Add DOB formatter listener
    dobController.addListener(_formatDOB);
  }

  void _formatDOB() {
    String text = dobController.text.replaceAll('/', '');
    String formatted = '';

    if (text.length > 0) {
      // Day
      if (text.length >= 2) {
        int day = int.tryParse(text.substring(0, 2)) ?? 0;
        if (day > 31) day = 31;
        formatted = day.toString().padLeft(2, '0');
      } else {
        formatted = text;
      }

      if (text.length > 2) {
        formatted += '/';
        // Month
        if (text.length >= 4) {
          int month = int.tryParse(text.substring(2, 4)) ?? 0;
          if (month > 12) month = 12;
          formatted += month.toString().padLeft(2, '0');
        } else {
          formatted += text.substring(2);
        }

        if (text.length > 4) {
          formatted += '/';
          // Year
          formatted += text.substring(4, text.length > 8 ? 8 : text.length);
        }
      }
    }

    if (formatted != dobController.text) {
      dobController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _checkFormCompletion() {
    setState(() {
      isFormComplete = nameController.text.isNotEmpty &&
          dobController.text.length == 10 &&
          heightController.text.isNotEmpty &&
          weightController.text.isNotEmpty &&
          phoneController.text.length == 10;
    });
  }

  String _generateRandomUID() {
    Random random = Random();
    int uid = 100000 + random.nextInt(900000);
    return uid.toString();
  }

  void createAccount() async {
    int age = _calculateAge(dobController.text);
    String randomUID = _generateRandomUID();

    Map<String, dynamic> personalData = {
      'name': nameController.text,
      'dob': dobController.text,
      'age': age,
      'gender': selectedGender,
      'height': heightController.text + ' cm',
      'weight': weightController.text + ' kg',
      'phone': phoneController.text,
      'uid': randomUID,
      'profileImage': null,
    };

    // Save with gmail and password
    await HiveDatabase.saveUserData(widget.gmail, widget.password, personalData);
    await HiveDatabase.setCurrentUser(widget.gmail);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessfulCmdPage(),
      ),
    );
  }

  int _calculateAge(String dob) {
    try {
      List<String> parts = dob.split('/');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);

        DateTime birthDate = DateTime(year, month, day);
        DateTime today = DateTime.now();

        int age = today.year - birthDate.year;
        if (today.month < birthDate.month ||
            (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }
        return age;
      }
    } catch (e) {
      return 21;
    }
    return 21;
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    heightController.dispose();
    weightController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Personal Information",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.only(left: 56),
                    child: Text(
                      widget.gmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable form
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Name (Only characters and dots)
                  _buildTextField(
                    "Name",
                    nameController,
                    Icons.person,
                    [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z. ]')),
                    ],
                  ),
                  SizedBox(height: 15),

                  // Date of Birth (Only numbers and auto-format)
                  _buildTextField(
                    "Date of Birth (DD/MM/YYYY)",
                    dobController,
                    Icons.calendar_today,
                    [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 15),

                  // Gender Dropdown
                  _buildGenderDropdown(),
                  SizedBox(height: 15),

                  // Height (Only 3 digits)
                  _buildTextField(
                    "Height (cm)",
                    heightController,
                    Icons.height,
                    [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 15),

                  // Weight (Only 3 digits)
                  _buildTextField(
                    "Weight (kg)",
                    weightController,
                    Icons.monitor_weight,
                    [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 15),

                  // Phone Number (Only 10 digits)
                  _buildTextField(
                    "Phone Number",
                    phoneController,
                    Icons.phone,
                    [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 30),
                  // Create Account Button (Bottom Right)
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: isFormComplete ? createAccount : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFormComplete
                              ? const Color.fromARGB(255, 70, 151, 218)
                              : Colors.grey,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Create Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon,
      List<TextInputFormatter> inputFormatters, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          icon: Icon(icon, color: Colors.grey[700]),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
      child: Row(
        children: [
          Icon(Icons.wc, color: Colors.grey[700]),
          SizedBox(width: 15),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: InputDecoration(
                labelText: "Gender",
                border: InputBorder.none,
              ),
              items: ["Male", "Female", "Other"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedGender = newValue!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}