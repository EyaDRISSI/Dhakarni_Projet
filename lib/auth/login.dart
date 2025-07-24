import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

import './sign-up/sign-up-partic.dart';
import './forgetPassword.dart';
import '../controller/user_controller.dart';
import '../pages/warranty/warranty-home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false; // Gère la visibilité du mot de passe.
  final _formKey = GlobalKey<FormState>(); 
  final TextEditingController _emailController = TextEditingController(); // Contrôleur pour le champ email.
  final TextEditingController _passwordController = TextEditingController(); // Contrôleur pour le champ mot de passe.

  bool _isLoading = false; // Indique si une opération de connexion est en cours.

  // Utilise Get.find pour récupérer l'instance du UserController,
  final UserController _userController = Get.find<UserController>();

  /// Effectue l'opération de connexion de l'utilisateur.
  void _performLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; 
      });

      try {
        log('DEBUG_TIME: Tentative de connexion pour ${_emailController.text.trim()}');
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        log('DEBUG_TIME: Connexion Firebase Auth réussie');

        if (userCredential.user != null) {
          log('DEBUG_TIME: Connexion réussie, récupération des détails utilisateur');
          await _userController.fetchCurrentUserDetails(userCredential.user!.uid);
          log('DEBUG_TIME: Détails utilisateur récupérés, navigation vers HomePage');
          Get.offAll(() => const WarrantyHomePage()); // Redirige vers la page d'accueil après une connexion réussie.
        }
      } on FirebaseAuthException catch (e) {
        log('DEBUG_TIME: Erreur Firebase Auth lors de la connexion: ${e.code} - ${e.message}');
        String errorMessage;
        Color snackBarColor = const Color(0xFFE91E63).withOpacity(0.8); 

        if (e.code == 'user-not-found') {
          errorMessage = 'Aucun utilisateur trouvé pour cet email.';
        } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          errorMessage = 'Mot de passe incorrect.';
          snackBarColor = const Color(0xFFE91E63).withOpacity(0.5); 
        } else if (e.code == 'invalid-email') {
          errorMessage = 'L\'adresse email est mal formatée.';
        } else if (e.code == 'too-many-requests') {
          errorMessage = 'Trop de tentatives de connexion échouées. Veuillez réessayer plus tard.';
        } else {
          errorMessage = 'Erreur de connexion : ${e.message}';
        }
        Get.snackbar(
          'Erreur de connexion',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBarColor, // Utilise la couleur déterminée.
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        print("Firebase Auth Error: ${e.code} - ${e.message}");
      } catch (e) {
        log('DEBUG_TIME: Erreur inattendue lors de la connexion: $e');
        Get.snackbar(
          'Erreur',
          'Une erreur inattendue est survenue : $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE91E63).withOpacity(0.8), 
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        print("Unexpected Error during login: $e");
      } finally {
        setState(() {
          _isLoading = false; // Désactive toujours l'indicateur de chargement.
        });
      }
    } else {
      Get.snackbar(
        'Erreur de validation',
        'Veuillez corriger les erreurs dans le formulaire.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8), 
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose(); // Libère les ressources du contrôleur d'email.
    _passwordController.dispose(); // Libère les ressources du contrôleur de mot de passe.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Obtient les dimensions de l'écran pour un design adaptatif.
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    const double figmaBaseWidth = 375;
    const double figmaBaseHeight = 812;

    final double widthScale = screenWidth / figmaBaseWidth;
    final double heightScale = screenHeight / figmaBaseHeight;

    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                // Fond dégradé
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Color.fromARGB(255, 250, 232, 239), 
                        ],
                      ),
                    ),
                  ),
                ),

                // Cercles Concentriques (élément de design)
                Positioned(
                  top: 190 * heightScale,
                  left: 40 * widthScale,
                  child: CustomPaint(
                    size: Size(364 * widthScale, 364 * heightScale),
                    painter: ConcentricCirclesPainter(opacity: 0.4),
                  ),
                ),

                Column(
                  children: [
                    // Zone supérieure avec image et logo
                    Container(
                      height: 421 * heightScale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 36 * heightScale,
                            left: (screenWidth - 319 * widthScale) / 2,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(200),
                                bottomRight: Radius.circular(200),
                              ),
                              child: Image.asset(
                                'assets/person_with_phone.png', 
                                width: 319 * widthScale,
                                height: 353 * heightScale,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20 * heightScale,
                            child: Image.asset(
                              'assets/dhakarni_logo.png',
                              height: 60 * heightScale,
                              width: 319 * widthScale * 0.7,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Formulaire de connexion
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: (screenWidth - 335 * widthScale) / 2,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 15 * heightScale),
                              Text(
                                'Email',
                                style: TextStyle(fontSize: 16 * widthScale),
                              ),
                              SizedBox(height: 8 * heightScale),
                              // Champ de saisie de l'email
                              TextFormField(
                                controller: _emailController,
                                decoration: _buildInputDecoration('Insérer votre email'),
                                validator: _validateEmail,
                              ),

                              SizedBox(height: 15 * heightScale),
                              Text(
                                'Mot de passe',
                                style: TextStyle(fontSize: 16 * widthScale),
                              ),
                              SizedBox(height: 8 * heightScale),
                              // Champ de saisie du mot de passe
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible, // Contrôle la visibilité du texte.
                                decoration: _buildInputDecoration(
                                  'Insérer un mot de passe',
                                  isPassword: true, // Indique que c'est un champ de mot de passe pour l'icône.
                                ),
                                validator: _validatePassword,
                              ),

                              SizedBox(height: 8 * heightScale),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Get.to(() => const ForgotPasswordPage()), // Navigue vers la page de mot de passe oublié.
                                  child: const Text(
                                    'Mot de passe oublié ?',
                                    style: TextStyle(color: Color(0xFFE91E63)), 
                                  ),
                                ),
                              ),

                              SizedBox(height: 10 * heightScale),
                              // Bouton de connexion
                              SizedBox(
                                width: double.infinity,
                                height: 49 * heightScale,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _performLogin, // Désactive le bouton si en chargement.
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE91E63), 
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20 * widthScale),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white), 
                                        )
                                      : Text(
                                          'Se connecter',
                                          style: TextStyle(fontSize: 18 * widthScale, color: const Color.fromARGB(255, 246, 238, 241)), 
                                        ),
                                ),
                              ),

                              SizedBox(height: 7 * heightScale),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Vous n'avez pas de compte?"),
                                  TextButton(
                                    onPressed: () => Get.to(() => const SignUpParticulierPage()), // Navigue vers la page d'inscription.
                                    child: const Text(
                                      'S\'inscrire',
                                      style: TextStyle(
                                        color: Color(0xFFE91E63), 
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText, {bool isPassword = false}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE91E63), width: 1.5),
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible; // Bascule la visibilité du mot de passe.
                });
              },
            )
          : null,
    );
  }

  /// Valide le format de l'email.
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email.';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Veuillez entrer un email valide.';
    }
    return null;
  }

  /// Valide la longueur du mot de passe.
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe.';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    return null;
  }
}


class ConcentricCirclesPainter extends CustomPainter {
  final double opacity;

  const ConcentricCirclesPainter({this.opacity = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final Paint paint = Paint()
      ..color = Colors.grey.shade300.withOpacity(opacity) // Couleur des cercles avec opacité.
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0; 

    canvas.drawCircle(center, size.width * 0.25, paint);
    canvas.drawCircle(center, size.width * 0.38, paint);
    canvas.drawCircle(center, size.width * 0.48, paint);
    canvas.drawCircle(center, size.width * 0.58, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is ConcentricCirclesPainter && oldDelegate.opacity != opacity;
  }
}