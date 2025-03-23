import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddInternship extends StatefulWidget {
  @override
  _AddInternshipScreenState createState() => _AddInternshipScreenState();
}

class _AddInternshipScreenState extends State<AddInternship> {
  final _formKey = GlobalKey<FormState>();
  File? _companyImage;
  String companyName = '';
  String title = '';
  String location = '';
  String internship = 'Internship';
  String type = 'On-site';
  String duration = '';
  String whatYouWillBeDoing = '';
  String whatWeAreLookingFor = '';
  String preferredQualifications = '';

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _companyImage = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print("Form Submitted Successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2252A1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Add New Internship",
          style: TextStyle(color: Color(0xFF2252A1), fontSize: 21, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "This page allows admins to add new internship opportunities to the application, "
                          "enabling students to register for these internships.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(child: buildImagePicker()),
                    buildTextField("Company Name", Icons.add_business_outlined, (value) => companyName = value!),
                    buildTextField("Internship Title", Icons.work, (value) => title = value!),
                    buildTextField("Location", Icons.location_on, (value) => location = value!),
                    buildDropdownField("Internship", Icons.style_rounded, ["Internship"], (value) => internship = value!),
                    buildDropdownField("Internship Type", Icons.business, ["On-site", "Remote", "Hybrid"], (value) => type = value!),
                    buildTextField("Duration (e.g., 3 months)", Icons.access_time, (value) => duration = value!),
                    buildTextField("What You Will Be Doing", Icons.description, (value) => whatYouWillBeDoing = value!, maxLines: 3),
                    buildTextField("What We Are Looking For", Icons.description_outlined, (value) => whatWeAreLookingFor = value!, maxLines: 3),
                    buildTextField("Preferred Qualifications", Icons.description, (value) => preferredQualifications = value!, maxLines: 3),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2252A1),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Submit", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImagePicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: _companyImage != null
                ? ClipOval(
              child: Image.file(_companyImage!, fit: BoxFit.cover, width: 120, height: 120),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 40, color: Colors.blue),
                Text("Upload Image", style: TextStyle(color: Colors.blue)),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildTextField(String label, IconData icon, Function(String?) onSaved, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.blue),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? "Enter $label" : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget buildDropdownField(String label, IconData icon, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<String>(
        value: options.contains(type) ? type : options.first,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.blue),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        items: options.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
