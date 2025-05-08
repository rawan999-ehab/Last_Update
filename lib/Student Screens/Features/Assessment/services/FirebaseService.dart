import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Assessment.dart';
import '../models/AssessmentResult.dart';
import '../models/Question.dart';

class FirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // تم تعديل الكونستركتور ليكون أكثر قابلية للاختبار
  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  Stream<List<Assessment>> getAssessments() {
    return _firestore.collection('Assessment').snapshots().asyncMap(
          (snapshot) async {
        return await Future.wait(
          snapshot.docs.map((doc) => Assessment.fromFirestore(doc)),
        );
      },
    );
  }

  Future<bool> hasAttemptedAssessment(String assessmentId) async {
    try {
      final result = await _firestore
          .collection('Assessment_result')
          .where('userId', isEqualTo: currentUserId)
          .where('assessmentId', isEqualTo: assessmentId)
          .limit(1)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check assessment attempt: $e');
    }
  }

  Future<List<Question>> getQuestionsForAssessment(String assessmentId) async {
    try {
      final snapshot = await _firestore
          .collection('Assessment')
          .doc(assessmentId)
          .collection('Questions')
          .get();

      return snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }

  Future<void> saveAssessmentResult(AssessmentResult result) async {
    try {
      await _firestore.collection('Assessment_result').add({
        ...result.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save result: $e');
    }
  }

  Stream<List<AssessmentResult>> getUserResults() {
    return _firestore
        .collection('Assessment_result')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AssessmentResult.fromFirestore(doc))
        .toList());
  }

  Future<Assessment?> getAssessment(String assessmentId) async {
    try {
      final doc = await _firestore.collection('Assessment').doc(assessmentId).get();
      return doc.exists ? Assessment.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Failed to get assessment: $e');
    }
  }
}