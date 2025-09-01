import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/user_controller.dart';
import '../../../controller/warranty_controller.dart';
import '../../../controller/notification_controller.dart';
import '../add-warranty/add_warranty_page.dart';
import '../../account/my-account.dart';
import 'dart:developer';
import '../warranty-details/warranty-details.dart';
import '../../Notification/notification_history.dart';

class WarrantyHomePage extends StatefulWidget {
  const WarrantyHomePage({super.key});

  @override
  State<WarrantyHomePage> createState() => _WarrantyHomePageState();
}

class _WarrantyHomePageState extends State<WarrantyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          backgroundColor: const Color(0xFFE91E63),
          elevation: 0,
        ),
      ),
      body: _getBodyWidget(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                label: 'Ajouter',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Mon compte',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFFE91E63),
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            onTap: (index) {
              if (index == 1) {
                Get.to(() => const AddWarrantyPage());
              } else {
                _onItemTapped(index);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _getBodyWidget(int index) {
    switch (index) {
      case 0:
        return const _WarrantyHomeContent();
      case 1:
        return const AddWarrantyPage();
      case 2:
        return const MyAccountPage();
      default:
        return const _WarrantyHomeContent();
    }
  }
}

class _WarrantyHomeContent extends StatefulWidget {
  const _WarrantyHomeContent({Key? key}) : super(key: key);

  @override
  _WarrantyHomeContentState createState() => _WarrantyHomeContentState();
}

class _WarrantyHomeContentState extends State<_WarrantyHomeContent> {
  late final WarrantyController warrantyController;
  late final UserController userController;
  late final NotificationController notificationController;
  
  

  @override
  void initState() {
    super.initState();
    warrantyController = Get.find<WarrantyController>();
    userController = Get.find<UserController>();
    notificationController = Get.find<NotificationController>();
    
    
  }

  @override
  void dispose() {
    
    super.dispose();
  }

  bool _isWarrantyActive(DateTime? endDate) {
    if (endDate == null) return false;
    final DateTime now = DateTime.now();
    return now.isBefore(endDate);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('d MMMM yyyy', 'fr_FR').format(date);
    } catch (e) {
      log('Erreur de formatage de la date: $e');
      return 'N/A';
    }
  }

  String _normalizeCategoryName(String name) {
    var withAccents = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÐðÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    var withoutAccents = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcDdIIIIiiiiUUUUuuuuNnSsYyyZz';
    for (int i = 0; i < withAccents.length; i++) {
      name = name.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return name.toLowerCase().trim();
  }

  IconData _getIconForSubCategory(String? subCategoryName) {
    if (subCategoryName == null || subCategoryName.isEmpty) {
      return Icons.category;
    }
    final normalizedName = _normalizeCategoryName(subCategoryName);
    switch (normalizedName) {
      case 'ordinateurs portables':
        return Icons.laptop;
      case 'ordinateurs de bureau':
        return Icons.desktop_windows;
      case 'imprimantes & scanners':
        return Icons.print;
      case 'disques durs & ssd':
        return Icons.storage;
      case 'ecrans':
        return Icons.monitor;
      case 'claviers & souris':
        return Icons.keyboard;
      case 'reseaux & routeurs':
        return Icons.router;
      case 'logiciels':
        return Icons.code;
      case 'refrigerateurs':
        return Icons.kitchen;
      case 'lave-linge':
        return Icons.local_laundry_service;
      case 'fours & micro-ondes':
        return Icons.microwave;
      case 'cuisinieres':
        return Icons.kitchen;
      case 'aspirateurs':
        return Icons.cleaning_services;
      case 'robots de cuisine':
        return Icons.blender;
      case 'chauffe-eau':
        return Icons.thermostat;
      case 'climatiseurs':
        return Icons.ac_unit;
      case 'televiseurs led/oled':
        return Icons.tv;
      case 'home cinema':
        return Icons.speaker;
      case 'appareils photo numeriques':
        return Icons.camera_alt;
      case 'cameras de surveillance':
        return Icons.videocam;
      case 'video projecteurs':
        return Icons.camera_indoor;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'casques audio':
        return Icons.headphones;
      case 'smartphones':
        return Icons.smartphone;
      case 'telephones fixes':
        return Icons.phone;
      case 'tablettes':
        return Icons.tablet_android;
      case 'accessoires de telephone':
        return Icons.phone_iphone;
      case 'cartes sim & recharge':
        return Icons.sim_card;
      case 'ecouteurs bluetooth':
        return Icons.headset_mic;
      case 'coques & housses':
        return Icons.cases;
      case 'chargeurs & cables':
        return Icons.electrical_services;
      case 'supports telephones / pc':
        return Icons.phonelink;
      case 'batteries externes':
        return Icons.battery_full;
      case 'cles usb':
        return Icons.usb;
      case 'accessoires gaming':
        return Icons.gamepad;
      case 'adaptateurs':
        return Icons.power;
      case 'voitures':
        return Icons.directions_car;
      case 'motos & scooters':
        return Icons.two_wheeler;
      case 'velos':
        return Icons.pedal_bike;
      case 'pieces detachees auto/moto':
        return Icons.handyman;
      case 'accessoires auto (gps, tapis, cameras)':
        return Icons.car_rental;
      case 'pneus & jantes':
        return Icons.tire_repair;
      case 'panneaux solaires':
        return Icons.solar_power;
      case 'batteries solaires':
        return Icons.battery_charging_full;
      case 'regulateurs de charge':
        return Icons.electrical_services;
      case 'onduleurs':
        return Icons.power;
      case 'lampes solaires':
        return Icons.lightbulb;
      case 'kits solaires portables':
        return Icons.power_settings_new;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
              left: 20.0, right: 20.0, bottom: 50.0, top: 30.0),
          decoration: const BoxDecoration(
            color: Color(0xFFE91E63),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    final user = userController.currentUser.value;
                    String greetingName = 'Cher client';
                    if (user != null) {
                      String firstName = user.prenom;
                      String lastName = user.nom ;
                      if (firstName.isNotEmpty) {
                        greetingName = firstName;
                        if (lastName.isNotEmpty) {
                          greetingName += ' ${lastName[0].toUpperCase()}.';
                        }
                      } else if (lastName.isNotEmpty) {
                        greetingName = lastName;
                      }
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bonjour,',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              greetingName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Transform.rotate(
                              angle: 0.8,
                              child: const Text(
                                '👋',
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const NotificationHistoryPage());
                        },
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      Obx(() {
                        if (notificationController.notificationCount.value > 0) {
                          return Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                notificationController.notificationCount.value.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  onChanged: (value) =>
                      warrantyController.searchTerm.value = value,
                  decoration: InputDecoration(
                    hintText: 'Recherche',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    icon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Obx(() {
            final percentage = userController.profileCompletionPercentage.value.toInt();
            final showProfileCompletionCard = percentage < 100;
            final displayedWarranties = warrantyController.filteredWarranties;
            if (warrantyController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (warrantyController.isLoading.value == false &&
                displayedWarranties.isEmpty &&
                warrantyController.searchTerm.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 30.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/Email sent.png',
                      width: 150,
                      height: 150,
                      opacity: const AlwaysStoppedAnimation(0.8),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Aucune garantie',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Ajoutez vos garanties pour commencer à profiter des notifications et des rappels.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => const AddWarrantyPage());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Ajouter Garantie',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (displayedWarranties.isEmpty && warrantyController.searchTerm.isNotEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Aucun résultat pour cette recherche.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showProfileCompletionCard)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade100,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/profile_completion_icon.png',
                              width: 50,
                              height: 50,
                              opacity: const AlwaysStoppedAnimation(0.8),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Compléter votre profil',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: Colors.grey.shade300,
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              '$percentage%',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mes garanties',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tous',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFE91E63),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedWarranties.length,
                    itemBuilder: (context, index) {
                      final warranty = displayedWarranties[index];
                      return _buildWarrantyCard(context, warranty);
                    },
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWarrantyCard(BuildContext context, warranty) {
    final String productName = warranty.product?.productName ?? 'Produit inconnu';
    final String subCategoryName =
        warranty.product?.productCategory?.subCategories.isNotEmpty == true
            ? warranty.product!.productCategory!.subCategories.first.categoryName
            : (warranty.product?.productCategory?.categoryName ??
                'Catégorie inconnue');
    final bool isActive = _isWarrantyActive(warranty.endDate);
    final String formattedStartDate = _formatDate(warranty.startDate);
    final String formattedEndDate = _formatDate(warranty.endDate);

    return InkWell(
      onTap: () {
        Get.to(() => WarrantyDetailsPage(warranty: warranty));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconForSubCategory(subCategoryName),
                    color: const Color(0xFFE91E63),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        subCategoryName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFC8E6C9) : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Expirée',
                    style: TextStyle(
                      color: isActive ? Colors.green.shade900 : Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 25, thickness: 0.5, color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date début',
                      style: TextStyle(fontSize: 13, color: Colors.grey.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedStartDate,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Date fin',
                      style: TextStyle(fontSize: 13, color: Colors.grey.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedEndDate,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}