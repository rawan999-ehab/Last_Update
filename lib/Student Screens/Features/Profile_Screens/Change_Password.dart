import 'package:flutter/material.dart';

import 'Setting.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => SettingScreen(),
      '/change-password': (context) => Change_Password(),
    },
  ));
}

class Change_Password extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    OutlineInputBorder customBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF2252A1)),
      borderRadius: BorderRadius.circular(8),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Change Password',
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
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Old Password',
                filled: true,
                fillColor: Colors.transparent,
                labelStyle: TextStyle(color: Color(0xFF2252A1)),
                border: customBorder,
                focusedBorder: customBorder,
                enabledBorder: customBorder,
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'New Password',
                filled: true,
                fillColor: Colors.transparent,
                labelStyle: TextStyle(color: Color(0xFF2252A1)),
                border: customBorder,
                focusedBorder: customBorder,
                enabledBorder: customBorder,
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                filled: true,
                fillColor: Colors.transparent,
                labelStyle: TextStyle(color: Color(0xFF2252A1)),
                border: customBorder,
                focusedBorder: customBorder,
                enabledBorder: customBorder,
              ),
              obscureText: true,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Logic to change password
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2252A1),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Change Password',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
