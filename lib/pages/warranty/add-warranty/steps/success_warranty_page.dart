import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../warranty-home/warranty-home.dart';
import '../../../../models/warranty_model.dart';
import '../../../Notification/notificationSetup/notification_setup_page.dart';

class SuccessWarrantyPage extends StatelessWidget {
  final WarrantyModel? newWarranty;

  const SuccessWarrantyPage({Key? key, this.newWarranty}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/warranty_success_icon.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 30),
              FittedBox(
                child: const Text(
                  'Garantie Ajoutée avec Succès !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 77, 77, 77),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Vous pouvez configurer les notifications maintenant ou plus tard dans les paramètres.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (newWarranty != null) {
                      Get.off(() => NotificationSetupPage(warranty: newWarranty!));
                    } else {
                      Get.snackbar(
                        "Erreur",
                        "La garantie est manquante. Redirection vers la page d'accueil.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      Future.delayed(const Duration(milliseconds: 1500), () {
                        Get.offAll(() => const WarrantyHomePage());
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Configurer Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Get.offAll(() => const WarrantyHomePage());
                },
                child: const Text(
                  'Plus Tard',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}