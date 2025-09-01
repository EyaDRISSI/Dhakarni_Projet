import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:developer';
import '../login.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isEmailVerified = false;
  Timer? timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSendingEmail = false;

  @override
  void initState() {
    super.initState();
    //  sendVerificationEmail(); 
    timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
  }

  Future<void> sendVerificationEmail() async {
    if (_isSendingEmail) return;

    setState(() {
      _isSendingEmail = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        if (!user.emailVerified) {
          log('DEBUG_TIME: Envoi de l\'email de vérification à ${user.email}');
          await user.sendEmailVerification();
          Get.snackbar(
            'Email de vérification envoyé',
            'Veuillez vérifier votre boîte de réception (et vos spams) pour le lien de vérification. Si vous ne le voyez pas, essayez de le renvoyer après quelques instants.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Color(0xFFE91E63),
            colorText: Colors.white,
            duration: const Duration(seconds: 9),
          );
        } else {
          log('DEBUG_TIME: Email for ${user.email} is already verified.');
          Get.snackbar(
            'E-mail déjà vérifié',
            'Votre adresse e-mail est déjà vérifiée. Vous pouvez vous connecter.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.offAll(() => const LoginPage());
        }
      } else {
        log('DEBUG_TIME: Aucun utilisateur connecté pour envoyer l\'email de vérification.');
        Get.snackbar(
          'Erreur',
          'Aucun utilisateur n\'est actuellement connecté. Veuillez vous connecter ou vous inscrire d\'abord.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on FirebaseAuthException catch (e) {
      log('DEBUG_TIME: Erreur lors de l\'envoi de l\'email de vérification: ${e.code} - ${e.message}');
      String errorMessage;
      if (e.code == 'too-many-requests') {
        errorMessage = 'Vous avez envoyé trop de demandes. Veuillez réessayer après un court instant.';
      } else {
        errorMessage = 'Impossible d\'envoyer l\'email de vérification: ${e.message}';
      }
      Get.snackbar(
        'Erreur d\'envoi d\'email',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      log('DEBUG_TIME: Erreur inattendue lors de l\'envoi de l\'email de vérification: $e');
      Get.snackbar(
        'Erreur',
        'Une erreur inattendue est survenue lors de l\'envoi de l\'email.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _isSendingEmail = false;
          });
        }
      });
    }
  }

  Future<void> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    setState(() {
      isEmailVerified = _auth.currentUser?.emailVerified ?? false;
    });

    if (isEmailVerified) {
      timer?.cancel();
      log('DEBUG_TIME: Email vérifié, redirection vers LoginPage.');
      Get.offAll(() => const LoginPage());
    } else {
      log('DEBUG_TIME: Email not yet verified for user: ${_auth.currentUser?.email}');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 50 * heightScale),
                      SizedBox(
                        width: 250 * widthScale,
                        height: 250 * heightScale,
                        child: Image.asset(
                          'assets/email_sent.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 50 * heightScale),
                      Text(
                        'Vérifiez Votre E-mail !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28 * widthScale,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 80, 76, 77),
                        ),
                      ),
                      SizedBox(height: 20 * heightScale),
                      Text(
                        'Veuillez vérifier votre boîte de réception pour un e-mail de vérification.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16 * widthScale,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSendingEmail ? null : sendVerificationEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: const Color(0xFFE91E63).withOpacity(0.5),
                  ),
                  child: _isSendingEmail
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Vérifier mon e-mail',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}