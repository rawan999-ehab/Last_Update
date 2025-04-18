import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/services/snackbar_service.dart';
import 'package:project/Company%20Screens/main_company.dart';
import 'package:project/Student Screens/Features/main_student.dart';
import 'package:project/Admin screens/Features/Admin-MS.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateUserPlayerId(String userId, String collection) async {
    String? playerId = OneSignal.User.pushSubscription.id;
    if (playerId != null) {
      await _firestore.collection(collection).doc(userId).update({'playerId': playerId});
    }
  }

  Future<void> _saveCompanyId(String companyId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('companyId', companyId);
  }

  Future<String?> getStoredCompanyId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('companyId');
  }

  Future<Map<String, dynamic>?> getCompanyById(String companyId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('company').doc(companyId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        print("❌ No company found with ID: $companyId");
        return null;
      }
    } catch (e) {
      print("⚠️ Error fetching company data: $e");
      return null;
    }
  }

  Future<void> _handleLogin(String email, BuildContext context) async {
    QuerySnapshot userSnapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
    QuerySnapshot companySnapshot = await _firestore.collection('company').where('Email', isEqualTo: email).get();
    QuerySnapshot adminSnapshot = await _firestore.collection('admin').where('email', isEqualTo: email).get();

    if (userSnapshot.docs.isNotEmpty) {
      String userId = userSnapshot.docs.first.id;
      await _updateUserPlayerId(userId, 'users');
      _navigateToScreen(context, MainScreen.routeName, 'Login successful! Redirecting to student home screen...');
    } else if (companySnapshot.docs.isNotEmpty) {
      String companyId = companySnapshot.docs.first.id;
      await _updateUserPlayerId(companyId, 'company');
      await _saveCompanyId(companyId);

      _showSnackbar(context, 'Login successful! Redirecting to company home screen...', Colors.green);

      // Navigate to MainCompany after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainCompany(companyId: companyId), // Navigate to MainCompany
          ),
        );
      });
    } else if (adminSnapshot.docs.isNotEmpty) {
      String adminId = adminSnapshot.docs.first.id;
      await _updateUserPlayerId(adminId, 'admin');
      _navigateToScreen(context, Adminms.routeName, 'Login successful! Redirecting to admin home screen...');
    } else {
      _showSnackbar(context, 'Email not found in any collection.', Colors.red);
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _handleLogin(email, context);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Please enter a valid email and password.';
      if (e.code == 'user-not-found') errorMessage = 'No account found with this email.';
      if (e.code == 'wrong-password') errorMessage = 'Incorrect password. Please try again.';
      _showSnackbar(context, errorMessage, Colors.red);
    } catch (e) {
      _showSnackbar(context, 'An unexpected error occurred. Please try again.', Colors.red);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      await _handleLogin(googleUser.email, context);
    } catch (e) {
      _showSnackbar(context, 'Google Sign-In failed. Please try again.', Colors.red);
    }
  }

  void _navigateToScreen(BuildContext context, String route, String message) {
    _showSnackbar(context, message, Colors.green);
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, route);
    });
  }

  void _showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
