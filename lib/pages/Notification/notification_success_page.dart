import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../pages/warranty/warranty-home/warranty-home.dart';
import 'notificationSetup/notification_setup_page.dart';
import '../../../models/warranty_model.dart';

class NotificationSuccessPage extends StatelessWidget {
  final WarrantyModel? warranty;

  const NotificationSuccessPage({Key? key, required this.warranty}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/notif.png', height: 120),
              const SizedBox(height: 24),
              const Text(
                'Rappels Ajoutés avec Succès !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Vos rappels ont été ajoutés avec succès. Vous serez désormais notifié selon vos préférences pour ne jamais manquer une échéance de garantie.',
                style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 100, 98, 98)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (warranty != null) {
                      Get.off(() => NotificationSetupPage(warranty: warranty!));
                    } else {
                      Get.offAll(() => const WarrantyHomePage());
                      Get.snackbar(
                        'Erreur',
                        'Impossible d\'ajouter un autre rappel sans garantie sélectionnée.',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Ajouter un autre rappel',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Get.offAll(() => const WarrantyHomePage());
                  },
                  child: const Text(
                    'Terminer',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
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