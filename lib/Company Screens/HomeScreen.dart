import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Job-Card.dart'; // Import the job card widget

class HomeScreen extends StatefulWidget {
  static const String routeName = "/HomeScreen";
  final String companyid;

  const HomeScreen({Key? key, required this.companyid}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: HomePageContent(companyId: widget.companyid),
      ),

    );
  }
}

class HomePageContent extends StatelessWidget {
  final String companyId;

  const HomePageContent({required this.companyId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Image.asset(
            'assets/images/logo1.jpeg',
            width: 150,
            height: 80,
          ),
          SizedBox(height: 20),
          Text(
            "Welcome Back!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF196AB3),
            ),
          ),
          SizedBox(height: 10),
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
          Expanded(child: JobsList(companyId: companyId)),
        ],
      ),
    );
  }
}

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
          'photoUrl': doc['CompanyPhoto'] ?? "",
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
                  companyPhotoUrl,
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

class JobsList extends StatelessWidget {
  final String companyId;

  const JobsList({required this.companyId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('interns')
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
