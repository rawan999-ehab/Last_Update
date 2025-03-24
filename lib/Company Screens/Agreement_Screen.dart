import 'package:flutter/material.dart';
import 'View_Students_Info.dart';

// تعريف كلاس التدريب مع العنوان والمدة فقط
class Internship {
  final String title;
  final String duration;

  Internship({required this.title, required this.duration});
}

// قائمة التدريبات (تحاكي بيانات قاعدة بيانات)
List<Internship> internships = [
  Internship(title: "Java Internship", duration: "3 Months"),
  Internship(title: "Web Developer Internship", duration: "6 Weeks"),
  Internship(title: "Python Internship", duration: "4 Months"),
];

class AgreementScreen extends StatelessWidget {
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
          "Internship Agreements",
          style: TextStyle(color: Color(0xFF2252A1), fontSize: 21, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: internships.length, // عدد العناصر في القائمة
        itemBuilder: (context, index) {
          return buildInternshipCard(context, internships[index]); // تمرير البيانات لكل عنصر
        },
      ),
    );
  }
}

// 🔹 دالة بناء البطاقة لكل تدريب مع عرض العنوان والمدة فقط
Card buildInternshipCard(BuildContext context, Internship internship) {
  return Card(
    margin: EdgeInsets.all(8.0),
    color: Colors.transparent, // الخلفية شفافة
    elevation: 0, // إزالة الظل
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Colors.blue, width: 2.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            internship.title, // ✅ عرض العنوان
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 8),
          Text(
            internship.duration, // ✅ عرض المدة فقط بدون وصف
            style: TextStyle(color: Colors.grey[700]),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // جعل الزر في أقصى اليمين
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewStudentsInfo()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // ✅ لون الزر أزرق
                  foregroundColor: Colors.white, // ✅ لون النص أبيض
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12), // مسافات داخلية
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // زوايا مدورة
                  ),
                ),
                child: Text("View Students Info"),
              ),

            ],
          ),
        ],
      ),
    ),
  );
}
