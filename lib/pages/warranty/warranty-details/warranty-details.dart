import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import '../../../models/warranty_model.dart';
import '../../../controller/warranty_controller.dart';
import '../edit-warranty/Edit-warranty.dart';
import 'package:share_plus/share_plus.dart';
import '../migrate-warranty/MigrateOrReceivePage.dart';
import './RemindersTabContent.dart';


class WarrantyDetailsPage extends StatefulWidget {
  final WarrantyModel warranty;
  const WarrantyDetailsPage({Key? key, required this.warranty}) : super(key: key);

  @override
  State<WarrantyDetailsPage> createState() => _WarrantyDetailsPageState();
}

class _WarrantyDetailsPageState extends State<WarrantyDetailsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final WarrantyController _warrantyController = Get.find<WarrantyController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Non spécifié';
    DateTime parsedDate;
    if (date is DateTime) {
      parsedDate = date;
    } else if (date is String) {
      try {
        parsedDate = DateTime.parse(date);
      } catch (e) {
        try {
          final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
          parsedDate = inputFormat.parse(date);
        } catch (e) {
          return 'Date invalide';
        }
      }
    } else {
      return 'Date invalide';
    }
    return DateFormat('d MMMM yyyy', 'fr_FR').format(parsedDate);
  }

  bool _isWarrantyActive(dynamic endDate) {
    if (endDate == null) return false;
    DateTime parsedEndDate;
    if (endDate is DateTime) {
      parsedEndDate = endDate;
    } else if (endDate is String) {
      try {
        parsedEndDate = DateTime.parse(endDate);
      } catch (e) {
        try {
          final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
          parsedEndDate = inputFormat.parse(endDate);
        } catch (e) {
          return false;
        }
      }
    } else {
      return false;
    }
    final DateTime now = DateTime.now();
    return now.isBefore(parsedEndDate);
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) {
      Get.snackbar('Erreur', 'Lien du fichier non disponible.');
      return;
    }
    
    final result = await OpenFilex.open(url);

    if (result.type == ResultType.done) {
      return;
    } else {
      final Uri uri = Uri.parse(url);
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          return;
        }
      }
    }

    Get.snackbar('Erreur', 'Impossible d\'ouvrir le fichier.');
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Partager'),
                onTap: () {
                  Navigator.pop(context);
                  _shareWarranty();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => EditWarrantyPage(warranty: widget.warranty));
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_upload),
                title: const Text('Migration'),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => MigrateOrReceivePage(warranty: widget.warranty));
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Reporter'),
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar('Fonctionnalité', 'Le rapport de problème sera bientôt disponible.');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareWarranty() {
    final warranty = widget.warranty;
    String textToShare =
        'Détails de ma garantie:\n\n'
        'Produit: ${warranty.product?.productName ?? 'N/A'}\n'
        'Catégorie: ${warranty.product?.productCategory?.categoryName ?? 'N/A'}\n'
        'Date d\'achat: ${_formatDate(warranty.purchaseDate)}\n'
        'Date de début de garantie: ${_formatDate(warranty.startDate)}\n'
        'Date de fin de garantie: ${_formatDate(warranty.endDate)}\n'
        'Vendeur: ${warranty.sellerName}\n'
        'Type de garantie: ${warranty.warrantyType}\n'
        'Notes: ${warranty.notes ?? 'Aucune'}\n\n'
        'Géré avec l\'application de garantie.';
    Share.share(textToShare, subject: 'Ma garantie pour le produit: ${warranty.product?.productName}');
  }

  void _confirmDelete() {
    Get.defaultDialog(
      title: 'Confirmer la suppression',
      titleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      contentPadding: const EdgeInsets.all(20),
      radius: 10.0,
      content: const Text(
        'Êtes-vous sûr de vouloir supprimer cette garantie ? Cette action est irréversible.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            'Annuler',
            style: TextStyle(color: Color.fromARGB(255, 28, 27, 27)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final WarrantyController warrantyController = Get.find<WarrantyController>();
            warrantyController.deleteWarranty(widget.warranty.id!);
            Get.back();
            Get.back();
            Get.snackbar(
              'Succès',
              'La garantie a été supprimée avec succès.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Supprimer',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final warranty = widget.warranty;
    final String warrantyId = warranty.id!;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          warranty.product?.productName ?? 'Produit inconnu',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProductImage(warrantyId), // Modifié pour utiliser l'ID
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 199, 198, 198),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: const Color.fromARGB(255, 255, 255, 255),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 173, 172, 172).withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                labelColor: Colors.black87,
                unselectedLabelColor: const Color.fromARGB(255, 10, 10, 10),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                tabs: const [
                  Tab(text: 'Détails'),
                  Tab(text: 'Rappels'),
                ],
                dividerColor: Colors.transparent,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(warranty),
                RemindersTabContent(warrantyId: warranty.id!),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductImage(String warrantyId) {
    return Obx(() {
      final WarrantyModel? currentWarranty = _warrantyController.allWarranties.firstWhereOrNull((w) => w.id == warrantyId);
      final String productPhotoUrl = currentWarranty?.product?.productPhotoUrl ?? 'https://via.placeholder.com/400x200';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                productPhotoUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/not-found.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDetailsTab(WarrantyModel warranty) {
    final bool isActive = _isWarrantyActive(warranty.endDate);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusTag(isActive),
          const SizedBox(height: 16),
          _buildDetailSection(
            [
              _buildDetailRow('Nom', warranty.product?.productName),
              _buildDetailRow(
                'Date de début/fin de garantie',
                '${_formatDate(warranty.startDate)} - ${_formatDate(warranty.endDate)}',
              ),
              _buildDetailRow('Type de garantie', warranty.warrantyType),
              _buildDetailRow('Date d\'achat', _formatDate(warranty.purchaseDate)),
              _buildDetailRow('Vendeur', warranty.sellerName),
              _buildFileLink('Facture', warranty.invoiceFilePath),
              _buildFileLink('Certificat de garantie', warranty.certificateFilePath),
              _buildDetailRow('Note', warranty.notes),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(221, 40, 40, 40)),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'Non spécifié',
            style: const TextStyle(color: Color.fromARGB(255, 65, 65, 65)),
          ),
        ],
      ),
    );
  }

  Widget _buildFileLink(String label, String? url) {
    final bool hasUrl = url != null && url.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: hasUrl ? () => _launchUrl(url) : null,
            child: Text(
              hasUrl ? 'Voir le fichier' : 'Non disponible',
              style: TextStyle(
                color: hasUrl ? Colors.pink : Colors.grey,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none, 
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(bool isActive) {
    return Container(
      width: 100,
      height: 40,
      padding: const EdgeInsets.all(7.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFC8E6C9) : Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Expirée',
        style: TextStyle(
          color: isActive ? Colors.green.shade900 : Colors.red.shade900,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
    );
  }
}