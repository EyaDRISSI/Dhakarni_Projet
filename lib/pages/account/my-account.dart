import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../controller/user_controller.dart'; 
import '../../controller/notification_controller.dart'; 
import '../Notification/notification_history.dart'; 

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final NotificationController _notificationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _notificationController = Get.find<NotificationController>();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            padding: EdgeInsets.fromLTRB(20.0, MediaQuery.of(context).padding.top + 60.0, 20.0, 20.0),
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
                        if (user.prenom != null && user.prenom.isNotEmpty) {
                          greetingName = user.prenom;
                          if (user.nom != null && user.nom.isNotEmpty) {
                            greetingName += ' ${user.nom[0].toUpperCase()}.';
                          }
                        } else if (user.nom != null && user.nom.isNotEmpty) {
                          greetingName = user.nom;
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
                                  style: TextStyle(fontSize: 28),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                    Obx(() {
                      return Stack(
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
                          if (_notificationController.notificationCount > 0)
                            Positioned(
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
                                  _notificationController.notificationCount.toString(), 
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 8,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Obx(() {
              final percentage = userController.profileCompletionPercentage.value.toInt();
              if (percentage < 100) { 
                return Container(
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
                );
              } else {
                return const SizedBox.shrink(); 
              }
            }),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 50, 
              decoration: BoxDecoration(
                color: Colors.grey.shade200, 
                borderRadius: BorderRadius.circular(30.0), 
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0), 
                  color: Colors.white, 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                labelColor: Colors.black87, 
                unselectedLabelColor: Colors.grey, 
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                tabs: const [
                  Tab(text: 'Mon Profil'),
                  Tab(text: 'Configuration'),
                ],
                dividerColor: Colors.transparent,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMonProfilTab(userController),
                _buildConfigurationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonProfilTab(UserController userController) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Obx(() {
        final user = userController.currentUser.value;
        String fullNameValue = '';
        if (user != null) {
          if (user.prenom != null && user.prenom.isNotEmpty) {
            fullNameValue += user.prenom;
          }
          if (user.nom != null && user.nom.isNotEmpty) {
            if (fullNameValue.isNotEmpty) {
              fullNameValue += ' ';
            }
            fullNameValue += user.nom;
          }
        }
        if (fullNameValue.isEmpty) {
          fullNameValue = 'Non spécifié';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileListItem(
              label: 'Nom complet',
              value: fullNameValue,
            ),
            _buildProfileListItem(
              label: 'Email',
              value: user?.email ?? 'Non spécifié',
            ),
            _buildProfileListItem(
              label: 'Mot de passe',
              value: '********',
              isPassword: true,
            ),
            const SizedBox(height: 20),
            _buildProfileListItem(
              label: 'Status',
              value: user?.status ?? 'Particulier',
            ),
            _buildProfileListItem(
              label: 'Date de naissance',
              value: user?.birthDate ?? '--',
            ),
            _buildProfileListItem(
              label: 'Mobile',
              value: user?.mobileNumber ?? '--',
            ),
            _buildProfileListItem(
              label: 'Adresse',
              value: user?.address ?? '--',
            ),
            const SizedBox(height: 20),
            _buildProfileListItem(
              label: 'Site web',
              value: user?.website ?? '--',
            ),
            _buildSocialMediaLinks(),
          ],
        );
      }),
    );
  }

  Widget _buildProfileListItem({
    required String label,
    required String value,
    bool isPassword = false,
    VoidCallback? onTap, 
  }) {
    return InkWell( 
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( 
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isPassword)
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
            const Divider(height: 15, thickness: 0.5),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Réseaux sociaux',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start, 
          children: [
            _buildSocialMediaIcon(FontAwesomeIcons.facebook, 'Facebook'), 
            const SizedBox(width: 25), 
            _buildSocialMediaIcon(FontAwesomeIcons.whatsapp, 'WhatsApp'),
            const SizedBox(width: 25),
            _buildSocialMediaIcon(FontAwesomeIcons.instagram, 'Instagram'),
          ],
        ),
      ],
    );
  }

  
  Widget _buildSocialMediaIcon(IconData icon, String tooltip) {
    return GestureDetector(
      onTap: () {
        print('$tooltip icon tapped!');
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 24,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConfigurationSection(
            title: 'Notifications',
            children: [
              _buildToggleSetting(label: 'Frequence des notifications', initialValue: true),
              _buildDropdownSetting(label: 'Sélectionnez la sonnerie', value: 'Aucun', options: ['Aucun', 'Sonnerie 1', 'Sonnerie 2']),
            ],
          ),
          const SizedBox(height: 20),
          _buildConfigurationSection(
            title: 'Autres',
            children: [
              _buildSimpleSetting(label: 'Reporter un problème'),
              _buildSimpleSetting(label: 'Politique de confidentialité'),
              _buildSimpleSetting(label: 'À propos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        ...children.map((child) => Padding( 
          padding: const EdgeInsets.symmetric(vertical: 4.0), 
          child: child,
        )).toList(),
      ],
    );
  }

  Widget _buildToggleSetting({required String label, required bool initialValue}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            Switch(
              value: initialValue,
              onChanged: (bool value) {
                print('$label changed to $value');
              },
              activeColor: const Color(0xFFE91E63),
            ),
          ],
        ),
        const Divider(height: 15, thickness: 0.5), 
      ],
    );
  }

  Widget _buildDropdownSetting({
    required String label,
    required String value,
    required List<String> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        const Divider(height: 15, thickness: 0.5),
      ],
    );
  }

  Widget _buildSimpleSetting({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        const Divider(height: 15, thickness: 0.5),
      ],
    );
  }
}