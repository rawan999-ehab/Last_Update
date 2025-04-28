import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'info/ATSMoreInfoScreen.dart';

class AtsScreen extends StatefulWidget {
  static const String routeName = '/AtsScreen';

  const AtsScreen({Key? key}) : super(key: key);

  @override
  _AtsScreenState createState() => _AtsScreenState();
}

class _AtsScreenState extends State<AtsScreen> {
  TextEditingController jobController = TextEditingController();
  File? selectedFile;
  bool isUploading = false;
  String aiResponse = '';

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
        aiResponse = '';
      });

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.5:5000/submit'),
      );

      request.fields['job_description'] = jobController.text;
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
          "ATS Tracking System",
          style: TextStyle(color: Color(0xFF2252A1), fontSize: 21, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Color(0xFF2252A1)), // Info icon
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
              'Career Field',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2252A1)),
            ),
            SizedBox(height: 5),
            Text(
              'Enter the industry you are applying for, such as Marketing, Engineering, or IT.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),

            SizedBox(height: 9),
            TextField(
              controller: jobController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                hintText: 'Enter your career field...',
                hintStyle: TextStyle(color: Colors.grey[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 2.5),
                ),
              ),
            ),

            SizedBox(height: 20),

            Text(
              'Upload CV',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2252A1)),
            ),
            SizedBox(height: 5),
            Text(
              'Note that only PDF files are allowed.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),

            SizedBox(height: 9),
            if (selectedFile == null)
              GestureDetector(
                onTap: pickFile,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, size: 50, color: Colors.blue),
                      SizedBox(height: 6),
                      Text('Click to upload or drag & drop', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      Text('PDF only | Max size: 5MB', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    ],
                  ),
                ),
              ),
            if (selectedFile != null) ...[
              SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.insert_drive_file, color: Colors.blueAccent),
                title: Text(selectedFile!.path.split('/').last),
                trailing: IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      selectedFile = null;
                    });
                  },
                ),
              ),
            ],

            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: processCV,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2252A1),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Analyze CV", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),

            if (aiResponse.isNotEmpty) ...[
              SizedBox(height: 20),
              Text('AI Response:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(aiResponse),
            ],
          ],
        ),
      ),
    );
  }
}
