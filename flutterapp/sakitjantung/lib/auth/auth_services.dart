import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sakitjantung/usecase/noti_listener_usecase.dart';

class FireAuthService {
  Future<void> signIn(
      BuildContext context, String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      NotiListenerUseCase useCase = NotiListenerUseCase();
      useCase.createUserDocument(FirebaseAuth.instance.currentUser!.uid);
    } catch (e) {
      // Handle authentication exceptions
      debugPrint("Error during sign-in: $e");

      // You can customize this part based on your requirements
      if (e is FirebaseAuthException) {
        // Show a pop-up modal for incorrect email or password
        // ignore: use_build_context_synchronously
        _showErrorDialog(context, "Error $e");
      }
    }
  }

  void logOut() {
    FirebaseAuth.instance.signOut();
  }

  // Function to show an error dialog
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
