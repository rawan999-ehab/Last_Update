import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Assessment.dart';
import '../services/FirebaseService.dart';
import '../widgets/AssessmentCard.dart';
import 'QuizScreen.dart';


class AssessmentListScreen extends StatefulWidget {
  @override
  _AssessmentListScreenState createState() => _AssessmentListScreenState();
}

class _AssessmentListScreenState extends State<AssessmentListScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Assessments'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Assessment>>(
        stream: _firebaseService.getAssessments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final assessments = snapshot.data ?? [];

          return assessments.isEmpty
              ? Center(child: Text('No assessments available'))
              : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: assessments.length,
            itemBuilder: (context, index) {
              return FutureBuilder<bool>(
                future: _firebaseService.hasAttemptedAssessment(assessments[index].id),
                builder: (context, attemptedSnapshot) {
                  final attempted = attemptedSnapshot.data ?? false;

                  return AssessmentCard(
                    assessment: assessments[index],
                    attempted: attempted,
                    onTap: () => _confirmStartAssessment(context, assessments[index], attempted),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _confirmStartAssessment(BuildContext context, Assessment assessment, bool attempted) {
    if (attempted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Assessment Already Taken'),
          content: Text('You have already completed this assessment.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start Assessment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assessment: ${assessment.title}'),
            SizedBox(height: 8),
            Text('Questions: ${assessment.totalQuestions}'),
            SizedBox(height: 8),
            Text('Time: ${assessment.timeInMinutes} minutes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(assessment: assessment),
                ),
              );
            },
            child: Text('Start'),
          ),
        ],
      ),
    );
  }
}
