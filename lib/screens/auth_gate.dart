import 'package:flutter/material.dart';
import 'login_page.dart';
import 'main_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // şimdilik login → MainShell
    return const LoginPage();
    // ileride FirebaseAuth bağlayınca burada MainShell döneceğiz.
  }
}
