import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import '../utils/snackbar.dart';
import '../utils/statusbar.dart';
import '../utils/dialogs.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _neighborhoodController = TextEditingController();

  bool _agreedToTerms = false;

  // özel karakter tespiti
  final _lettersSpacesTR = RegExp(r'^[A-Za-zÇĞİÖŞÜçğıöşü\s]+$');

  void _submitIfValid() {
    if (!_formKey.currentState!.validate()) {
      showErrorMessage(context, "Please fill out the form correctly");
      return;
    }
    if (!_agreedToTerms) {
      showErrorMessage(context, "You must agree to the terms");
      return;
    }

    showSuccessDialog(
      context,
      "Your account has been successfully created.",
      onOk: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      },
    );
  }

  InputDecoration _underlineDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF0A1445)),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF0A1445)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF0A1445), width: 2),
      ),
    );
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: _underlineDecoration("Name"),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Name is required";
                            }
                            if (!_lettersSpacesTR.hasMatch(v.trim())) {
                              return "Only letters and spaces are allowed";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _surnameController,
                          decoration: _underlineDecoration("Surname"),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Surname is required";
                            }
                            if (!_lettersSpacesTR.hasMatch(v.trim())) {
                              return "Only letters and spaces are allowed";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // telefon no
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    decoration: _underlineDecoration("Telephone"),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Phone number is required";
                      }
                      if (v.length < 10 || v.length > 11) {
                        return "Phone number must be 10 or 11 digits";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // şehir
                  TextFormField(
                    controller: _cityController,
                    decoration: _underlineDecoration("City"),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "City is required";
                      }
                      if (!_lettersSpacesTR.hasMatch(v.trim())) {
                        return "Only letters and spaces are allowed";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ilçe
                  TextFormField(
                    controller: _districtController,
                    decoration: _underlineDecoration("District"),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "District is required";
                      }
                      if (!_lettersSpacesTR.hasMatch(v.trim())) {
                        return "Only letters and spaces are allowed";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // mahalle
                  TextFormField(
                    controller: _neighborhoodController,
                    decoration: _underlineDecoration("Neighborhood"),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Neighborhood is required";
                      }
                      if (!_lettersSpacesTR.hasMatch(v.trim())) {
                        return "Only letters and spaces are allowed";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // terms kontrolü
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (v) {
                          setState(() {
                            _agreedToTerms = v ?? false;
                          });
                        },
                        activeColor: const Color(0xFF112250),
                      ),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            text: "I agree to ",
                            style: TextStyle(color: Color(0xFF112250)),
                            children: [
                              TextSpan(
                                text: "Privacy Policy",
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: " and "),
                              TextSpan(
                                text: "Term of use",
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),

                  // create account butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitIfValid,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF112250),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Create Account",
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
