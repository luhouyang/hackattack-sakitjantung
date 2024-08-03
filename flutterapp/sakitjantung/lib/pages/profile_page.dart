import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/auth_services.dart';
import '../widgets/mybutton.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                "Your Profile",
                style: TextStyle(
                    color: Colors.blue[900],
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(50)),
              child: const Icon(
                Icons.person_2_rounded,
                size: 50,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2), blurRadius: 10)
                  ]),
              child: Column(
                children: [
                  Text(
                    "Signed in as ${user?.email}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MyButton(
                      color: Colors.blue[900]!,
                      text: "Log Out",
                      onTap: () {
                        FireAuthService fireAuth = FireAuthService();
                        fireAuth.logOut();
                      }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
