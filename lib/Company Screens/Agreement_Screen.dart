import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'View_Students_Info.dart';
import 'CompanyService.dart';
import 'package:project/screens/Auth/auth_service.dart';
class AgreementScreen extends StatefulWidget {
  @override
  _AgreementScreenState createState() => _AgreementScreenState();}
class _AgreementScreenState extends State<AgreementScreen> {
  String? companyId;
  @override
  void initState() {
    super.initState();
    _loadCompanyId();
  }
  Future<void> _loadCompanyId() async {
    String? id = await AuthService().getStoredCompanyId();
    setState(() {
      companyId = id;});
    if (id != null) {
      Map<String, dynamic>? companyData = await AuthService().getCompanyById(id);
      if (companyData != null) {
        print("Company Name: ${companyData['name']}");
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    if (companyId == null) {
      print("⏳ Waiting for companyId...");
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2252A1)),
          onPressed: () {
            print("🔙 رجوع للخلف");
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Internship Agreements",
          style: TextStyle(
            color: Color(0xFF2252A1),
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: CompanyService.getInternships(companyId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("⏳ Fetching internships...");
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print("❌ No internships found!");
            return Center(child: Text("No internships available"));
          }
          final interns = snapshot.data!.docs;
          print("✅ Internships Found: ${interns.length}");
          return ListView.builder(
            itemCount: interns.length,
            itemBuilder: (context, index) {
              final data = interns[index].data() as Map<String, dynamic>;
              print("🎓 Internship Loaded: ${data['title']}");
              return buildInternshipCard(context, data);},);
        },
      ),
    );
  }
  Card buildInternshipCard(BuildContext context, Map<String, dynamic> internship) {
    print("🎭 Building Internship Card for: ${internship['title'] ?? 'Unknown'}");
    return Card(
      margin: EdgeInsets.all(8.0),
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              internship['title'] ?? "Unknown Title",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              internship['duration'] ?? "Unknown Duration",
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print("📜 Navigating to ViewStudentsInfo for Internship ID: ${internship['companyId'] ?? 'Unknown'}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewStudentsInfo(internshipId: internship['companyId'] ?? ''),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text("View Students Info"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}