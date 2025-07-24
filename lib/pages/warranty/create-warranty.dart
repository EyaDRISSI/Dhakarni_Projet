import 'package:flutter/material.dart';

class AddWarrantyPage extends StatelessWidget {
  const AddWarrantyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une Garantie'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Page pour ajouter une nouvelle garantie',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}