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
          icon: Icon(Icons.arrow_back, color: Color(0xFF2252A1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "طريقة التقديم",
          style: TextStyle(
            color: Color(0xFF2252A1),
            fontSize: 22,
            fontWeight: FontWeight.bold,
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
            Text(
              'اختر طريقة التقديم:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: screenHeight * 0.04),

            // خيارات التقديم
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // خيار بناء السيرة الذاتية
                _buildOptionCard(
                  icon: Icons.edit_document,
                  title: 'إنشاء سيرة ذاتية',
                  isSelected: selectedOption == 'build',
                  onTap: () => setState(() => selectedOption = 'build'),
                  width: screenWidth * 0.42,
                ),

                // خيار رفع السيرة الذاتية
                _buildOptionCard(
                  icon: Icons.upload_file,
                  title: 'رفع سيرة ذاتية',
                  isSelected: selectedOption == 'upload',
                  onTap: () => setState(() => selectedOption = 'upload'),
                  width: screenWidth * 0.42,
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.05),

            // عرض الشاشة المختارة
            if (selectedOption.isNotEmpty)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
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

  // ويدجت لبطاقة الخيار
  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required double width,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE3F2FD) : Colors.white,
          border: Border.all(
            color: isSelected ? Color(0xFF196AB3) : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 30,
                color: isSelected ? Color(0xFF196AB3) : Colors.grey),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Color(0xFF196AB3) : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}