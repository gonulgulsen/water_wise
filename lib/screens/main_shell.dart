import 'package:flutter/material.dart';
import 'package:water_wise/screens/plant_page.dart';
import 'home_page.dart';
import 'usage_page.dart'; // 🔹 UsagePage import edildi

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 2; // Home default

  final _pages = const [
    Scaffold(
      backgroundColor: Color(0xFFD8C8C2),
      body: Center(child: Text("Profile Page")),
    ),
    UsagePage(),
    HomePage(),
    Scaffold(
      backgroundColor: Color(0xFFD8C8C2),
      body: Center(child: Text("My Task Page")),
    ),
    PlantPage()
  ];

  Widget _buildNavItem(int i, IconData icon, String label) {
    final isSelected = _index == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _index = i),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: isSelected ? 28 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8C8C2),
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF112250),
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            _buildNavItem(0, Icons.person_outline, "Profile"),
            _buildNavItem(1, Icons.opacity_outlined, "Usage"),
            _buildNavItem(2, Icons.home_outlined, "Home"),
            _buildNavItem(3, Icons.checklist_outlined, "My Task"),
            _buildNavItem(4, Icons.spa_outlined, "Plant"),
          ],
        ),
      ),
    );
  }
}
