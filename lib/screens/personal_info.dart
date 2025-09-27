import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8C8C2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8C8C2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Personal Info",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3C5070),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF112250)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage("assets/images/avatar.jpg"),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${userData!['name']} ${userData!['surname']}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF112250),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${userData!['city']}, ${userData!['district']}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                const Divider(color: Color(0xFF11225050)),

                _infoTile(
                  icon: Icons.phone,
                  label: "Telephone",
                  value: userData!['telephone'] ?? "-",
                ),
                const Divider(color: Color(0xFF11225050)),

                _infoTile(
                  icon: Icons.location_city,
                  label: "City",
                  value: userData!['city'] ?? "-",
                ),
                const Divider(color: Color(0xFF11225050)),

                _infoTile(
                  icon: Icons.map,
                  label: "District",
                  value: userData!['district'] ?? "-",
                ),
                const Divider(color: Color(0xFF11225050)),

                _infoTile(
                  icon: Icons.home,
                  label: "Neighborhood",
                  value: userData!['neighborhood'] ?? "-",
                ),
              ],
            ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3C5070)),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF112250),
        ),
      ),
      subtitle: Text(value, style: const TextStyle(color: Colors.black87)),
    );
  }
}
