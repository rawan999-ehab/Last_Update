import 'package:flutter/material.dart';
import '../Add_screens/Add_Internship.dart';
import 'jobcard.dart'; // استيراد JobCard

class HomeScreen extends StatefulWidget {
  static const String routeName = '/HomeScreen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> jobList = [
    {
      "company": "JUMIA",
      "title": "Java Developer (Full Time)",
      "location": "Cairo, Egypt - 1 month ago • Over 100 people clicked apply",
      "type1": "On-site",
      "type2": "Internship",
    },
    {
      "company": "Google",
      "title": "Software Engineer Intern (Remote)",
      "location": "San Francisco, USA - 2 weeks ago • 200+ applicants",
      "type1": "Remote",
      "type2": "Internship",
    },
    // إضافة المزيد من البيانات هنا
  ];

  void _deleteJob(int index) {
    setState(() {
      jobList.removeAt(index);
    });
    _showMessage();
  }

  void _showMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Internship deleted successfully"),
        backgroundColor: Color(0xFF196AB3),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.06),
            Text(
              "Welcome Admins!",
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Color(0xFF196AB3),
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
            Expanded(
              child: ListView.builder(
                itemCount: jobList.length,
                itemBuilder: (context, index) {
                  var job = jobList[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                    child: JobCard(
                      job: job,
                      index: index,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      onDelete: _deleteJob,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddInternship()));
        },
        backgroundColor: Color(0xFF196AB3),
        child: Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}