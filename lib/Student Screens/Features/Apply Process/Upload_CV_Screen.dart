import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadCVScreen extends StatefulWidget {
  @override
  _UploadCVScreenState createState() => _UploadCVScreenState();
}

class _UploadCVScreenState extends State<UploadCVScreen> {
  String? fileName;

  Future<void> _pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
      });

      // 👉 هنا ممكن ترفعي الملف إلى Firebase Storage
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("CV Selected: $fileName")));
    } else {
      // المستخدم لغى العملية
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Your CV"),
        backgroundColor: Color(0xFF196AB3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickCV,
              icon: Icon(Icons.upload_file),
              label: Text("Choose CV File"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF196AB3),
                minimumSize: Size(double.infinity, 45),
              ),
            ),
            SizedBox(height: 20),
            if (fileName != null)
              Text("Selected File: $fileName", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
