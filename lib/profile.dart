import 'package:flutter/material.dart';
import 'dart:io';

class ProfileBody extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const ProfileBody({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    String? profileImagePath = profileData['profileImage'];
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          // Profile header with avatar (without box decoration)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color.fromARGB(255, 70, 151, 218),
                  backgroundImage: profileImagePath != null
                      ? FileImage(File(profileImagePath))
                      : null,
                  child: profileImagePath == null
                      ? Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.white,
                        )
                      : null,
                ),
                SizedBox(height: 15),
                Text(
                  profileData['name'] ?? 'Guest',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "UID: ${profileData['uid'] ?? '00000'}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // User information list
          _buildInfoItem("Name", profileData['name'] ?? 'N/A', Icons.person_outline),
          _buildInfoItem("Date of Birth", profileData['dob'] ?? 'N/A', Icons.cake_outlined),
          _buildInfoItem("UID", profileData['uid'] ?? 'N/A', Icons.badge_outlined),
          _buildInfoItem("Gender", profileData['gender'] ?? 'N/A', Icons.wc_outlined),
          _buildInfoItem("Height", profileData['height'] ?? 'N/A', Icons.height_outlined),
          _buildInfoItem("Weight", profileData['weight'] ?? 'N/A', Icons.monitor_weight_outlined),
          _buildInfoItem("Phone", profileData['phone'] ?? 'N/A', Icons.phone_outlined),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(15),
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
          // Icon
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 70, 151, 218).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 70, 151, 218),
              size: 28,
            ),
          ),
          SizedBox(width: 15),
          // Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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