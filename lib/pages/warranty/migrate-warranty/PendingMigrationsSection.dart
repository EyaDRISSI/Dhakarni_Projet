// Fichier : lib/pages/warranty/migrate-warranty/PendingMigrationsSection.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Importez le modèle de garantie si nécessaire
// import '../../../../models/warranty_model.dart';

class PendingMigrationsSection extends StatelessWidget {
  PendingMigrationsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Demandes de migration en attente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200, // Une hauteur fixe pour l'exemple
          child: ListView.builder(
            itemCount: 2, // Exemple avec 2 éléments factices
            itemBuilder: (context, index) {
              final String senderEmail =
                  'utilisateur${index + 1}@example.com';
              final String productName = 'Produit ${index + 1}';

              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text('Demande de migration pour $productName'),
                  subtitle: Text('De : $senderEmail'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () {
                          // Action fictive pour l'acceptation
                          Get.snackbar(
                            'Action',
                            'Acceptation simulée de la demande de $senderEmail',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          // Action fictive pour le rejet
                          Get.snackbar(
                            'Action',
                            'Rejet simulé de la demande de $senderEmail',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}