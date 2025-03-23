import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class Agreement_Screen extends StatefulWidget {
  @override
  _AgreementScreenState createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<Agreement_Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool isLoading = true;
  List<Map<String, dynamic>> agreements = [];

  @override
  void initState() {
    super.initState();

    // Loading design
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: 0, end: 3.14).animate(_controller);

    loadAgreements();
  }

  Future<void> loadAgreements() async {
    await Future.delayed(Duration(seconds: 3)); //Loading Time
    List<Map<String, dynamic>> data = [
      {"name": "Ahmed Abo El Asm", "job": "Java Developer", "cv": "Ahmed_CV.pdf", "accepted": false},
      {"name": "Mohamed Hassan", "job": "Flutter Developer", "cv": "Mohamed_CV.pdf", "accepted": false},
      {"name": "Abdelrahman Mostafa", "job": "UI/UX Designer", "cv": "Abdelrahman_CV.pdf", "accepted": false},
      {"name": "Nada Mostafa", "job": "Backend Developer", "cv": "Nada_CV.pdf", "accepted": false},
      {"name": "Hazem Ahmed", "job": "Data Scientist", "cv": "Hazem_CV.pdf", "accepted": false},
    ];

    setState(() {
      agreements = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Text(
              "Agreement",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2252A1),
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 20),

            // clock design
            isLoading
                ? Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Icon(
                        Icons.hourglass_empty,
                        size: 60,
                        color: Color(0xFF2252A1),
                      ),
                    );
                  },
                ),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: agreements.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: buildAgreementBox(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAgreementBox(int index) {
    Map<String, dynamic> agreement = agreements[index];
    bool isAccepted = agreement["accepted"];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: isAccepted ? Colors.grey : Colors.blue),
        borderRadius: BorderRadius.circular(10),
        color: isAccepted ? Colors.white : Colors.transparent,
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 40, color: Colors.black54),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agreement["name"],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    agreement["job"],
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0x5490CAF9),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                agreement["cv"],
                style: TextStyle(color: Colors.black54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 10),


          ElevatedButton(
            onPressed: isAccepted
                ? null
                : () {
              acceptAgreement(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccepted ? Colors.grey : Color(0xFF2252A1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Text(
                isAccepted ? "Accepted" : "Accept",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void acceptAgreement(int index) {
    setState(() {
      agreements[index]["accepted"] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You have accepted ${agreements[index]["name"]}!"),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF2252A1),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
