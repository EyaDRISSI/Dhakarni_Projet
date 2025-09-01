import 'package:flutter/material.dart';
import '../auth/login.dart'; 



class SingleSplashPage extends StatefulWidget {
  const SingleSplashPage({Key? key}) : super(key: key);

  @override
  State<SingleSplashPage> createState() => _SingleSplashPageState();
}


class _SingleSplashPageState extends State<SingleSplashPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _animation;

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

  final Duration _transitionDuration = const Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _transitionDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  void _onNextPressed() {
    if (_currentIndex < _contents.length - 1) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _currentIndex++; 
          });
          _animationController.forward(); 
        }
      });
    } else {
      _navigateToLogin();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    const double figmaBaseWidth = 355;
    const double figmaBaseHeight = 812;

    final double widthScale = screenWidth / figmaBaseWidth;
    final double heightScale = screenHeight / figmaBaseHeight;

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
                  height: screenHeight * 0.50,
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
  final String imagePath;
  final String title;        
  final String description; 

  SplashScreenContent({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}