import 'package:flutter/material.dart';

class students extends StatelessWidget {
  final List<Map<String, String>> studentsList = [
    {"name": "Rawan Ehab", "field": "Front-End Developer", "email": "Rawan@gmail.com", "password": "123"},
    {"name": "Joumana Samy", "field": "Front-End Developer", "email": "Joumana@gmail.com", "password": "1234"},
    {"name": "Mina Samy", "field": "Back-End Developer", "email": "Mina@gmail.com", "password": "12345"},
    {"name": "Mahmoud Kotp", "field": "Database Developer", "email": "Mahmoud@gmail.com", "password": "123456"},
    {"name": "Beshoy Rasmi", "field": "Front-End Developer", "email": "Beshoy@gmail.com", "password": "1234567"},
    {"name": "Mona Salah", "field": "Software Engineer", "email": "Mona@gmail.com", "password": "12345678"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2252A1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Students Profiles",
          style: TextStyle(color: Color(0xFF2252A1), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView.builder(
          itemCount: studentsList.length,
          itemBuilder: (context, index) {
            final student = studentsList[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: EdgeInsets.all(10),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                title: Text(
                  student["name"]!,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student["field"]!, style: TextStyle(color: Colors.grey[700])),
                    Text(student["email"]!, style: TextStyle(color: Colors.grey[700])),
                    Text(student["password"]!, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
