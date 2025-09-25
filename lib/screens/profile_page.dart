import 'package:flutter/material.dart';
import 'package:water_wise/screens/personal_info.dart';
import 'change_password.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';
import '../utils/snackbar.dart'; // ✅ snackbarları ekledik

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool pushNotifications = true;
  Map<String, dynamic>? userData;

  final user = FirebaseAuth.instance.currentUser; // login olan kullanıcı

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      setState(() {
        userData = doc.data();
      });
    }
  }

  void _openEditProfileSheet() {
    if (userData == null) return;

    final nameCtrl = TextEditingController(text: userData!['name'] ?? "");
    final surnameCtrl = TextEditingController(text: userData!['surname'] ?? "");
    final phoneCtrl = TextEditingController(text: userData!['telephone'] ?? "");
    final cityCtrl = TextEditingController(text: userData!['city'] ?? "");
    final districtCtrl = TextEditingController(text: userData!['district'] ?? "");
    final neighborhoodCtrl =
    TextEditingController(text: userData!['neighborhood'] ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF3C5070),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Profile",
                  style: TextStyle(
                    color: Color(0xFFD8C8C2),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: nameCtrl,
                        style: const TextStyle(color: Color(0xFFD8C8C2)),
                        cursorColor: Color(0xFFD8C8C2),
                        decoration: _underlineInput("Name"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: surnameCtrl,
                        style: const TextStyle(color: Color(0xFFD8C8C2)),
                        cursorColor: Color(0xFFD8C8C2),
                        decoration: _underlineInput("Surname"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: phoneCtrl,
                  style: const TextStyle(color: Color(0xFFD8C8C2)),
                  cursorColor: Color(0xFFD8C8C2),
                  decoration: _underlineInput("Telephone"),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: cityCtrl,
                  style: const TextStyle(color: Color(0xFFD8C8C2)),
                  cursorColor: Color(0xFFD8C8C2),
                  decoration: _underlineInput("City"),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: districtCtrl,
                  style: const TextStyle(color: Color(0xFFD8C8C2)),
                  cursorColor: Color(0xFFD8C8C2),
                  decoration: _underlineInput("District"),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: neighborhoodCtrl,
                  style: const TextStyle(color: Color(0xFFD8C8C2)),
                  cursorColor: Color(0xFFD8C8C2),
                  decoration: _underlineInput("Neighborhood"),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEDC58F),
                      foregroundColor: const Color(0xFF112250),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (user == null) return;

                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .update({
                          'name': nameCtrl.text,
                          'surname': surnameCtrl.text,
                          'telephone': phoneCtrl.text,
                          'city': cityCtrl.text,
                          'district': districtCtrl.text,
                          'neighborhood': neighborhoodCtrl.text,
                        });

                        Navigator.pop(ctx);
                        _loadUserData();

                        showSuccessMessage(context, "Profile updated successfully");
                      } catch (e) {
                        showErrorMessage(context, "Failed to update profile: $e");
                      }
                    },
                    child: const Text("SUBMIT"),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static InputDecoration _underlineInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFD8C8C2)),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD8C8C2)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD8C8C2), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8C8C2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8C8C2),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SpeedDial(
              icon: Icons.settings,
              activeIcon: Icons.close,
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF112255),
              elevation: 0,
              overlayColor: Colors.transparent,
              overlayOpacity: 0.0,
              direction: SpeedDialDirection.down,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.edit, color: Colors.white),
                  backgroundColor: const Color(0xFF3C5070),
                  onTap: _openEditProfileSheet,
                ),
                SpeedDialChild(
                  child: const Icon(Icons.delete, color: Colors.white),
                  backgroundColor: const Color(0xFFC30B0E),
                  onTap: () async {
                    try {
                      if (user == null) return;

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .delete();

                      await user!.delete();

                      if (!mounted) return;
                      showSuccessMessage(context, "Account deleted successfully");

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                      );
                    } on FirebaseAuthException catch (e) {
                      String message = "An error occurred";
                      if (e.code == "requires-recent-login") {
                        message = "Please re-login before deleting your account";
                      }
                      showErrorMessage(context, message);
                    } catch (e) {
                      showErrorMessage(context, "Unexpected error: $e");
                    }
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.logout, color: Colors.white),
                  backgroundColor: const Color(0xFF112250),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();

                    if (!mounted) return;
                    showSuccessMessage(context, "Logged out successfully");

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Column(
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundImage: AssetImage('assets/images/avatar.jpg'),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 12),
              Text(
                "${userData!['name']} ${userData!['surname']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                "${userData!['city']}, ${userData!['district']}, ${userData!['neighborhood']}",
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildListTile(
              "Personal Info",
            onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PersonalInfo())
                );
            }
          ),
          const Divider(color: Color(0xFF11225050)),
          _buildListTile(
            "Change Password",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePassword()),
              );
            },
          ),
          const Divider(color: Color(0xFF11225050)),
          _buildListTile("Language", trailing: const Text("English")),
          const Divider(color: Color(0xFF11225050)),
          SwitchListTile(
            title: const Text("Push Notifications"),
            value: pushNotifications,
            activeColor: const Color(0xFF3C5070),
            activeTrackColor: const Color(0xFF3C5070).withOpacity(0.5),
            onChanged: (val) {
              setState(() => pushNotifications = val);
            },
          ),
          const Divider(color: Color(0xFF11225050)),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
