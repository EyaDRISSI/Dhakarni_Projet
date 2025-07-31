import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../controller/user_controller.dart';
import '../../models/user_model.dart';
import './verif-mail.dart';


class SignUpParticulierPage extends StatefulWidget {
  const SignUpParticulierPage({Key? key}) : super(key: key);

  @override
  State<SignUpParticulierPage> createState() => _SignUpParticulierPageState();
}

enum SignUpStep { nameInput, securitySetup }

class _SignUpParticulierPageState extends State<SignUpParticulierPage> {
  SignUpStep _currentStep = SignUpStep.nameInput;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =TextEditingController();
  

  final GlobalKey<FormState> _nameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _securityFormKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSigningUp = false;

  bool _hasMinLength = false;
  bool _hasUpperCaseAndLowerCase =false;
  bool _hasSpecialCharacter = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserController _userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    setState(() {
      final password = _passwordController.text;
      _hasMinLength = password.length >= 8;
      _hasUpperCaseAndLowerCase = password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[a-z]'));
      _hasSpecialCharacter =
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  void _nextStep() async {
    setState(() {
      if (_currentStep == SignUpStep.nameInput) {
        if (_nameFormKey.currentState!.validate()) {
          _currentStep = SignUpStep.securitySetup;
        }
      } else if (_currentStep == SignUpStep.securitySetup) {
        if (_securityFormKey.currentState!.validate()) {
          _performSignUp();
        }
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep == SignUpStep.securitySetup) {
        _currentStep = SignUpStep.nameInput;
      }
    });
  }

  int _getStepIndex(SignUpStep step) {
    switch (step) {
      case SignUpStep.nameInput:
        return 0;
      case SignUpStep.securitySetup:
        return 1;
      default:
        return 0;
    }
  }

  void _performSignUp() async {
    if (_isSigningUp) return;

    setState(() {
      _isSigningUp = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user == null) {
        throw Exception("L'utilisateur Firebase n'a pas été créé.");
      }

      String fullName = _fullNameController.text.trim();
      List<String> nameParts = fullName.split(' ');
      String prenom = nameParts.isNotEmpty ? nameParts.first : '';
      String nom = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      UserModel newUser = UserModel(
        userId: userCredential.user!.uid,
        email: userCredential.user!.email!,
        prenom: prenom,
        nom: nom,
        status: 'Particulier',
        address: null,
        mobileNumber: null,
        registrationDate: null,
        birthDate: null,
        website: null,
      );

      await _userController.saveUserData(newUser);
      
      Get.offAll(() => const EmailVerificationPage());
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erreur d\'inscription.';
      if (e.code == 'weak-password') {
        errorMessage = 'Le mot de passe fourni est trop faible.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Le compte existe déjà pour cet email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'L\'adresse e-mail n\'est pas valide.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Erreur réseau. Veuillez vérifier votre connexion internet.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      print('Erreur d\'authentification Firebase lors de l\'inscription : ${e.code} - ${e.message}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur inattendue est survenue: ${e.toString()}')),
      );
      print('Erreur inattendue lors de l\'inscription : $e');
    } finally {
      setState(() {
        _isSigningUp = false;
      });
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case SignUpStep.nameInput:
        return _buildNameInputForm();
      case SignUpStep.securitySetup:
        return _buildSecuritySetupForm();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNameInputForm() {
    return Form(
      key: _nameFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          const Text(
            'Tout Commence Par le Nom',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tout d\'abord, dites-nous comment vous voulez être appelé(e).',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          const Text(
            'Votre nom complet',
            style: TextStyle(
                fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              hintText: 'ex: Foulen ben Foulen',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFE91E63), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom complet.';
              }
              if (value.trim().split(' ').length < 2) {
                return 'Veuillez entrer votre nom et prénom.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySetupForm() {
    return Form(
      key: _securityFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Sécurisez Votre Compte',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Maintenant, mettons en place les détails de connexion de votre compte.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          const Text(
            'Email',
            style: TextStyle(
                fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Insérer votre email',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFE91E63), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email.';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Veuillez entrer un email valide.';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          const Text(
            'Mot de passe',
            style: TextStyle(
                fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 9),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Insérer un mot de passe',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFE91E63), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre mot de passe.';
              }
              if (!_hasMinLength ||
                  !_hasUpperCaseAndLowerCase ||
                  !_hasSpecialCharacter) {
                return 'Le mot de passe ne respecte pas les critères.';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          const Text(
            'Confirmer mot de passe',
            style: TextStyle(
                fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Répéter le mot de passe',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFE91E63), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible =
                        !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez confirmer votre mot de passe.';
              }
              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas.';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          _buildPasswordRequirement('Au moins 8 caractères.', _hasMinLength),
          _buildPasswordRequirement(
              'Contient au moins une majuscule et minuscule.',
              _hasUpperCaseAndLowerCase),
          _buildPasswordRequirement(
              'Contient au moins un caractère spécial.', _hasSpecialCharacter),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_off,
            color: isValid ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: isValid ? Colors.black87 : Colors.grey,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    bool isButtonEnabled = true;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep == SignUpStep.nameInput
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  _previousStep();
                },
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SignUpProgressIndicator(
              currentStep: _getStepIndex(_currentStep),
              totalSteps: 2,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildStepContent(),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (isButtonEnabled && !_isSigningUp)
                      ? _nextStep
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(25)),
                    elevation: 0,
                    disabledBackgroundColor:
                        const Color(0xFFE91E63).withOpacity(0.5),
                  ),
                  child: _isSigningUp
                      ? const CircularProgressIndicator(
                            color: Colors.white)
                      : const Text(
                            'Continuer',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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

class SignUpProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const SignUpProgressIndicator({
    Key? key,
    required this.currentStep,
    this.totalSteps = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(totalSteps, (index) {
          bool isActive = index <=
              currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(
                  right: index == totalSteps - 1
                      ? 0
                      : 8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFE91E63)
                    : Colors.grey[
                        300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}