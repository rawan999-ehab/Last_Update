import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/services/snackbar_service.dart';
import 'package:project/Company Screens/Home_Screen.dart';
import 'package:project/screens/Features/main_screen.dart';
import 'package:project/Adminscreens/Features/Admin-MS.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SnackBarService _snackBarService = SnackBarService();

  Future<void> _updateUserPlayerId(String userId, String collection) async {
    // Get the playerID from OneSignal
    String? playerId = OneSignal.User.pushSubscription.id;

    if (playerId != null) {
      // Update Firestore with the playerID
      await _firestore.collection(collection).doc(userId).update({
        'playerId': playerId,
      });
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      QuerySnapshot userSnapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
      QuerySnapshot companySnapshot = await _firestore.collection('company').where('Email', isEqualTo: email).get();
      QuerySnapshot adminSnapshot = await _firestore.collection('admin').where('email', isEqualTo: email).get();

      if (userSnapshot.docs.isNotEmpty) {
        String userId = userSnapshot.docs.first.id;
        await _updateUserPlayerId(userId, 'users');
        _snackBarService.showCustomSnackBar(context, 'Login successful! Redirecting to student home screen...', Colors.green);
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacementNamed(context, MainScreen.routeName);
      } else if (companySnapshot.docs.isNotEmpty) {
        String companyId = companySnapshot.docs.first.id;
        await _updateUserPlayerId(companyId, 'company');
        _snackBarService.showCustomSnackBar(context, 'Login successful! Redirecting to company home screen...', Colors.green);
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacementNamed(context, Home_Screen.routeName, arguments: companyId);
      } else if (adminSnapshot.docs.isNotEmpty) {
        String adminId = adminSnapshot.docs.first.id;
        await _updateUserPlayerId(adminId, 'admin');
        _snackBarService.showCustomSnackBar(context, 'Login successful! Redirecting to admin home screen...', Colors.green);
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacementNamed(context, Adminms.routeName, arguments: adminId);
      } else {
        _snackBarService.showCustomSnackBar(context, 'Email not found in any collection.', Colors.red);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Please enter a valid email and password.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No account found with this email. Please check your email or sign up.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password. Please try again.';
      }
      _snackBarService.showCustomSnackBar(context, errorMessage, Colors.red);
    } catch (e) {
      _snackBarService.showCustomSnackBar(context, 'An unexpected error occurred. Please try again.', Colors.red);
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
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      String email = googleUser.email;
      QuerySnapshot userSnapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
      QuerySnapshot companySnapshot = await _firestore.collection('company').where('Email', isEqualTo: email).get();
      QuerySnapshot adminSnapshot = await _firestore.collection('admin').where('email', isEqualTo: email).get();

      if (userSnapshot.docs.isNotEmpty) {
        String userId = userSnapshot.docs.first.id;
        await _updateUserPlayerId(userId, 'users');
        _snackBarService.showCustomSnackBar(context, 'Google Sign-In successful! Redirecting to student home screen...', Colors.green);
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacementNamed(context, MainScreen.routeName);
      } else if (companySnapshot.docs.isNotEmpty) {
        String companyId = companySnapshot.docs.first.id;
        await _updateUserPlayerId(companyId, 'company');
        _snackBarService.showCustomSnackBar(context, 'Google Sign-In successful! Redirecting to company home screen...', Colors.green);
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacementNamed(context, Home_Screen.routeName, arguments: companyId);
      } else if (adminSnapshot.docs.isNotEmpty) {
        String adminId = adminSnapshot.docs.first.id;
        await _updateUserPlayerId(adminId, 'admin');
        _snackBarService.showCustomSnackBar(context, 'Google Sign-In successful! Redirecting to admin home screen...', Colors.green);
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacementNamed(context, Adminms.routeName, arguments: adminId);
      } else {
        _snackBarService.showCustomSnackBar(context, 'Email not found in any collection.', Colors.red);
      }
    } catch (e) {
      _snackBarService.showCustomSnackBar(context, 'Google Sign-In failed. Please try again.', Colors.red);
    }
  }
}
