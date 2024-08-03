import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sakitjantung/services/firebase_services.dart';

class FireAuthService {
  Future<void> signIn(
      BuildContext context, String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseService useCase = FirebaseService();
      useCase.createUserDocument(FirebaseAuth.instance.currentUser!.uid);
    } catch (e) {
      debugPrint("Error during sign-in: $e");
      if (e is FirebaseAuthException) {
        _showErrorDialog(context, "Error: ${e.message}");
      }
    }
  }

  Future<void> signUp(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      FirebaseService useCase = FirebaseService();
      useCase.createUserDocument(userCredential.user!.uid);
    } catch (e) {
      debugPrint("Error during sign-up: $e");
      if (e is FirebaseAuthException) {
        _showErrorDialog(context, "Error: ${e.message}");
      }
    }
  }

  void logOut() {
    FirebaseAuth.instance.signOut();
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authentication Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
