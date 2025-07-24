import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/user_controller.dart'; 
import 'create-warranty.dart'; 
import '../my-account.dart';   

class WarrantyHomePage extends StatefulWidget {
  const WarrantyHomePage({super.key});

  @override
  State<WarrantyHomePage> createState() => _WarrantyHomePageState();
}

class _WarrantyHomePageState extends State<WarrantyHomePage> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const _WarrantyHomeContent(), // Une classe interne pour le contenu de la page d'accueil
    const AddWarrantyPage(),      // Page pour ajouter une garantie
    const MyAccountPage(),        // Page de mon compte
  ];

  /// Met à jour l'index sélectionné et navigue vers la page correspondante.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false, // Supprime le bouton retour par défaut.
      ),
      body: _widgetOptions.elementAt(_selectedIndex),

      // Barre de navigation inférieure.
      bottomNavigationBar: BottomNavigationBar(
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
        currentIndex: _selectedIndex, // L'élément sélectionné est mis à jour dynamiquement.
        selectedItemColor: const Color(0xFFE91E63), 
        unselectedItemColor: Colors.grey, 
        onTap: _onItemTapped,
      ),
    );
  }
}

class _WarrantyHomeContent extends StatelessWidget {
  const _WarrantyHomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Column(
      children: [
        // Section supérieure avec salutation, nom et barre de recherche (fond rose).
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 60.0), 
          decoration: const BoxDecoration(
            color: Color(0xFFE91E63),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    final user = userController.currentUser.value;
                    String greetingName = 'Cher client'; // Salutation par défaut.
                    if (user != null) {
                      if (user.prenom.isNotEmpty) {
                        greetingName = user.prenom;
                        if (user.nom.isNotEmpty) {
                          greetingName += ' ${user.nom}'; // Affiche le nom de famille complet.
                        }
                      } else if (user.nom.isNotEmpty) {
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
                        Text(
                          greetingName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, 
                          ),
                        ),
                      ],
                    );
                  }),
                  const Icon(
                    Icons.person, 
                    color: Colors.white, 
                    size: 30,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Barre de recherche.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), 
                  borderRadius: BorderRadius.circular(25), 
                ),
                child: TextField(
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

       
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0), 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/Email sent.png', // Image pour le visuel "pas de garantie".
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

                // Bouton "Ajouter Garantie".
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigue vers la page d'ajout de garantie lors du clic.
                      Get.to(() => const ());
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
          ),
        ),
      ],
    );
  }
}