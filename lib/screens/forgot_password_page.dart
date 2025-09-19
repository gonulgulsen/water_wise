import 'package:flutter/material.dart';
import '../utils/snackbar.dart';
import '../utils/statusbar.dart';
import '../utils/dialogs.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final _emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');

  void _resetPassword() {
    if (!_formKey.currentState!.validate()) {
      showErrorMessage(context, "Please enter a valid email address");
      return;
    }

    showSuccessDialog(
      context,
      "Password reset link has been sent to your email.",
    );
  }

  InputDecoration _underlineDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF112250)),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF112250)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF112250), width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setStatusBarDarkIcons();

    return Scaffold(
      body: Container(
        color: const Color(0xFFD8CBC2),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.lock_reset,
                      size: 80, color: Color(0xFF112250)),
                  const SizedBox(height: 16),
                  const Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF112250),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _underlineDecoration("Email"),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Email is required";
                      }
                      if (!_emailRegex.hasMatch(v.trim())) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Reset button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF112250),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Send Reset Link",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD8CBC2),
                        ),
                      ),
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
