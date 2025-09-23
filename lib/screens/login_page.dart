import 'package:flutter/material.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'main_shell.dart'; // 🔹 yeni ekleme
import '../utils/statusbar.dart';
import '../utils/snackbar.dart';
import '../utils/dialogs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  final _emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');

  void _submitIfValid() {
    if (!_formKey.currentState!.validate()) {
      showErrorMessage(context, "Please fill out the form correctly");
      return;
    }

    showSuccessDialog(
      context,
      "Login successful",
      onOk: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainShell()), // 🔹 değiştirildi
        );
      },
    );
  }

  InputDecoration _outlinedDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFD8CBC2)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD8CBC2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD8CBC2), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setStatusBarLightIcons();

    return Scaffold(
      body: Container(
        color: const Color(0xFF112250), // koyu mavi arka plan
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Logo
                  Column(
                    children: [
                      Image.asset(
                        "assets/images/water-wise-logo.png",
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "WELCOME BACK",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFFF5FDE8DD),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Color(0xFFD8CBC2)),
                    keyboardType: TextInputType.emailAddress,
                    decoration: _outlinedDecoration("Email Address"),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Enter your email";
                      }
                      if (!_emailRegex.hasMatch(v.trim())) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Color(0xFFD8CBC2)),
                    decoration: _outlinedDecoration("Password").copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFFD8CBC2),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Enter your password";
                      }
                      if (v.length < 6) {
                        return "The password must be at least 6 characters long";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(color: Color(0xFFD8CBC2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login button
                  SizedBox(
                    width: 328,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitIfValid,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD8CBC2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFFD8CBC2),
                            width: 1,
                          ),
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF112250),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign up
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(color: Color(0xFFD8CBC2)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
