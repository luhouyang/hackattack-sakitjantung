import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sakitjantung/pages/login_page.dart';
import 'main_page.dart';

class AuthStreamPage extends StatelessWidget {
  const AuthStreamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return const MainPage();
          } else {
            return const LoginPage();
          }
        });
  }
}
