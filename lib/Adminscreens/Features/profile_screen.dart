import 'package:flutter/material.dart';
import '../ViewProfiles/students.dart';
import '../ViewProfiles/companies.dart';

class ViewProfiles extends StatelessWidget {
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
          "View Profiles",
          style: TextStyle(color: Color(0xFF2252A1), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Choose Your Role",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2252A1)),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => students()),
                    );
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: 50, color: Colors.blue),
                        SizedBox(height: 5),
                        Text("Student", style: TextStyle(color: Colors.blue, fontSize: 16)),
                      ],
                    ),
                  ),
                ),


                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => companies()),
                    );
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.business, size: 50, color: Colors.blue),
                        SizedBox(height: 5),
                        Text("Company", style: TextStyle(color: Colors.blue, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
