import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const EditProfilePage({super.key, required this.profileData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController dobController;
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController phoneController;
  String selectedGender = "Male";
  String? profileImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profileData['name']);
    dobController = TextEditingController(text: widget.profileData['dob']);
    heightController = TextEditingController(
        text: widget.profileData['height']?.replaceAll(' cm', ''));
    weightController = TextEditingController(
        text: widget.profileData['weight']?.replaceAll(' kg', ''));
    phoneController =
        TextEditingController(text: widget.profileData['phone'] ?? '');
    selectedGender = widget.profileData['gender'];
    profileImagePath = widget.profileData['profileImage'];
    
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

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      profileImagePath = image.path;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      profileImagePath = image.path;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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
      return widget.profileData['age'] ?? 0;
    }
    return widget.profileData['age'] ?? 0;
  }

  void saveProfile() {
    Map<String, dynamic> updatedData = {
      'name': nameController.text,
      'dob': dobController.text,
      'age': _calculateAge(dobController.text),
      'uid': widget.profileData['uid'],
      'gender': selectedGender,
      'height': heightController.text + ' cm',
      'weight': weightController.text + ' kg',
      'phone': phoneController.text,
      'gmail': widget.profileData['gmail'],
      'profileImage': profileImagePath,
    };
    Navigator.pop(context, updatedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 70, 151, 218),
        title: Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),
            
            // Profile Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color.fromARGB(255, 70, 151, 218),
                    backgroundImage: profileImagePath != null
                        ? FileImage(File(profileImagePath!))
                        : null,
                    child: profileImagePath == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 70, 151, 218),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Tap to change photo",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 30),
            
            // Name (Only characters and dots)
            _buildTextField(
              "Name",
              nameController,
              Icons.person_outline,
              [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z. ]')),
              ],
            ),
            SizedBox(height: 15),
            
            // Date of Birth (Only numbers with auto-format)
            _buildTextField(
              "Date of Birth (DD/MM/YYYY)",
              dobController,
              Icons.cake_outlined,
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
              Icons.height_outlined,
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
              Icons.monitor_weight_outlined,
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
            
            // Save Button
            ElevatedButton(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 70, 151, 218),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Save Changes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
          icon: Icon(icon, color: const Color.fromARGB(255, 70, 151, 218)),
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
          Icon(Icons.wc_outlined,
              color: const Color.fromARGB(255, 70, 151, 218)),
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