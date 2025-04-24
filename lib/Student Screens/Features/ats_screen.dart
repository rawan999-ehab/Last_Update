import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'main_student.dart'; // Import your main screen file
import 'info/ATSMoreInfoScreen.dart';

class AtsScreen extends StatefulWidget {
  static const String routeName = '/AtsScreen';


  @override
  _AtsScreenState createState() => _AtsScreenState();
}

class _AtsScreenState extends State<AtsScreen> {
  TextEditingController jobController = TextEditingController();
  File? selectedFile; // Store the selected PDF file
  bool isUploading = false;
  String aiResponse = ''; // Store the AI response

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> processCV() async {
    if (selectedFile != null && jobController.text.isNotEmpty) {
      setState(() {
        isUploading = true;
        aiResponse = ''; // Clear previous response
      });

      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        setState(() => isUploading = false);
        return;
      }

      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.7:5000/submit'), // Replace with your server IP
      );

      // Add the job description and user ID
      request.fields['job_description'] = jobController.text;
      request.fields['user_id'] = user.uid; // Add user ID to the request

      // Add the PDF file
      var fileStream = http.ByteStream(selectedFile!.openRead());
      var length = await selectedFile!.length();
      var multipartFile = http.MultipartFile(
        'cv_file',
        fileStream,
        length,
        filename: selectedFile!.path.split('/').last,
        contentType: MediaType('application', 'pdf'),
      );
      request.files.add(multipartFile);

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        setState(() {
          aiResponse = jsonResponse['ai_response'].toString();
          isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CV Processing Completed!')),
        );
      } else {
        setState(() {
          isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process CV. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload a PDF and enter a job description first!')),
      );
    }
    String extractedPercentage = RegExp(r'\d+%').stringMatch(aiResponse) ?? '0%';
    await uploadToSupabase(selectedFile!, extractedPercentage);

  }

  Future<void> uploadToSupabase(File file, String percentage) async {
    final supabase = Supabase.instance.client;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in')));
      return;
    }

    final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final fileBytes = await file.readAsBytes();

    // Upload to Supabase Storage
    final storageResponse = await supabase.storage
        .from('cv-pdf')
        .uploadBinary(fileName, fileBytes, fileOptions: FileOptions(contentType: 'application/pdf'));

    if (storageResponse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload PDF to Supabase')));
      return;
    }

    // Get the public URL
    final publicUrl = supabase.storage.from('cv-pdf').getPublicUrl(fileName);

    // Save record in Supabase table
    final insertResponse = await supabase.from('cv_pdf').insert({
      'user_id': user.uid,
      'pdf_url': publicUrl,
      'percentage': percentage,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (insertResponse.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to insert record into Supabase')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CV uploaded to Supabase!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('ATS Tracking System'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()), // Navigate to MainScreen
            );
          },
        ),

        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.black), // Info icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ATSMoreInfoScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              'Job description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            TextField(
              controller: jobController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Enter job description...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Upload Resume (PDF)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),

            // Show upload container only when no file is selected
            if (selectedFile == null)
              GestureDetector(
                onTap: pickFile,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, size: 50, color: Colors.blueAccent),
                        SizedBox(height: 6),
                        Text(
                          'Click to upload or drag & drop',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        Text(
                          'PDF only | Max size: 5MB',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (selectedFile != null) ...[
              SizedBox(height: 12),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  leading: Icon(Icons.insert_drive_file, color: Colors.blueAccent),
                  title: Text(
                    selectedFile!.path.split('/').last,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        selectedFile = null;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'File uploaded successfully!',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
            SizedBox(height: 30),
            if (isUploading) ...[
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Under Processing by AI...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: processCV,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Center(child: Text('Check the CV', style: TextStyle(fontSize: 16))),
              ),
            ],
            if (aiResponse.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                'AI Response:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  children: _parseBoldText(aiResponse),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Function to parse `__bold__` text and return formatted spans
  List<TextSpan> _parseBoldText(String text) {
    final regex = RegExp(r'__(.*?)__'); // Detects __bold__ text
    final spans = <TextSpan>[];

    text.splitMapJoin(
      regex,
      onMatch: (match) {
        spans.add(TextSpan(
          text: match.group(1),
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
        return '';
      },
      onNonMatch: (nonBoldText) {
        spans.add(TextSpan(text: nonBoldText));
        return '';
      },
    );

    return spans;
  }
}
