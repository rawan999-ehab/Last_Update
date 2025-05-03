import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  final String companyId;

  const ProfileScreen({Key? key, required this.companyId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? supabaseImageUrl;
  bool isLoadingImage = true;
  String? errorMessage;
  int internshipsCount = 0;
  int applicantsCount = 0;
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    debugPrint('Fetching profile for company ID: ${widget.companyId}');
    fetchSupabaseImage();
    fetchStatistics();
  }

  Future<void> fetchSupabaseImage() async {
    try {
      final response = await Supabase.instance.client
          .from('companies_profile')
          .select('img_url')
          .eq('company_id', widget.companyId)
          .maybeSingle();

      if (response != null && response['img_url'] != null) {
        debugPrint('Found image URL: ${response['img_url']}');
        setState(() {
          supabaseImageUrl = response['img_url'];
          isLoadingImage = false;
        });
      } else {
        debugPrint('No image found for company ID: ${widget.companyId}');
        setState(() {
          isLoadingImage = false;
          errorMessage = 'No company image found';
        });
      }
    } catch (e) {
      debugPrint('Error fetching image from Supabase: $e');
      setState(() {
        isLoadingImage = false;
        errorMessage = 'Failed to load company image';
      });
    }
  }

  Future<void> fetchStatistics() async {
    try {
      final internshipsQuery = await FirebaseFirestore.instance
          .collection('interns')
          .where('companyId', isEqualTo: widget.companyId)
          .get();

      int totalApplicants = 0;

      for (var internship in internshipsQuery.docs) {
        final internshipId = internship['internshipId'];

        final applicantsQuery = await FirebaseFirestore.instance
            .collection('Student_Applicant')
            .where('internshipId', isEqualTo: internshipId)
            .get();

        totalApplicants += applicantsQuery.size;
      }

      setState(() {
        internshipsCount = internshipsQuery.size;
        applicantsCount = totalApplicants;
        isLoadingStats = false;
      });
    } catch (e) {
      debugPrint('Error fetching statistics: $e');
      setState(() {
        isLoadingStats = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load statistics")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Company Profile"),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('company')
            .doc(widget.companyId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Company not found",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCompanyImageSection(),

                const SizedBox(height: 24),

                Text(
                  data['CompanyName']?.toUpperCase() ?? 'NO NAME',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                _buildStatisticsSection(),

                const SizedBox(height: 24),

                _buildSectionTitle("About Company"),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    data['Description'] ?? 'No Description Provided',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),

                const SizedBox(height: 24),

                _buildSectionTitle("Contact Information"),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildContactItem(
                        Icons.email,
                        "Email",
                        data['Email'] ?? 'No Email Provided',
                        onTap: null,
                      ),

                      const Divider(height: 24),

                      _buildContactItem(
                        Icons.language,
                        "Website",
                        data['Website']?.toString().isNotEmpty ?? false
                            ? "Click to visit website"
                            : 'No Website Provided',
                        isLink: data['Website']?.toString().isNotEmpty ?? false,
                        onTap: () async {
                          final url = data['Website']?.toString();
                          if (url != null && url.isNotEmpty) {
                            await _launchURL(url);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatisticItem(
            "Internships",
            internshipsCount,
            Icons.work_outline,
            Colors.blue,
          ),
          _buildStatisticItem(
            "Applicants",
            applicantsCount,
            Icons.people_outline,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticItem(String title, int count, IconData icon, Color color) {
    return Column(
      children: [
        isLoadingStats
            ? const CircularProgressIndicator()
            : Text(
          count.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompanyImageSection() {
    if (isLoadingImage) {
      return const SizedBox(
        height: 150,
        width: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (supabaseImageUrl != null) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue[100]!, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            supabaseImageUrl!,
            height: 150,
            width: 150,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                height: 150,
                width: 150,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          ),
        ),
      );
    }

    return _buildImagePlaceholder(errorMessage: errorMessage);
  }

  Widget _buildImagePlaceholder({String? errorMessage}) {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
        border: Border.all(color: Colors.blue[100]!, width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.business, size: 60, color: Colors.grey),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(
      IconData icon,
      String title,
      String value, {
        bool isLink = false,
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: Colors.blue[800]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: isLink ? Colors.blue : Colors.black,
                      decoration: isLink ? TextDecoration.underline : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final uri = Uri.parse(url);
      debugPrint('Attempting to launch URL: $uri');

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not launch $url")),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error launching URL: ${e.toString()}")),
        );
      }
    }
  }
}