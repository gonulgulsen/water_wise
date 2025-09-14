import 'package:flutter/material.dart';
import 'login_page.dart';
//import 'home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // şimdilik hep login page açılıyo
    return const LoginPage();
  }
}