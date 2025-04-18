import 'package:flutter/material.dart';
import '../Courses_Screens/Cybersecurity.dart';
import '../Add_screens/Add_Course.dart';

class CoursesScreen extends StatefulWidget {
  static const String routeName = "CoursesFieldsScreen";

  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<String> fields = [
    'Cybersecurity',
    'Networking',
    'Software Development',
    'Front End Developer',
    'Back End Developer',
    'Full Stack Developer',
    'Mobile Application Development',
    'Operating Systems',
    'UI/UX Design',
    'Cloud Computing',
    'Databases',
    'Database Administrator',
    'Data Science and Analytics',
    'C programming language',
    'C++ programming language',
    'C# programming language',
    'Information Technology',
    'Software Engineering',
    'Project Management',
  ];

  void _deleteField(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this course?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                fields.removeAt(index);
              });
              Navigator.pop(context);
              _showMessage();
            },
            child: Text("Confirm", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Course deleted successfully"),
        backgroundColor: Color(0xFF196AB3),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/images/courses.jpeg',
                fit: BoxFit.fill,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Choose Your Field',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2252A1)),
                    textAlign: TextAlign.center,
                  ),
                ),
                ..._buildFieldButtons(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddCourse()));
        },
        backgroundColor: Color(0xFF196AB3),
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  List<Widget> _buildFieldButtons(BuildContext context) {
    return List.generate(fields.length, (index) {
      return FieldButton(
        text: fields[index],
        onDelete: () => _deleteField(index),
        onEdit: () {
          print("Edit course: ${fields[index]}");
        },
      );
    });
  }
}

class FieldButton extends StatelessWidget {
  final String text;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  FieldButton({required this.text, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  if (text == "Cybersecurity") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Cybersecurity()),
                    );
                  } else {
                    print('Button pressed: $text');
                  }
                },
                child: Text(
                  text,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.green),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
