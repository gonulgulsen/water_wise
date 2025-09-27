import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/snackbar.dart';
import '../utils/statusbar.dart';
import 'package:lottie/lottie.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'main_shell.dart';

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
  bool _isLoading = false;

  final _emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');

  Future<void> _submitIfValid() async {
    if (!_formKey.currentState!.validate()) {
      showErrorMessage(context, "Please fill out the form correctly");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _showLoginSuccessDialog();
    } on FirebaseAuthException catch (e) {
      String message = "Login failed!";
      if (e.code == "user-not-found") {
        message = "No user found for this email.";
      } else if (e.code == "wrong-password") {
        message = "Incorrect password.";
      } else if (e.code == "invalid-email") {
        message = "Invalid email address.";
      }
      showErrorMessage(context, message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLoginSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 60),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FDE8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Login Successful!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3C5070),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Welcome back! You are now logged in.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xFF3C5070)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainShell(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C5070),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          color: Color(0xFFF5FDE8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 0,
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: Lottie.network(
                    "https://assets10.lottiefiles.com/packages/lf20_jbrw3hcz.json",
                    repeat: false,
                  ),
                ),
              ),
            ],
          ),
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
        color: const Color(0xFF112250),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
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

                  SizedBox(
                    width: 328,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitIfValid,
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
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Color(0xFF112250),
                            )
                          : const Text(
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
