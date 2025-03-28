import 'package:flutter/material.dart';
class ViewStudentsInfo extends StatefulWidget {
  final String internshipId;
  const ViewStudentsInfo({Key? key, required this.internshipId}) : super(key: key);
  @override
  _ViewStudentsInfoState createState() => _ViewStudentsInfoState();}
class _ViewStudentsInfoState extends State<ViewStudentsInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool isLoading = true;
  List<Map<String, dynamic>> agreements = [];
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
    _rotationAnimation = Tween<double>(begin: 0, end: 3.14).animate(_controller);
    loadAgreements();
  }
  Future<void> loadAgreements() async {
    await Future.delayed(Duration(seconds: 3));
    agreements = [
      {"name": "Ahmed Abo El Asm", "job": "Java Developer", "cv": "Ahmed_CV.pdf", "accepted": false},//الاسم عندك من ال user
      {"name": "Mohamed Hassan", "job": "Flutter Developer", "cv": "Mohamed_CV.pdf", "accepted": false},
      {"name": "Abdelrahman Mostafa", "job": "UI/UX Designer", "cv": "Abdelrahman_CV.pdf", "accepted": false},
      {"name": "Nada Mostafa", "job": "Backend Developer", "cv": "Nada_CV.pdf", "accepted": false},
      {"name": "Hazem Ahmed", "job": "Data Scientist", "cv": "Hazem_CV.pdf", "accepted": false},
    ];
    setState(() {
      isLoading = false;
    });
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Students Info",
          style: TextStyle(color: Color(0xFF2252A1), fontSize: 21, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
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
        )
            : ListView.builder(
          itemCount: agreements.length,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: buildAgreementBox(index),
          ),
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
        color: Colors.white,
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
            onPressed: isAccepted ? null : () => acceptAgreement(index),
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