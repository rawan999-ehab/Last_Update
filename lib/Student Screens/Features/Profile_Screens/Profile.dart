import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project/Student%20Screens/Features/Profile_Screens/Setting.dart';
import '../../Auth/login_screen.dart';
import 'Edit_Profile.dart';
import 'Interested_Field.dart';
import 'Saved_Internships.dart';

// Constants
class AppColors {
  static const primary = Color(0xFF2252A1);
  static const error = Colors.red;
  static const greyShade = Colors.grey;
}

final supabase = Supabase.instance.client;

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  String _name = 'Loading...';
  String _email = 'Loading...';
  String? _imageUrl;
  String? _userId;
  bool _isLoading = false;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle not logged in case
      return;
    }
    setState(() {
      _userId = user.uid;
    });
    await _loadUserData();
    await _loadProfileImage();
  }

  Future<void> _loadUserData() async {
    if (_userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (!mounted) return;

      if (userDoc.exists) {
        setState(() {
          _name = userDoc.data()?['firstName'] ?? 'No Name';
          _email = userDoc.data()?['email'] ?? 'No Email';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data')),
      );
      debugPrint('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProfileImage() async {
    if (_userId == null) return;

    setState(() {
      _isLoadingImage = true;
    });

    try {
      final response = await supabase
          .from('profile_images')
          .select('image_url')
          .eq('user_id', _userId!)
          .single();

      if (response['image_url'] != null) {
        setState(() {
          _imageUrl = response['image_url'];
        });
      }
    } catch (e) {
      debugPrint('No profile image found or error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage == null || _userId == null) return;

      final file = File(pickedImage.path);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('الملف المحدد غير موجود')),
          );
        }
        return;
      }

      setState(() {
        _imageFile = file;
        _isLoadingImage = true;
      });

      final fileExt = pickedImage.path.split('.').last.toLowerCase();
      final fileName = '${_userId}_profile.$fileExt';
      final filePath = fileName;

      // تحديد نوع الملف بشكل صحيح
      String mimeType;
      switch (fileExt) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        default:
          mimeType = 'image/jpeg'; // افتراض
      }

      final fileBytes = await file.readAsBytes();

      await supabase.storage
          .from('profile-images')
          .uploadBinary(
        filePath,
        fileBytes,
        fileOptions: FileOptions(
          contentType: mimeType,
          upsert: true,
        ),
      );

      // الحصول على رابط الصورة
      final imageUrl = supabase.storage
          .from('profile-images')
          .getPublicUrl(filePath);

      // حفظ البيانات في الجدول
      await supabase.from('profile_images').upsert({
        'user_id': _userId,
        'image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      setState(() {
        _imageUrl = imageUrl;
      });

    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء رفع الصورة: ${e.toString()}')),

    // رفع الملف كـ bytes
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
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
                    _logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? backgroundImage;
    if (_imageFile != null) {
      backgroundImage = FileImage(_imageFile!);
    } else if (_imageUrl != null) {
      backgroundImage = NetworkImage(_imageUrl!);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
        children: [
          SizedBox(height: 20),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              _isLoadingImage
                  ? CircularProgressIndicator(color: AppColors.primary)
                  : CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: backgroundImage,
                child: _imageUrl == null && _imageFile == null
                    ? Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 15,
                    child: Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            _name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            _email,
            style: TextStyle(color: AppColors.greyShade),
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
              backgroundColor: AppColors.primary,
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
                _buildMenuItem(Icons.settings, 'Settings', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingScreen()),
                  );
                }),
                _buildMenuItem(Icons.help, 'Help & Support'),
                _buildMenuItem(
                  Icons.logout,
                  'Logout',
                  iconColor: AppColors.error,
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
    Color iconColor = AppColors.primary,
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