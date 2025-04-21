import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../details/internship_details_screen.dart';
import 'chatbot/chat_bot_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/HomeScreen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> jobList = [];

  @override
  void initState() {
    super.initState();
    _fetchInternships();
  }

  Future<void> _fetchInternships() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('interns').get();
      setState(() {
        jobList = querySnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data["id"] = doc.id; // إضافة id لتحديد كل internship
          return data;
        }).toList();
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<bool> _checkIfSaved(String internshipId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var snapshot = await _firestore
        .collection('Saved_Internships')
        .where('internshipId', isEqualTo: internshipId)
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.06),
            Text(
              "Welcome To Your Future!",
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Color(0xFF196AB3),
                height: 2,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            SizedBox(
              height: screenHeight * 0.06,
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                  prefixIcon: Icon(Icons.search, color: Colors.white, size: screenWidth * 0.06),
                  filled: true,
                  fillColor: Color(0xFF2252A1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Expanded(
              child: ListView.builder(
                itemCount: jobList.length,
                itemBuilder: (context, index) {
                  var job = jobList[index];
                  return FutureBuilder<bool>(
                    future: _checkIfSaved(job["id"]),
                    builder: (context, snapshot) {
                      bool isSaved = snapshot.data ?? false;
                      return Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                        child: _buildJobCard(job, screenWidth, screenHeight, isSaved),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatBotScreen()),
          );
        },
        backgroundColor: Colors.blue,
        shape: CircleBorder(),
        child: Icon(Icons.smart_toy, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, double screenWidth, double screenHeight, bool isSaved) {
    String internshipId = job["id"];
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue, width: 1.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.045),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job["company"] ?? "Unknown Company",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  job["title"] ?? "Unknown Title",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            job["location"] ?? "Unknown Location",
            style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.033),
          ),
          SizedBox(height: screenHeight * 0.015),
          Row(
            children: [
              _buildTag(job["type"] ?? "Unknown Type", Icons.check),
              SizedBox(width: screenWidth * 0.02),
              _buildTag(job["internship"] ?? "Unknown Type", Icons.check),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: screenHeight * 0.04,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InternshipDetailsScreen(internshipData: job),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF196AB3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    label: Text("See More", style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04)),
                    icon: Icon(Icons.trending_up, color: Colors.white, size: screenWidth * 0.05),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: SizedBox(
                  height: screenHeight * 0.04,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (!isSaved) {
                        await _firestore.collection('Saved_Internships').add({
                          "internshipId": internshipId,
                          "userId": userId,
                        });
                      } else {
                        var snapshot = await _firestore
                            .collection('Saved_Internships')
                            .where('internshipId', isEqualTo: internshipId)
                            .where('userId', isEqualTo: userId)
                            .get();
                        for (var doc in snapshot.docs) {
                          await doc.reference.delete();
                        }
                      }
                      setState(() {});
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSaved ? Colors.blue : Colors.white,
                      side: BorderSide(color: Colors.blue, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? Colors.white : Colors.blue,
                      size: screenWidth * 0.05,
                    ),
                    label: Text(
                      isSaved ? "Saved" : "Save",
                      style: TextStyle(
                        color: isSaved ? Colors.white : Colors.blue,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blue, size: 16),
          SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
