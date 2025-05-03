import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Features/Apply Process/CV_Options_Screen.dart';

class InternshipDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> internshipData;

  const InternshipDetailsScreen({Key? key, required this.internshipData}) : super(key: key);

  Future<void> _checkAndProceed(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showAnimatedSnackBar(
            context,
            "You must be logged in to apply",
            isError: true
        );
        return;
      }

      var existingApplication = await FirebaseFirestore.instance
          .collection('Student_Applicant')
          .where('userId', isEqualTo: user.uid)
          .where('internshipId', isEqualTo: internshipData["internshipId"])
          .get();

      if (existingApplication.docs.isNotEmpty) {
        _showAnimatedSnackBar(
            context,
            "You have already applied for this opportunity",
            isError: true
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CVOptionScreen(
            internshipId: internshipData["internshipId"],
            internshipTitle: internshipData["title"] ?? '',
          ),
        ),
      );
    } catch (e) {
      _showAnimatedSnackBar(
          context,
          "An error occurred during application. Please try again later",
          isError: true
      );
    }
  }

  void _showAnimatedSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<int> _getApplicantsCount() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('Student_Applicant')
          .where('internshipId', isEqualTo: internshipData["internshipId"])
          .get();

      return query.size;
    } catch (e) {
      print("Error getting applicants count: $e");
      return 0;
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Not specified";
    return DateFormat('MMM d, yyyy').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = Color(0xFF2563EB); // Modern blue
    final secondaryColor = Color(0xFFFF6B00); // Modern orange

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Internship Details",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_border_rounded),
            onPressed: () {
              _showAnimatedSnackBar(context, "Internship saved to bookmarks");
            },
          ),
          IconButton(
            icon: Icon(Icons.share_rounded),
            onPressed: () {
              _showAnimatedSnackBar(context, "Share link copied to clipboard");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Company header section
            _buildCompanyHeader(context, primaryColor, secondaryColor),

            // Main content
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview section
                    _buildOverviewSection(context, primaryColor),

                    Divider(height: 32, thickness: 1),

                    // Responsibilities section
                    _buildSection(
                      context,
                      title: "Responsibilities",
                      icon: Icons.assignment_rounded,
                      color: primaryColor,
                      items: internshipData["whatYouWillBeDoing"] is List
                          ? internshipData["whatYouWillBeDoing"]
                          : (internshipData["whatYouWillBeDoing"] as String?)?.split("-") ?? [],
                    ),

                    SizedBox(height: 24),

                    // Requirements section
                    _buildSection(
                      context,
                      title: "Requirements",
                      icon: Icons.check_circle_outline_rounded,
                      color: primaryColor,
                      items: internshipData["whatWeAreLookingFor"] is List
                          ? internshipData["whatWeAreLookingFor"]
                          : (internshipData["whatWeAreLookingFor"] as String?)?.split("-") ?? [],
                    ),

                    SizedBox(height: 24),

                    // Preferred qualifications section
                    _buildSection(
                      context,
                      title: "Preferred Qualifications",
                      icon: Icons.stars_rounded,
                      color: primaryColor,
                      items: internshipData["preferredQualifications"] is List
                          ? internshipData["preferredQualifications"]
                          : (internshipData["preferredQualifications"] as String?)?.split("-") ?? [],
                    ),

                    SizedBox(height: 24),

                    // Additional information section
                    _buildAdditionalInfo(context, primaryColor),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Apply button section
            _buildApplySection(context, primaryColor),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyHeader(BuildContext context, Color primaryColor, Color secondaryColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    internshipData["company"]?.substring(0, 1) ?? "C",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      internshipData["title"] ?? "Unknown Title",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      internshipData["company"] ?? "Unknown Company",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[600]),
              SizedBox(width: 6),
              Text(
                internshipData["location"] ?? "Location not specified",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 16),
              Icon(Icons.access_time_rounded, size: 18, color: Colors.grey[600]),
              SizedBox(width: 6),
              Text(
                internshipData["type"] ?? "Unknown type",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          FutureBuilder<int>(
            future: _getApplicantsCount(),
            builder: (context, snapshot) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_alt_outlined, size: 16, color: Colors.grey[700]),
                    SizedBox(width: 6),
                    Text(
                      "${snapshot.data ?? 0} Applicants",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline_rounded, color: primaryColor, size: 20),
            SizedBox(width: 8),
            Text(
              "Overview",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildOverviewItem(
          context,
          icon: Icons.calendar_today_rounded,
          title: "Duration",
          value: internshipData["duration"] ?? "Not specified",
        ),
        SizedBox(height: 12),
        _buildOverviewItem(
          context,
          icon: Icons.play_circle_outline_rounded,
          title: "Start Date",
          value: internshipData["startDate"] ?? "Not specified",
        ),
        SizedBox(height: 12),
        _buildOverviewItem(
          context,
          icon: Icons.category_outlined,
          title: "Field",
          value: internshipData["field"] ?? "Not specified",
        ),
      ],
    );
  }

  Widget _buildOverviewItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.blue[700]),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<dynamic> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ...items.map((item) {
          String text = item.toString().trim();
          if (text.isEmpty) return SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 5),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAdditionalInfo(BuildContext context, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.more_horiz_rounded, color: primaryColor, size: 20),
            SizedBox(width: 8),
            Text(
              "Additional Information",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Text(
                "This internship provides a unique opportunity to gain hands-on experience in ${internshipData["field"] ?? "the field"}. You'll work directly with experienced professionals on real-world projects while developing essential skills for your career.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Application deadline: 2 weeks from posting",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplySection(BuildContext context, Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ready to apply?",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Submit your application now",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _checkAndProceed(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Apply Now",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}