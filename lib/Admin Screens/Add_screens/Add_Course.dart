import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class AddCourse extends StatefulWidget {
  @override
  _AddCourseState createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  final _formKey = GlobalKey<FormState>();
  String fieldName = '', fieldDescription = '', placeName = '', courseType = '';
  File? _fieldImage, _roadmapImage, _coursePlaceImage, _courseVideo;
  VideoPlayerController? _videoController;

  Future<void> _pickImage(Function(File?) setImage) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        setImage(File(pickedFile.path));
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _courseVideo = File(pickedFile.path);
        _videoController = VideoPlayerController.file(_courseVideo!)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.play();
          });
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
          "Add New Course",
          style: TextStyle(color: Color(0xFF2252A1), fontSize: 21, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "This page allows admins to add new field & course opportunities to the application, enabling students to register for these courses.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                SizedBox(height: 10),

                buildImagePicker(title: "Upload Field Image", imageFile: _fieldImage, onPick: () => _pickImage((file) => _fieldImage = file)),
                buildTextField("Field Name", Icons.work, (value) => fieldName = value!),
                buildTextField("Field Description", Icons.description, (value) => fieldDescription = value!, maxLines: 3),

                buildVideoPicker(),
                buildImagePicker(title: "Upload Roadmap Image", imageFile: _roadmapImage, onPick: () => _pickImage((file) => _roadmapImage = file)),
                buildImagePicker(title: "Upload Course Place Image", imageFile: _coursePlaceImage, onPick: () => _pickImage((file) => _coursePlaceImage = file)),

                buildTextField("Place Name", Icons.location_on, (value) => placeName = value!),
                buildTextField("Course Type", Icons.business, (value) => courseType = value!),

                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2252A1),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Submit", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImagePicker({required String title, required File? imageFile, required Function() onPick}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
        SizedBox(height: 10),
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: imageFile != null
                ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(imageFile, fit: BoxFit.cover, width: double.infinity, height: 180))
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image, size: 40, color: Colors.blue), Text("Upload Image", style: TextStyle(color: Colors.blue))]),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildVideoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Upload Course Video", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
        SizedBox(height: 10),
        GestureDetector(
          onTap: _pickVideo,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: _courseVideo != null
                ? _videoController != null && _videoController!.value.isInitialized
                ? AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!))
                : Center(child: CircularProgressIndicator())
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.video_library, size: 40, color: Colors.blue), Text("Upload Video", style: TextStyle(color: Colors.blue))]),
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
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.blue, width: 2)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue, width: 2)),
          filled: true,
          fillColor: Colors.transparent,
        ),
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? "Enter $label" : null,
        onSaved: onSaved,
      ),
    );
  }
}
