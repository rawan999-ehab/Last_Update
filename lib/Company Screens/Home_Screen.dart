
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Nav_Bar.dart'; // Import the navigation bar
import 'add_screen.dart'; // Import the add screen
import 'Agreement_Screen.dart'; // Import the agreements screen
import 'Profile.dart'; // Import the profile screen
import 'Job-Card.dart'; // Import the job card widget

class Home_Screen extends StatefulWidget {
  static const String routeName = "/Home_Screen"; // Define route name

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Home_Screen> {
  int _selectedIndex = 0;
  late String companyid; // Store the companyId

  // List of pages for the bottom navigation bar
  late final List<Widget> _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! String) {
      throw ArgumentError("companyId must be passed as a String argument");
    }
    companyid = args; // Initialize companyId
    _pages = [
      HomePageContent(companyId: companyid),
      AgreementScreen(),
      Placeholder(), // Replace with actual screen if needed
      Profile(),
    ];
  }

  // Function to handle bottom navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(

        ),
        child: SafeArea(
          child: _pages[_selectedIndex], // Display the selected page
        ),
      ),
      bottomNavigationBar: Nav_Bar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF196AB3), // Same color as LoginScreen buttons
        child: Icon(Icons.add, size: 30, color: Colors.white), // Add icon
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddScreen(Id: companyid),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

/// Widget يعرض المحتوى الرئيسي للصفحة مع بيانات الشركة وقائمة الوظائف
class HomePageContent extends StatelessWidget {
  final String companyId; // Receive companyId as a parameter

  const HomePageContent({required this.companyId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          // Logo ثابت
          Image.asset(
            'assets/images/logo1.jpeg', // Same logo as LoginScreen
            width: 150,
            height: 80,
          ),
          SizedBox(height: 20),
          Text(
            "Welcome Back!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF196AB3), // Same color as LoginScreen
            ),
          ),
          SizedBox(height: 10),
          // عرض بيانات الشركة في Widget منفصل
          CompanyHeader(companyId: companyId),
          SizedBox(height: 20),
          Text(
            "Recent Jobs",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          // قائمة الوظائف في Widget منفصل
          Expanded(child: JobsList(companyId: companyId)),
        ],
      ),
    );
  }
}

/// Widget لتحميل وعرض بيانات الشركة (الاسم والصورة) من Firestore
class CompanyHeader extends StatelessWidget {
  final String companyId;

  const CompanyHeader({required this.companyId});

  Future<Map<String, String>> _fetchCompanyData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('company')
          .doc(companyId)
          .get();
      if (doc.exists) {
        return {
          'name': doc['CompanyName'] ?? "Company Interface",
          'photoUrl': doc['CompanyPhoto'] ?? "", // Fetch the CompanyPhoto URL
        };
      } else {
        return {
          'name': "Company Interface",
          'photoUrl': "",
        };
      }
    } catch (e) {
      print("Error fetching company data: $e");
      return {
        'name': "Company Interface",
        'photoUrl': "",
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _fetchCompanyData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text(
            "Error loading company data",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          );
        }
        final companyName = snapshot.data?['name'] ?? "Company Interface";
        final companyPhotoUrl = snapshot.data?['photoUrl'] ?? "";

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (companyPhotoUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  companyPhotoUrl, // Load image directly from the URL
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error, size: 100, color: Colors.grey);
                  },
                ),
              )
            else
              Icon(Icons.business, size: 100, color: Colors.grey),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                "$companyName Interface",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget لتحميل وعرض قائمة الوظائف من Firestore
class JobsList extends StatelessWidget {
  final String companyId;

  const JobsList({required this.companyId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('interns') // Correct collection name
          .where('companyId', isEqualTo: companyId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No jobs found'));
        }
        final jobData = snapshot.data!.docs;
        return ListView.builder(
          itemCount: jobData.length,
          itemBuilder: (context, index) {
            final job = jobData[index].data() as Map<String, dynamic>;
            return JobCard(
              title: job['title'] ?? "No Title",
              location: job['location'] ?? "No Location",
              time: job['duration'] ?? "No Time",
              applicants: job['applicants'] ?? "No Applicants",
              type1: job['type'] ?? "No Type",
              type2: job['duration'] ?? "No Type",
            );
          },
        );
      },
    );
  }
}
