import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  final String title;
  final String location;
  final String time;
  final String applicants;
  final String type1;
  final String type2;

  const JobCard({
    required this.title,
    required this.location,
    required this.time,
    required this.applicants,
    required this.type1,
    required this.type2,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue, width: 1),
      ),
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "$location · $time · $applicants",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.edit_note_sharp, color: Colors.blue),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                TagButton(text: type1),
                SizedBox(width: 8),
                TagButton(text: type2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Tag button widget
class TagButton extends StatelessWidget {
  final String text;

  const TagButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: Colors.blue, size: 16),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}