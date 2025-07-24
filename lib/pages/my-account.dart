import 'package:flutter/material.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Compte'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Page de gestion du compte utilisateur',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}