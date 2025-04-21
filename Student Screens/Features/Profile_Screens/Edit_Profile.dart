import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _universityController;
  late TextEditingController _dateOfBirthController;
  String? _selectedGender;
  String? _selectedFaculty;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _firstNameController = TextEditingController(text: userData['firstName']);
          _lastNameController = TextEditingController(text: userData['lastName']);
          _emailController = TextEditingController(text: userData['email']);
          _phoneController = TextEditingController(text: userData['phone']);
          _cityController = TextEditingController(text: userData['city']);
          _universityController = TextEditingController(text: userData['university']);
          _dateOfBirthController = TextEditingController(text: userData['dateOfBirth']);
          _selectedGender = userData['gender'];
          _selectedFaculty = userData['faculty'];
          _isLoading = false; // البيانات خلصت تحميل
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
            'city': _cityController.text.trim(),
            'university': _universityController.text.trim(),
            'dateOfBirth': _dateOfBirthController.text.trim(),
            'gender': _selectedGender,
            'faculty': _selectedFaculty,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile updated successfully!',
                style: TextStyle(color: Colors.white), // نص أبيض
              ),
              backgroundColor: Color(0xFF2252A1), // خلفية زرقاء
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile. Please try again.',
              style: TextStyle(color: Colors.white), // نص أبيض
            ),
            backgroundColor: Color(0xFF2252A1), // خلفية زرقاء
          ),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(16), // كرف كبير
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2252A1))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // الخلفية بيضاء
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2252A1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(
              color: Color(0xFF2252A1),
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_firstNameController, 'First Name'),
                _buildTextField(_lastNameController, 'Last Name'),
                _buildTextField(_emailController, 'Email', isEmail: true),
                _buildTextField(_phoneController, 'Phone', isPhone: true),
                _buildTextField(_cityController, 'City'),
                _buildTextField(_universityController, 'University'),
                _buildTextField(_dateOfBirthController, 'Date of Birth'),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: _inputDecoration('Gender'),
                  items: ['Male', 'Female'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator: (value) => value == null || value.isEmpty ? 'Please select your gender' : null,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedFaculty,
                  decoration: _inputDecoration('Faculty'),
                  items: [
                    'Business Information System',
                    'Information System',
                    'Network System',
                    'Computer Science',
                    'Artificial Intelligence',
                  ].map((faculty) {
                    return DropdownMenuItem(
                      value: faculty,
                      child: Text(faculty),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedFaculty = value),
                  validator: (value) => value == null || value.isEmpty ? 'Please select your faculty' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _updateProfile,
                  label: Text(
                    "Update Profile",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2252A1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isEmail = false, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: _inputDecoration(label),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter your $label';
          if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Enter a valid email';
          }
          if (isPhone && !RegExp(r'^[0-9]{11}$').hasMatch(value)) {
            return 'Phone must be exactly 11 digits';
          }
          return null;
        },
      ),
    );
  }
}
