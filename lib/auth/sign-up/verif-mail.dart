import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'package:dhakarni_1/controller/user_controller.dart';
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
  final UserController _userController = Get.find<UserController>();

  bool _isSendingEmail = false;

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
      sendVerificationEmail();
    }
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
            backgroundColor: Colors.blueAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 7),
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
                                'assets/email_sent.png',
                                width: 319 * widthScale,
                                height: 353 * heightScale,
                                fit: BoxFit.cover,
                              ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20 * heightScale),
                            Text(
                              'Vérifiez votre adresse e-mail',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24 * widthScale,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE91E63),
                              ),
                            ),
                            SizedBox(height: 20 * heightScale),
                            Text(
                              'Un e-mail de vérification a été envoyé à l\'adresse :',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16 * widthScale, color: Colors.grey[700]),
                            ),
                            Text(
                              _auth.currentUser?.email ?? 'votre e-mail',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18 * widthScale,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 20 * heightScale),
                            Text(
                              'Veuillez cliquer sur le lien de vérification dans cet e-mail pour activer votre compte. Vérifiez également votre dossier de spams.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16 * widthScale, color: Colors.grey[700]),
                            ),
                            SizedBox(height: 30 * heightScale),
                            ElevatedButton(
                              onPressed: _isSendingEmail ? null : sendVerificationEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE91E63),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20 * widthScale),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 30 * widthScale, vertical: 15 * heightScale),
                              ),
                              child: _isSendingEmail
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                'Renvoyer l\'email',
                                style: TextStyle(fontSize: 18 * widthScale, color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 10 * heightScale),
                            TextButton(
                              onPressed: () {
                                _auth.signOut();
                                Get.offAll(() => const LoginPage());
                              },
                              child: const Text(
                                'Se déconnecter et retourner à la connexion',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
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
}

