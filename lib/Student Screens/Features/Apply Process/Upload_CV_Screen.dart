import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class UploadCVScreen extends StatefulWidget {
  final String internshipId;
  final String internshipTitle;

  const UploadCVScreen({
    Key? key,
    required this.internshipId,
    required this.internshipTitle,
  }) : super(key: key);

  @override
  _UploadCVScreenState createState() => _UploadCVScreenState();
}

class _UploadCVScreenState extends State<UploadCVScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController externalLinkController = TextEditingController();
  final TextEditingController GPAController = TextEditingController();

  String? cvFileName;
  PlatformFile? cvFile;
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final double maxFileSizeMB = 5.0;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  Future<void> _prefillUserData() async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      emailController.text = user.email!;
    }
  }

  Future<void> uploadCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Important: ensure data is loaded in memory
      );

      if (result != null) {
        final file = result.files.single;
        final fileSizeMB = file.size / (1024 * 1024);

        if (fileSizeMB > maxFileSizeMB) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File size exceeds ${maxFileSizeMB}MB limit')),
          );
          return;
        }

        setState(() {
          cvFileName = file.name;
          cvFile = file;
        });
      }
    } catch (e) {
      print('File picking error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: ${e.toString()}')),
      );
    }
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (cvFile == null) {
      showSnackBar('Please upload your CV (PDF only)');
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // 1. Upload to Supabase Storage
      final supabase = Supabase.instance.client;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'cv/${user.uid}/${timestamp}_${cvFile!.name}';

      // Make sure we have the file bytes for upload
      final fileBytes = cvFile!.bytes;
      if (fileBytes == null) {
        throw Exception('File data is null');
      }

      // Upload the file
      await supabase.storage
          .from('upload-cv')
          .uploadBinary(
        filePath,
        fileBytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
          contentType: 'application/pdf',
        ),
      );

      // 2. Get Public URL
      final publicUrl = supabase.storage
          .from('upload-cv')
          .getPublicUrl(filePath);

      // 3. Save to Supabase table
      final supabaseResponse = await supabase
          .from('Uplod-CV')  // Note: There's a typo here in table name
          .insert({
        'Cv-url': publicUrl,
        'userid': user.uid,
        'National-ID': nationalIdController.text.trim(),
        'Email': emailController.text.trim(),
        'ExternaLink': externalLinkController.text.trim(),  // Note: There's a typo here
        'Gpa': double.tryParse(GPAController.text.trim()) ?? 0.0,
        'internship_id': widget.internshipId,
      }).select().single();

      final supabaseCvId = supabaseResponse['id'] as int;

      // 4. Save to Firestore
      await FirebaseFirestore.instance.collection('Student_Applicant').add({
        'appliedAt': FieldValue.serverTimestamp(),
        'internshipId': widget.internshipId,
        'internshipTitle': widget.internshipTitle,
        'cvId': publicUrl,
        'email': emailController.text.trim(),
        'status': 'pending',
        'userId': user.uid,
        'uploadMethod': 'upload',
        'supabaseCvId': supabaseCvId,
        'nationalId': nationalIdController.text.trim(),
        'gpa': GPAController.text.trim(),
      });

      showSnackBar('Application submitted successfully!');
      _resetForm();

      // Navigate back after successful submission
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Submission error: $e');
      showSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      cvFileName = null;
      cvFile = null;
    });
  }

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for ${widget.internshipTitle}'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 20),
              _buildFormFields(),
              const SizedBox(height: 20),
              _buildUploadSection(),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ensure all information is accurate. Your profile data will be used for this application.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: emailController,
          decoration: _inputDecoration('Email*', suffixIcon: const Icon(Icons.email)),
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: nationalIdController,
          decoration: _inputDecoration('National ID*'),
          keyboardType: TextInputType.number,
          validator: _validateRequiredField,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: GPAController,
          decoration: _inputDecoration('GPA*'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: _validateGPA,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: externalLinkController,
          decoration: _inputDecoration('Portfolio/LinkedIn (Optional)'),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upload Your CV*', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: uploadCV,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.cloud_upload, size: 40, color: Colors.blue),
                const SizedBox(height: 10),
                Text(
                  cvFileName ?? 'Select PDF File',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cvFileName != null ? Colors.green : Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Max ${maxFileSizeMB}MB • PDF only',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading ? null : submitForm,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('SUBMIT APPLICATION', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validateRequiredField(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }

  String? _validateGPA(String? value) {
    if (value == null || value.isEmpty) return 'GPA is required';
    final gpa = double.tryParse(value);
    if (gpa == null) return 'Enter a valid number';
    if (gpa < 0 || gpa > 4) return 'GPA must be between 0 and 4';
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    nationalIdController.dispose();
    externalLinkController.dispose();
    GPAController.dispose();
    super.dispose();
  }
}