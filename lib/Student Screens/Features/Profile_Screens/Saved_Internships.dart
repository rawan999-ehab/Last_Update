import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../details/internship_details_screen.dart';

class SavedInternshipScreen extends StatefulWidget {
  @override
  State<SavedInternshipScreen> createState() => _SavedInternshipScreenState();
}

class _SavedInternshipScreenState extends State<SavedInternshipScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;
  List<Map<String, dynamic>> savedInternships = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      _fetchSavedInternships();
    } else {
      print("User not logged in");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchSavedInternships() async {
    if (userId == null) return;

    try {
      final snapshot = await _firestore
          .collection('Saved_Internships')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> tempList = [];

      for (var doc in snapshot.docs) {
        String internshipId = doc['internshipId'];
        var internshipDoc =
        await _firestore.collection('interns').doc(internshipId).get();
        if (internshipDoc.exists) {
          var data = internshipDoc.data()!;
          data['id'] = internshipId;
          data['savedDocId'] = doc.id;
          tempList.add(data);
        }
      }

      setState(() {
        savedInternships = tempList;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching saved internships: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteSavedInternship(String savedDocId) async {
    await _firestore.collection('Saved_Internships').doc(savedDocId).delete();
    _fetchSavedInternships();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2252A1)),
          onPressed: () {},
        ),
        title: Text(
          "Saved Internships",
          style: TextStyle(
              color: Color(0xFF2252A1),
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedInternships.isEmpty
          ? const Center(child: Text("No saved internships yet."))
          : Padding(
        padding:
        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: ListView.builder(
          itemCount: savedInternships.length,
          itemBuilder: (context, index) {
            var job = savedInternships[index];
            return Padding(
              padding: EdgeInsets.only(
                top: index == 0 ? screenHeight * 0.02 : 0,
                bottom: screenHeight * 0.02,
              ),
              child: Container(
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
                          padding:
                          EdgeInsets.all(screenWidth * 0.045),
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
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.033,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      children: [
                        // زر See More
                        Expanded(
                          child: SizedBox(
                            height: screenHeight * 0.04,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        InternshipDetailsScreen(
                                          internshipData: job,
                                        ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF196AB3),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(25),
                                ),
                              ),
                              icon: Icon(Icons.trending_up,
                                  color: Colors.white,
                                  size: screenWidth * 0.05),
                              label: Text(
                                "See More",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        // زر Delete
                        Expanded(
                          child: SizedBox(
                            height: screenHeight * 0.04,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _deleteSavedInternship(
                                    job['savedDocId']);
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Colors.red, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(25),
                                ),
                              ),
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: screenWidth * 0.05,
                              ),
                              label: Text(
                                "Delete Saved",
                                style: TextStyle(
                                  color: Colors.red,
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
              ),
            );
          },
        ),
      ),
    );
  }
}