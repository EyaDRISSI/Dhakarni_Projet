import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dhakarni_1/models/warranty_model.dart';
import 'MigrateWarranty.dart';
import 'PendingMigrationsSection.dart';

class MigrateOrReceivePage extends StatelessWidget {
  final WarrantyModel warranty;

  const MigrateOrReceivePage({Key? key, required this.warranty}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color customPink = Color(0xFFE91E63);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('Gérer la migration', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: customPink),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/migration.png', height: 200),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => MigrateWarrantyPage(warranty: warranty));
                  },
                  icon: const Icon(Icons.send_rounded, size: 24),
                  label: const Text(
                    'Migrer une garantie',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.to(() => Scaffold(
                      appBar: AppBar(
                        title: const Text('Garanties reçues', style: TextStyle(color: Colors.black)),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: customPink),
                          onPressed: () => Get.back(),
                        ),
                      ),
                      body: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: PendingMigrationsSection(),
                      ),
                    ));
                  },
                  icon: const Icon(Icons.download_rounded, size: 24, color: customPink),
                  label: const Text(
                    'Garanties reçues',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: customPink),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    side: const BorderSide(color: customPink, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}