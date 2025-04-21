import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/Student%20Screens/Features/Profile_Screens/Setting.dart';
import '../../Auth/login_screen.dart';
import 'Edit_Profile.dart';
import 'Interested_Field.dart';
import 'Saved_Internships.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProfileScreen(),
  ));
}

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Text(
              'Confirm logout?',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 21, color: Colors.black54),
            ),
          ),
          content: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _logout();  // تنفيذ تسجيل الخروج
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2252A1),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white38,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // دالة تسجيل الخروج التي تعيد المستخدم إلى صفحة تسجيل الدخول
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2252A1)),
          onPressed: () {},
        ),
        title: Text(
          "Profile",
          style: TextStyle(
              color: Color(0xFF2252A1),
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    backgroundColor: Color(0xFF2252A1),
                    radius: 15,
                    child: Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Rawan Ehab',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'rawan99@gmail.com',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2252A1),
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'Edit Profile',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(Icons.school, 'Interested Field', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InterestedField()),
                  );
                }),
                _buildMenuItem(Icons.bookmark, 'Saved Internships', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SavedInternshipScreen()),
                  );
                }),
                _buildMenuItem(Icons.history, 'Student History'),
                _buildMenuItem(Icons.bookmark, 'Setting', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingScreen()),
                  );
                }),
                _buildMenuItem(Icons.help, 'Help & Support'),
                _buildMenuItem(
                  Icons.logout,
                  'Logout',
                  iconColor: Colors.red, // اللون الأحمر للأيقونة
                  onTap: _showLogoutDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {
    Color iconColor = const Color(0xFF2252A1),
    Color textColor = Colors.black,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }
}
