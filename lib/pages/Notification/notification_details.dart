// Dans notification_details.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import '../../../models/notification_model.dart';
import '../../../controller/warranty_controller.dart';
import '../../../models/warranty_model.dart';

class NotificationDetailsPage extends StatefulWidget {
  final NotificationModel notification;
  const NotificationDetailsPage({super.key, required this.notification});

  @override
  _NotificationDetailsPageState createState() => _NotificationDetailsPageState();
}

class _NotificationDetailsPageState extends State<NotificationDetailsPage> {
  final WarrantyController warrantyController = Get.find<WarrantyController>();
  final Rx<WarrantyModel?> _warranty = Rx<WarrantyModel?>(null);
  final RxBool _isLoading = true.obs; 

  @override
  void initState() {
    super.initState();
    _fetchWarrantyDetails();
  }

  Future<void> _fetchWarrantyDetails() async {
    _isLoading.value = true;
    try {
      // Utilisez la méthode améliorée du contrôleur.
      final warranty = await warrantyController.getWarrantyById(widget.notification.warrantyId);
      if (mounted) {
        _warranty.value = warranty;
      }
    } catch (e) {
      log('Erreur lors de la récupération de la garantie: $e');
      if (mounted) {
        _warranty.value = null;
      }
    } finally {
      if (mounted) {
        _isLoading.value = false;
      }
    }
  }

  String _getTimeRemainingInDays(DateTime endDate) {
    // ... (unchanged code)
    final now = DateTime.now();
    final difference = endDate.difference(now);
    final days = difference.inDays;

    if (days < 0) {
      return 'Expirée le ${DateFormat('d MMMM yyyy').format(endDate)}';
    } else if (days == 0) {
      return 'Expire aujourd\'hui';
    } else {
      return '$days jour${days > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Détails de la notification',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final warranty = _warranty.value;
        if (warranty == null || warranty.product == null) {
          return const Center(
            child: Text(
              'Garantie non trouvée ou données incomplètes.',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        }

        final remainingDaysText = _getTimeRemainingInDays(warranty.endDate!);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'le garantie  $remainingDaysText avant la fin de la garantie.',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ce rappel a été créé pour le produit "${warranty.product?.productName ?? 'Nom non disponible'}". Voici les détails de votre garantie.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                icon: Icons.sell,
                label: 'Nom du produit',
                value: warranty.product?.productName ?? 'Nom non disponible',
              ),
              const SizedBox(height: 10),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Date de fin de garantie',
                value: DateFormat('d MMMM yyyy').format(warranty.endDate!),
              ),
              const SizedBox(height: 10),
              _buildInfoRow(
                icon: Icons.access_time,
                label: 'Date de rappel',
                value: DateFormat('d MMMM yyyy à HH:mm', 'fr_FR').format(widget.notification.scheduledDate),
              ),
              const SizedBox(height: 10),
              _buildInfoRow(
                icon: Icons.event,
                label: 'Type de rappel',
                value: widget.notification.type,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}