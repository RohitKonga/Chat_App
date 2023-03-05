import 'package:chat_app/screens/auth/login.dart';
import 'package:chat_app/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';

class LoginOrRegisterScreen extends StatefulWidget {
  const LoginOrRegisterScreen({super.key});

  @override
  State<LoginOrRegisterScreen> createState() => _LoginOrRegisterScreenState();
}

class _LoginOrRegisterScreenState extends State<LoginOrRegisterScreen> {
  //initially show login screen
  bool showLoginPage = true;

  //toggle between login and register screen
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: togglePages);
    } else {
      return RegisterScreen(onTap: togglePages);
    }
  }
}
