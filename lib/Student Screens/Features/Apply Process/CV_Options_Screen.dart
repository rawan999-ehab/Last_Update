import 'package:flutter/material.dart';
import 'Build_CV_Screen.dart';
import 'Upload_CV_Screen.dart';

class CVOptionScreen extends StatefulWidget {
  final String internshipId;
  final String internshipTitle;
  const CVOptionScreen({
    Key? key,
    required this.internshipId,
    required this.internshipTitle,
  }) : super(key: key);

  @override
  _CVOptionScreenState createState() => _CVOptionScreenState();
}

class _CVOptionScreenState extends State<CVOptionScreen> {
  String selectedOption = '';

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2252A1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Application Method",
          style: TextStyle(
            color: Color(0xFF2252A1),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),
            const Text(
              'Choose your application method:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: screenHeight * 0.04),

            // Application options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Build CV option
                _buildOptionCard(
                  icon: Icons.edit_document,
                  title: 'Create Resume',
                  description: 'Build your resume using our tool',
                  isSelected: selectedOption == 'build',
                  onTap: () => setState(() => selectedOption = 'build'),
                  width: screenWidth * 0.45,
                ),

                // Upload CV option
                _buildOptionCard(
                  icon: Icons.upload_file_rounded,
                  title: 'Upload Resume',
                  description: 'Use your existing resume',
                  isSelected: selectedOption == 'upload',
                  onTap: () => setState(() => selectedOption = 'upload'),
                  width: screenWidth * 0.45,
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.04),

            // Display selected screen
            if (selectedOption.isNotEmpty)
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: selectedOption == 'build'
                      ? BuildCVScreen(
                    internshipId: widget.internshipId,
                    internshipTitle: widget.internshipTitle,
                  )
                      : UploadCVScreen(
                    internshipId: widget.internshipId,
                    internshipTitle: widget.internshipTitle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Option card widget
  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
    required double width,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F3FF) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF2252A1) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF2252A1).withOpacity(0.15)
                  : Colors.grey.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: isSelected ? const Color(0xFF2252A1) : Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2252A1) : const Color(0xFF333333),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}