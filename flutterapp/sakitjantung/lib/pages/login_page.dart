import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakitjantung/utils/constants.dart';
import 'package:sakitjantung/widgets/mybutton.dart';
import 'package:sakitjantung/widgets/mytextbox.dart';
import '../auth/auth_services.dart';
import '../usecase/navigation_usecase.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _signup = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: MyColours.primaryColour,
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(100))),
            ),
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  _signup
                      ? const Text(
                          "Sign Up Page",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        )
                      : const Text(
                          "Login Page",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10)
                        ]),
                    child: Column(
                      children: [
                        MyTextBox(
                            controller: emailController, hintText: "Email"),
                        MyTextBox(
                          controller: passwordController,
                          hintText: "Password",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _signup
                      ? MyButton(
                          color: MyColours.primaryColour,
                          text: "Sign Up",
                          onTap: () {
                            FireAuthService fireAuth = FireAuthService();
                            fireAuth.signUp(
                                context,
                                emailController.text.trim(),
                                passwordController.text.trim());
                            NavigationUseCase navigationUseCase =
                                Provider.of<NavigationUseCase>(context,
                                    listen: false);
                            navigationUseCase.changeIdx(0);
                            emailController.clear();
                            passwordController.clear();
                          },
                        )
                      : MyButton(
                          color: MyColours.primaryColour,
                          text: "Login",
                          onTap: () {
                            FireAuthService fireAuth = FireAuthService();
                            fireAuth.signIn(
                                context,
                                emailController.text.trim(),
                                passwordController.text.trim());
                            NavigationUseCase navigationUseCase =
                                Provider.of<NavigationUseCase>(context,
                                    listen: false);
                            navigationUseCase.changeIdx(0);
                            emailController.clear();
                            passwordController.clear();
                          },
                        ),
                  const SizedBox(
                    height: 16,
                  ),
                  Divider(color: MyColours.primaryColour, height: 2.0),
                  _signup
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: RichText(
                              text: TextSpan(
                                  style: const TextStyle(fontSize: 16),
                                  children: <TextSpan>[
                                const TextSpan(
                                    text: "Already have an account? ",
                                    style: TextStyle(color: Colors.black)),
                                TextSpan(
                                    text: "Login",
                                    style: TextStyle(
                                      color: MyColours.primaryColour,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _signup = !_signup;
                                        setState(() {});
                                      })
                              ])),
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: RichText(
                              text: TextSpan(
                                  style: const TextStyle(fontSize: 16),
                                  children: <TextSpan>[
                                const TextSpan(
                                    text: "Create a new account ",
                                    style: TextStyle(color: Colors.black)),
                                TextSpan(
                                    text: "Here",
                                    style: TextStyle(
                                      color: MyColours.primaryColour,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _signup = !_signup;
                                        setState(() {});
                                      })
                              ])),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
