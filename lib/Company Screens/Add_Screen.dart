import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:onesignal_flutter/onesignal_flutter.dart'; // تأكد من إضافة الحزمة
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddScreen extends StatefulWidget {
  final String Id; // Add companyId as a parameter

  AddScreen({required this.Id}); // Constructor to receive companyId

  @override
  _AddInternshipScreenState createState() => _AddInternshipScreenState();
}

class _AddInternshipScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String location = '';
  String internship = 'Internship';
  String type = 'On-site';
  String duration = '';
  String whatYouWillBeDoing = '';
  String whatWeAreLookingFor = '';
  String preferredQualifications = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    initOneSignal(); // Initialize OneSignal
  }

  void initOneSignal() {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize("a7907370-789c-4b08-b75d-88a68dd2490a"); // Replace with your actual app ID

    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      if (data != null && data['internshipId'] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddScreen(Id: data['internshipId']),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // تم نقل backgroundColor هنا
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  "This page allows companies to add new internship opportunities to the application, "
                      "enabling students to register for these internships.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                buildTextField(
                    "Internship Title", Icons.work, (value) => title = value!),
                buildTextField("Location", Icons.location_on, (value) =>
                location = value!),
                buildDropdownField(
                    "Internship", Icons.style_rounded, ["Internship"], (
                    value) => internship = value!),
                buildDropdownField("Internship Type", Icons.business,
                    ["On-site", "Remote", "Hybrid"], (value) => type = value!),
                buildTextField(
                    "Duration (e.g., 3 months)", Icons.access_time, (value) =>
                duration = value!),
                buildTextField(
                    "What You Will Be Doing", Icons.description, (value) =>
                whatYouWillBeDoing = value!, maxLines: 3),
                buildTextField(
                    "What We Are Looking For", Icons.description_outlined, (
                    value) => whatWeAreLookingFor = value!, maxLines: 3),
                buildTextField(
                    "Preferred Qualifications", Icons.description, (value) =>
                preferredQualifications = value!, maxLines: 3),
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
                    child: Text(
                      "Submit",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, IconData icon, Function(String?) onSaved,
      {int maxLines = 1}) {
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

  Widget buildDropdownField(String label, IconData icon, List<String> options,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<String>(
        value: options.first,
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
        items: options.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        DocumentReference docRef = _firestore.collection('interns').doc(); // Create a new document

        await docRef.set({
          "internshipId": docRef.id, // Store the document ID
          'title': title,
          'location': location,
          'internship': internship,
          'type': type,
          'duration': duration,
          'whatYouWillBeDoing': whatYouWillBeDoing,
          'whatWeAreLookingFor': whatWeAreLookingFor,
          'preferredQualifications': preferredQualifications,
          'timestamp': FieldValue.serverTimestamp(),
          'companyId': widget.Id, // Add the company ID
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Internship Added Successfully!")),
        );

        // Send a notification to all users
        await sendOneSignalNotification(
          title: "New Internship Opportunity!",
          message: "$title - $location",
          data: {
            "internshipId": docRef.id,
            "title": title,
            "location": location,
          },
        );

        // Clear the form after submission
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add internship: $e")),
        );
      }
    }
  }

  Future<void> sendOneSignalNotification({
    required String title,
    required String message,
    required Map<String, dynamic> data,
  }) async {
    final String oneSignalAppId = dotenv.get('ONESIGNAL_APP_ID', fallback: '');
    final String oneSignalApiKey = dotenv.get('ONESIGNAL_API_KEY', fallback: '');

    // ✅ تأكد أن القيم لا تزال موجودة
    print('ONESIGNAL_APP_ID: $oneSignalAppId');
    print('ONESIGNAL_API_KEY: $oneSignalApiKey');

    if (oneSignalAppId.isEmpty || oneSignalApiKey.isEmpty) {
      print('❌ OneSignal API credentials are missing!');
      return;
    }

    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      List<String> playerIds = [];

      for (var doc in usersSnapshot.docs) {
        var playerId = doc['playerId']; // ✅ تأكد أن الحقل موجود واسمه صحيح
        if (playerId != null && playerId.isNotEmpty) {
          playerIds.add(playerId);
        }
      }

      if (playerIds.isEmpty) {
        print('❌ No users with Player IDs found in Firestore!');
        return;
      }

      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Basic $oneSignalApiKey',
        },
        body: jsonEncode({
          'app_id': oneSignalAppId, // ✅ تأكد أن الـ app_id هنا موجود
          'include_player_ids': playerIds,
          'contents': {'en': message},
          'headings': {'en': title},
          'data': data,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully to ${playerIds.length} users');
      } else {
        print('❌ Failed to send notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }
}
