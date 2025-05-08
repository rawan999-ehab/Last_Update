import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/Student Screens/Features/Assessment/services/AuthService.dart';
import '../models/AssessmentResult.dart';
import '../services/FirebaseService.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _confirmSignOut(context, authService),
          ),
        ],
      ),
      body: StreamBuilder<List<AssessmentResult>>(
        stream: _firebaseService.getUserResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final results = snapshot.data ?? [];

          if (results.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileStats(context, results),
                SizedBox(height: 24),
                Text(
                  'Assessment History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return _buildResultCard(context, results[index]);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No assessments taken yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Complete an assessment to see your results here',
            style: TextStyle(
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats(BuildContext context, List<AssessmentResult> results) {
    int totalAssessments = results.length;

    int totalQuestions = results.fold<int>(0, (int sum, AssessmentResult result) {
      return sum + result.totalQuestions;
    });

    int totalCorrect = results.fold<int>(0, (int sum, AssessmentResult result) {
      return sum + result.totalCorrectAnswers;
    });

    double avgPercentage = 0.0;

    if (results.isNotEmpty && totalAssessments != 0) {
      avgPercentage = results.fold<double>(0.0, (double sum, AssessmentResult result) {
        return sum + result.percentage;
      }) / totalAssessments;
    }
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  context,
                  'Assessments',
                  totalAssessments.toString(),
                  Icons.assignment,
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  'Avg. Score',
                  '${avgPercentage.toStringAsFixed(1)}%',
                  Icons.score,
                  _getScoreColor(avgPercentage),
                ),
                _buildStatItem(
                  context,
                  'Correct',
                  '${totalCorrect}/${totalQuestions}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, AssessmentResult result) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    result.assessmentName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getLevelColor(result.level).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result.level,
                    style: TextStyle(
                      color: _getLevelColor(result.level),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: ${result.score} (${result.percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: _getScoreColor(result.percentage),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${result.totalCorrectAnswers}/${result.totalQuestions} correct',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Taken on ${_formatDate(result.timestamp)}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _confirmSignOut(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 75) {
      return Colors.blue;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Expert':
        return Colors.green;
      case 'Advanced':
        return Colors.blue;
      case 'Intermediate':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}