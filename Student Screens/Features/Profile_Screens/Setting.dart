import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF2252A1),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2252A1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          children: [
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.lock, color: Color(0xFF2252A1)),
              title: Text('Change Password',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.pushNamed(context, '/change-password'); // أو استخدمي Navigator مع MaterialPageRoute
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.language, color: Color(0xFF2252A1)),
              title: Text('Language',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.pushNamed(context, '/language'); // أو استخدمي Navigator
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
