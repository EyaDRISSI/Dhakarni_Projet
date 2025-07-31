import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer'; 

import 'package:dhakarni_1/auth/login.dart'; 
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>(); 
  final TextEditingController _emailController = TextEditingController(); 
  bool _isLoading = false; 

  // envoyer un email de réinitialisation de mot de passe.
  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; 
      });

      try {
        log('DEBUG_TIME: Tentative de réinitialisation du mot de passe pour ${_emailController.text.trim()}');
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );
        log('DEBUG_TIME: Email de réinitialisation de mot de passe envoyé avec succès');

        Get.snackbar(
          'Email envoyé',
          'Un lien de réinitialisation de mot de passe a été envoyé à votre adresse email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green, 
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        // Retourne automatiquement à la page de connexion après 3 secondes.
        Future.delayed(const Duration(seconds: 3), () {
          Get.offAll(() => const LoginPage()); 
        });
      } on FirebaseAuthException catch (e) {
        log('DEBUG_TIME: Erreur Firebase Auth lors de la réinitialisation du mot de passe: ${e.code} - ${e.message}');
        String errorMessage;
        Color snackBarColor = Colors.red;

        if (e.code == 'user-not-found') {
          errorMessage = 'Aucun utilisateur trouvé pour cet email.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'L\'adresse email est mal formatée.';
        } else if (e.code == 'network-request-failed') {
          errorMessage = 'Problème de connexion réseau. Veuillez vérifier votre connexion.';
        } else if (e.code == 'too-many-requests') {
          errorMessage = 'Trop de tentatives. Veuillez réessayer plus tard.';
        } else {
          errorMessage = 'Erreur de réinitialisation : ${e.message}';
        }

        Get.snackbar(
          'Erreur',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBarColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        print("Firebase Auth Error: ${e.code} - ${e.message}");
      } catch (e) {
        log('DEBUG_TIME: Erreur inattendue lors de la réinitialisation du mot de passe: $e');
        Get.snackbar(
          'Erreur',
          'Une erreur inattendue est survenue : $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        print("Unexpected Error during password reset: $e");
      } finally {
        setState(() {
          _isLoading = false; 
        });
      }
    } else {
      Get.snackbar(
        'Erreur de validation',
        'Veuillez entrer une adresse email valide.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose(); 
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
                                'Réinitialiser votre mot de passe',
                                style: TextStyle(
                                  fontSize: 22 * widthScale,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE91E63),
                                ),
                              ),
                              SizedBox(height: 10 * heightScale),
                              Text(
                                'Veuillez entrer l\'adresse e-mail associée à votre compte. Un lien de réinitialisation vous sera envoyé.',
                                style: TextStyle(fontSize: 16 * widthScale, color: Colors.grey[700]),
                              ),
                              SizedBox(height: 20 * heightScale),
                              Text(
                                'Email',
                                style: TextStyle(fontSize: 16 * widthScale),
                              ),
                              SizedBox(height: 8 * heightScale),

                              TextFormField(
                                controller: _emailController,
                                decoration: _buildInputDecoration('Insérer votre email'),
                                validator: _validateEmail,
                              ),

                              SizedBox(height: 30 * heightScale),

                              SizedBox(
                                width: double.infinity,
                                height: 49 * heightScale,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _resetPassword,
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
                                          'Envoyer le lien de réinitialisation',
                                          style: TextStyle(fontSize: 18 * widthScale, color: Colors.white),
                                        ),
                                ),
                              ),

                              SizedBox(height: 10 * heightScale),

                              Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () => Get.back(), 
                                  child: const Text(
                                    'Retour à la connexion',
                                    style: TextStyle(
                                      color: Color(0xFFE91E63),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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

 
  InputDecoration _buildInputDecoration(String hintText) {
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
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email.';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Veuillez entrer un email valide.';
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
      ..color = Colors.grey.shade300.withOpacity(opacity)
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