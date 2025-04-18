import 'package:flutter/material.dart';

class companies extends StatefulWidget {
  @override
  _CompaniesState createState() => _CompaniesState();
}

class _CompaniesState extends State<companies> {
  List<Map<String, String>> companiesList = [
    {
      "name": "Jumia",
      "field": "Software Development Company",
      "email": "Jumia@gmail.com",
      "password": "Jumia123456"
    },
    {
      "name": "Amazon",
      "field": "Artificial Intelligence & Data Science",
      "email": "Amazon@gmail.com",
      "password": "Amazon123456"
    },
    {
      "name": "Shein",
      "field": "Databases",
      "email": "Shein@gmail.com",
      "password": "Shein123456"
    },
    {
      "name": "Dell",
      "field": "Software & Hardware Solutions",
      "email": "Dell@gmail.com",
      "password": "Dell123456"
    },
    {
      "name": "HP",
      "field": "Artificial Intelligence & Data Science",
      "email": "HP@gmail.com",
      "password": "HP123456"
    },
    {
      "name": "Amazon",
      "field": "Artificial Intelligence & Data Science",
      "email": "Amazon@gmail.com",
      "password": "Amazon123456"
    },
    {
      "name": "Jumia",
      "field": "Software Development Company",
      "email": "Jumia@gmail.com",
      "password": "Jumia123456"
    },
    {
      "name": "HP",
      "field": "Artificial Intelligence & Data Science",
      "email": "HP@gmail.com",
      "password": "HP123456"
    },
    {
      "name": "Dell",
      "field": "Software & Hardware Solutions",
      "email": "Dell@gmail.com",
      "password": "Dell123456"
    },
  ];

  void _deleteCompany(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this company?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                companiesList.removeAt(index);
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
        content: Text("Company deleted successfully"),
        backgroundColor: Color(0xFF196AB3),
        duration: Duration(seconds: 2),
      ),
    );
  }

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
          "Companies Profiles",
          style: TextStyle(color: Color(0xFF2252A1), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView.builder(
          itemCount: companiesList.length,
          itemBuilder: (context, index) {
            final company = companiesList[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.business, size: 40, color: Colors.blue),
                ),
                title: Text(
                  company["name"]!,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(company["field"]!, style: TextStyle(color: Colors.grey[700])),
                    Text(company["email"]!, style: TextStyle(color: Colors.grey[700])),
                    Text(company["password"]!, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.green),
                      onPressed: () {
                        print("Edit ${company["name"]}");
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCompany(index),
                    ),
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
