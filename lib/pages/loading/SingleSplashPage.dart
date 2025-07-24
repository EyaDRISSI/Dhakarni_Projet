import 'package:flutter/material.dart';
import '../../auth/login.dart'; 
/// Page d'introduction (Splash Screen) affichant des contenus défilants.
/// Utilise `SingleTickerProviderStateMixin` pour les animations.
class SingleSplashPage extends StatefulWidget {
  const SingleSplashPage({Key? key}) : super(key: key);

  @override
  State<SingleSplashPage> createState() => _SingleSplashPageState();
}

class _SingleSplashPageState extends State<SingleSplashPage>
    with SingleTickerProviderStateMixin {
  // Index du contenu actuel affiché dans le splash screen.
  int _currentIndex = 0;
  // Contrôleur d'animation pour gérer les transitions de fondu.
  late AnimationController _animationController;
  // Animation de type `double` pour l'opacité.
  late Animation<double> _animation;

  // Liste des contenus pour chaque écran du splash screen.
  final List<SplashScreenContent> _contents = [
    SplashScreenContent(
      imagePath: 'assets/Man-With-Phone.png',
      title: 'Ne manquez jamais une garantie!',
      description: 'Laissez-nous prendre soin de vos garanties.',
    ),
    SplashScreenContent(
      imagePath: 'assets/AppleIphone.png',
      title: 'Navigation Simplifiée',
      description:
          'Trouvez toutes vos informations facilement grâce à une interface intuitive.',
    ),
    SplashScreenContent(
      imagePath: 'assets/Notifchat.png',
      title: 'Restez Toujours Informé!',
      description:
          'Notre système de notification maximise vos garanties en restant toujours à jour.',
    ),
  ];

  // Durée de la transition entre les contenus.
  final Duration _transitionDuration = const Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    // Initialisation du contrôleur d'animation.
    _animationController = AnimationController(
      vsync: this,
      duration: _transitionDuration,
    );
    // Définition de l'animation de fondu avec une courbe d'accélération.
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Démarre l'animation de fondu pour le premier contenu.
    _animationController.forward();
  }

  /// Navigue vers la page de connexion, en remplaçant la pile de routes.
  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  /// Gère l'action du bouton "Passer".
  void _onNextPressed() {
    if (_currentIndex < _contents.length - 1) {
      // Si ce n'est pas le dernier écran, anime la sortie, puis change de contenu et anime l'entrée.
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _currentIndex++; // Passe à l'écran suivant.
          });
          _animationController.forward(); // Anime l'entrée du nouveau contenu.
        }
      });
    } else {
      // Si c'est le dernier écran, navigue vers la page de connexion.
      _navigateToLogin();
    }
  }

  @override
  void dispose() {
    // Libère les ressources du contrôleur d'animation lors de la suppression du widget.
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Dimensions de base du design Figma pour le calcul des échelles.
    const double figmaBaseWidth = 355;
    const double figmaBaseHeight = 812;

    // Calcul des facteurs d'échelle pour adapter les tailles aux différentes résolutions d'écran.
    final double widthScale = screenWidth / figmaBaseWidth;
    final double heightScale = screenHeight / figmaBaseHeight;

    // Contenu actuel à afficher basé sur l'index.
    SplashScreenContent currentContent = _contents[_currentIndex];

    String? backgroundImagePath = _currentIndex == 0 || _currentIndex == 1
        ? 'assets/Group26887.png'
        : null; 

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color.fromARGB(255, 252, 226, 236), 
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).padding.top + (20 * heightScale), 
              left: 20 * widthScale, 
              right: 20 * widthScale, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/dhakarni_logo.png',
                    height: 35 * heightScale,
                    fit: BoxFit.contain,
                  ),
                  TextButton(
                    onPressed: _onNextPressed,
                    child: Text(
                      'Passer',
                      style: TextStyle(
                        color: const Color(0xFFE91E63), 
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * widthScale, 
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.20), 
                child: FadeTransition(
                  opacity: _animation, 
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                  
                      Padding(
                        padding: EdgeInsets.only(bottom: 15.0 * heightScale), 
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_contents.length, (index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.0 * widthScale), 
                              width: _currentIndex == index ? 24.0 * widthScale : 8.0 * widthScale, 
                              height: 8.0 * heightScale, 
                              decoration: BoxDecoration(
                                color: _currentIndex == index
                                    ? const Color(0xFFE91E63) 
                                    : Colors.grey[300], 
                                borderRadius: BorderRadius.circular(4.0 * widthScale), 
                              ),
                            );
                          }),
                        ),
                      ),
                      Container(
                        width: screenWidth * 0.8, 
                        child: Column(
                          children: [
                            // Titre.
                            Text(
                              currentContent.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30 * widthScale,
                                color: const Color.fromARGB(255, 82, 82, 82),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12 * heightScale), 
                            Text(
                              currentContent.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16 * widthScale, 
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),

         
            Align(
              alignment: Alignment.bottomCenter,
              child: FadeTransition(
                opacity: _animation, 
                child: Container(
                  height: screenHeight * 0.55,
                  width: screenWidth, 
                  decoration: backgroundImagePath != null
                      ? BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(backgroundImagePath),
                            fit: BoxFit.cover, 
                          ),
                        )
                      : null, 
                  child: Image.asset(
                    currentContent.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            
            if (_currentIndex == 0) ...[
              
              Positioned(
                bottom: screenHeight * 0.25, 
                right: screenWidth * 0.03, 
                child: Container(
                  width: 140 * widthScale, 
                  height: 60 * heightScale, 
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/12-janv.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Deuxième image flottante.
              Positioned(
                bottom: screenHeight * 0.09, 
                left: screenWidth * 0.02, 
                child: Container(
                  width: 140 * widthScale, 
                  height: 60 * heightScale, 
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/22-avril.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SplashScreenContent {
  final String imagePath;     // Chemin de l'image à afficher.
  final String title;         // Titre de l'écran.
  final String description;   // Description de l'écran.

  SplashScreenContent({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}