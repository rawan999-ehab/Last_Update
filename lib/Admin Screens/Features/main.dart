import 'package:flutter/material.dart';
import '../bottom_navbar.dart'; // غير الاسم لو الملف اسمه مختلف

// الصفحات الأساسية اللي هيظهروا
class OverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text("Overview Page"));
}

class InternshipsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text("Internships Page"));
}

class CoursesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text("Courses Page"));
}

class ProfilesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text("View Profiles Page"));
}

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    OverviewPage(),
    InternshipsPage(),
    CoursesPage(),
    ProfilesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
