import 'package:flutter/material.dart';

import 'change_password.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool pushNotifications = true;

  void _openEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF112250),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            bottom: bottomInset,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FDE8),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const Text(
                "Edit Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: _inputDecoration("Name"),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: _inputDecoration("Surname"),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: _inputDecoration("City"),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: _inputDecoration("District"),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: _inputDecoration("Neighborhood"),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEDC58F),
                    foregroundColor: const Color(0xFF112250),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile updated")),
                    );
                  },
                  child: const Text("SUBMIT"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  static InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white30),
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
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: _openEditProfileSheet,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Column(
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundColor: Colors.purple,
              ),
              const SizedBox(height: 12),
              const Text(
                "Tanya Menyshuk",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Text(
                "Ankara, Çankaya, Bahçelievler",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildListTile("Personal Info"),
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

          Theme(
            data: Theme.of(context).copyWith(
              splashColor: const Color(0xFFF5FDE8),
              highlightColor: const Color(0xFFF5FDE8),
            ),
            child: SwitchListTile(
              title: const Text("Push Notifications"),
              value: pushNotifications,
              onChanged: (val) {
                setState(() => pushNotifications = val);
              },
            ),
          ),
          const Divider(color: Color(0xFF11225050)),

          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              "Delete Account",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
      String title, {
        Widget? trailing,
        VoidCallback? onTap,
      }) {
    return ListTile(
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap, // dışarıdan gelen fonksiyon
    );
  }

}
