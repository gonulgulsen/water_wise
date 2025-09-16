import 'package:flutter/material.dart';
import '../utils/statusbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    setStatusBarDarkIcons();
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: const Center(
        child: Text(
          "dummy home-page",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}