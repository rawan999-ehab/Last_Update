import 'package:flutter/material.dart';
import '/Company Screens/HomeScreen.dart';
import '/Company Screens/Agreement_Screen.dart';
import '/Company Screens/History_Screen.dart';
import '/Company Screens/Profile_Screen.dart';
import '/Company Screens/nav_bar.dart';
import 'add_screen.dart'; // Import the add screen

class MainCompany extends StatefulWidget {
  static const String routeName = '/MainCompany';
  final String companyId;

  MainCompany({required this.companyId}); // إضافة المتغير companyId

  @override
  _MainCompanyState createState() => _MainCompanyState();
}

class _MainCompanyState extends State<MainCompany> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // إنشاء قائمة الصفحات
    final List<Widget> _pages = [
      HomeScreen(companyid: widget.companyId), // تمرير companyId إلى HomeScreen
      AgreementScreen(),
      HistoryScreen(),
      ProfileScreen(companyId: widget.companyId),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF196AB3),
        child: Icon(Icons.add, size: 30, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddScreen(Id: widget.companyId), // تم تمرير ID هنا
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Nav_Bar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
