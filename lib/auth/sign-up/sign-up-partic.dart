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

/// Enumération pour définir les types de compte possibles (Particulier ou Entreprise).
enum AccountType { individual, company }

/// Enumération pour gérer les différentes étapes du processus d'inscription.
enum SignUpStep { accountType, nameInput, securitySetup }

/// État interne de la page `SignUpParticulierPage`.
class _SignUpParticulierPageState extends State<SignUpParticulierPage> {
  // Variable pour stocker le type de compte sélectionné par l'utilisateur.
  AccountType? _selectedAccountType;
  // Variable pour suivre l'étape actuelle du processus d'inscription.
  SignUpStep _currentStep = SignUpStep.accountType;

  // Contrôleurs de texte pour récupérer les valeurs des champs de saisie.
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =TextEditingController();
 

  // Clés globales pour la validation des formulaires.
  // Permettent d'accéder à l'état du formulaire et d'appeler la méthode `validate()`.
  final GlobalKey<FormState> _nameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _securityFormKey = GlobalKey<FormState>();

  // Variables d'état pour gérer la visibilité des mots de passe.
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  // Variable pour indiquer si une inscription est en cours.
  bool _isSigningUp = false;

  // pour valider les critères du mot de passe en temps réel.
  bool _hasMinLength = false; // Longueur minimale (8 caractères).
  bool _hasUpperCaseAndLowerCase =false; // Majuscules et minuscules.
  bool _hasSpecialCharacter = false; // Caractère spécial.

  // Instance de Firebase Authentication pour gérer l'authentification des utilisateurs.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Instance du UserController injectée via GetX pour gérer les opérations utilisateur.
  final UserController _userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    // Ajoute un écouteur au contrôleur du mot de passe pour valider le mot de passe en temps réel.
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    // Libère les ressources des contrôleurs de texte pour éviter les fuites de mémoire.
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Valide le mot de passe saisi par l'utilisateur en fonction de critères prédéfinis.
  /// Met à jour les drapeaux `_hasMinLength`, `_hasUpperCaseAndLowerCase`, `_hasSpecialCharacter`.
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

  /// Passe à l'étape suivante du processus d'inscription.
  /// Gère la logique de validation avant de passer à l'étape suivante.
  void _nextStep() async {
    setState(() {
      if (_currentStep == SignUpStep.accountType) {
        if (_selectedAccountType != null) {
          if (_selectedAccountType == AccountType.company) {
            // Affiche un SnackBar si le type de compte "Entreprise" est sélectionné
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'La page d\'inscription pour les entreprises est en cours de développement.')),
            );
            return; 
          }
          _currentStep = SignUpStep.nameInput; // Passe à l'étape de saisie du nom.
        } else {
          // Affiche un SnackBar si aucun type de compte n'est sélectionné.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez sélectionner un type de compte.')),
          );
        }
      } else if (_currentStep == SignUpStep.nameInput) {
        // Valide le formulaire de saisie du nom.
        if (_nameFormKey.currentState!.validate()) {
          _currentStep =
              SignUpStep.securitySetup; // Passe à l'étape de sécurité.
        }
      } else if (_currentStep == SignUpStep.securitySetup) {
        // Valide le formulaire de configuration de la sécurité et lance l'inscription.
        if (_securityFormKey.currentState!.validate()) {
          _performSignUp(); // Déclenche la logique d'inscription.
        }
      }
    });
  }

  /// Revient à l'étape précédente du processus d'inscription.
  void _previousStep() {
    setState(() {
      if (_currentStep == SignUpStep.securitySetup) {
        _currentStep = SignUpStep.nameInput; // Revient à l'étape de saisie du nom.
      } else if (_currentStep == SignUpStep.nameInput) {
        _currentStep =
            SignUpStep.accountType; // Revient à l'étape de sélection du type de compte.
      }
    });
  }

  /// Retourne l'index numérique de l'étape d'inscription actuelle.
  /// Utilisé pour l'indicateur de progression.
  int _getStepIndex(SignUpStep step) {
    switch (step) {
      case SignUpStep.accountType:
        return 0;
      case SignUpStep.nameInput:
        return 1;
      case SignUpStep.securitySetup:
        return 2;
      default:
        return 0;
    }
  }

  
  /// Crée l'utilisateur dans Firebase Authentication et sauvegarde ses données dans Firebase Realtime Database.
  void _performSignUp() async {
    if (_isSigningUp) return; // Empêche les tentatives d'inscription multiples.

    setState(() {
      _isSigningUp = true; // Définit l'état d'inscription sur vrai.
    });

    try {
      // 1. Crée l'utilisateur dans Firebase Authentication avec l'email et le mot de passe.
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Vérifie si l'utilisateur Firebase a été créé.
      if (userCredential.user == null) {
        throw Exception("L'utilisateur Firebase n'a pas été créé.");
      }

      // Divise le nom complet en prénom et nom.
      String fullName = _fullNameController.text.trim();
      List<String> nameParts = fullName.split(' ');
      String prenom = nameParts.isNotEmpty ? nameParts.first : '';
      String nom = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Crée une instance du UserModel avec les données collectées.
      // L'adresse et le numéro de mobile sont mis à null car ils ne sont pas collectés dans ce formulaire.
      UserModel newUser = UserModel(
        userId: userCredential.user!.uid,
        email: userCredential.user!.email!,
        prenom: prenom,
        nom: nom,
        status: _selectedAccountType == AccountType.individual
            ? 'Particulier'
            : 'Entreprise',
        address: null, // Non collecté dans ce formulaire
        mobileNumber: null, // Non collecté dans ce formulaire
        registrationDate: null, // La date d'inscription est définie par le serveur
        birthDate: null, // Non collecté dans ce formulaire
        website: null, // Non collecté dans ce formulaire
      );

      // Sauvegarde les données de l'utilisateur dans la base de données Realtime via le UserController.
      await _userController.saveUserData(newUser);
      // Navigue vers la page de vérification d'email et supprime toutes les routes précédentes.
      Get.offAll(() => const EmailVerificationPage());
      // Affiche un message de succès (peut être un SnackBar ou une autre notification).
    } on FirebaseAuthException catch (e) {
      // Gère les erreurs spécifiques de Firebase Authentication.
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
      // Affiche un SnackBar avec le message d'erreur.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      // Affiche l'erreur dans la console pour le débogage.
      print('Erreur d\'authentification Firebase lors de l\'inscription : ${e.code} - ${e.message}');
    } catch (e) {
      // Gère toute autre erreur inattendue.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur inattendue est survenue: ${e.toString()}')),
      );
      // Affiche l'erreur dans la console pour le débogage.
      print('Erreur inattendue lors de l\'inscription : $e');
    } finally {
      setState(() {
        _isSigningUp = false; 
      });
    }
  }

  /// Construit le contenu du widget en fonction de l'étape d'inscription actuelle.
  Widget _buildStepContent() {
    switch (_currentStep) {
      case SignUpStep.accountType:
        return _buildAccountTypeSelection(); // Contenu pour la sélection du type de compte.
      case SignUpStep.nameInput:
        return _buildNameInputForm(); // Contenu pour la saisie du nom.
      case SignUpStep.securitySetup:
        return _buildSecuritySetupForm(); // Contenu pour la configuration de la sécurité.
      default:
        return const SizedBox.shrink(); 
    }
  }

  /// Construit une carte pour la sélection du type de compte (Particulier ou Entreprise).
  Widget _buildAccountTypeCard({
    required String iconPath,
    required String label,
    required String description,
    required AccountType accountType,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAccountType = accountType; // Met à jour le type de compte sélectionné.
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Image.asset(
                    iconPath,
                    height: 60,
                    width: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                if (isSelected)
                  // Indicateur de coche lorsque la carte est sélectionnée.
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1, 
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2, 
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  ///  l'interface utilisateur pour la sélection du type de compte.
  Widget _buildAccountTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        const Text(
          'Préparons votre compte ensemble !',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE91E63),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Avant de commencer, pouvez-vous nous dire si vous êtes une personne ou une entreprise ?',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Flexible(
              flex: 1,
              child: _buildAccountTypeCard(
                iconPath: 'assets/man.png', 
                label: 'Particulier',
                description: 'Pour votre usage personnel',
                accountType: AccountType.individual,
                isSelected: _selectedAccountType == AccountType.individual,
              ),
            ),
            const SizedBox(width: 16), 
            const Column(
              children: [
                SizedBox(height: 50), 
                Text(
                  'Ou',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(width: 16), 
            Flexible(
              flex: 1,
              child: _buildAccountTypeCard(
                iconPath: 'assets/building1.png', 
                label: 'Entreprise',
                description: 'Pour votre usage professionnel',
                accountType: AccountType.company,
                isSelected: _selectedAccountType == AccountType.company,
              ),
            ),
          ],
        ),
      ],
    );
  }

  ///  l'interface utilisateur pour la saisie du nom complet.
  Widget _buildNameInputForm() {
    return Form(
      key: _nameFormKey, // Associe la clé globale pour la validation du formulaire.
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
            controller: _fullNameController, // Contrôleur pour le champ du nom complet.
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
              // Valide que le nom complet contient au moins deux parties (prénom et nom).
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

  ///  l'interface utilisateur pour la configuration de l'email et du mot de passe.
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
            controller: _emailController, // Contrôleur pour le champ email.
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
              // Utilise GetX pour valider le format de l'email.
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
            controller: _passwordController, // Contrôleur pour le champ mot de passe.
            obscureText: !_isPasswordVisible, // Active/désactive la visibilité du mot de passe.
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
                    _isPasswordVisible = !_isPasswordVisible; // Inverse la visibilité.
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre mot de passe.';
              }
              // Valide le mot de passe par rapport aux critères.
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
            controller: _confirmPasswordController, // Contrôleur pour le champ de confirmation.
            obscureText:
                !_isConfirmPasswordVisible, 
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
              // Vérifie si les mots de passe correspondent.
              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas.';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          // Indicateurs des exigences de mot de passe.
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

  /// Widget d'aide pour afficher une exigence de mot de passe avec une coche.
  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_off, // Icône de coche si valide, sinon cercle vide.
            color: isValid ? Colors.green : Colors.grey, // Couleur verte si valide, sinon grise.
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
    // Définit le style de la barre de statut système (couleur, icônes).
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent, // Rendre la barre de statut transparente.
        statusBarIconBrightness: Brightness.dark, // Icônes de la barre de statut sombres.
      ),
    );

    // Détermine si le bouton "Continuer" doit être activé.
    bool isButtonEnabled = false;
    if (_currentStep == SignUpStep.accountType) {
      isButtonEnabled = _selectedAccountType != null; // Activé si un type de compte est sélectionné.
    } else if (_currentStep == SignUpStep.nameInput) {
      isButtonEnabled =
          true; // Le bouton est activé pour la navigation, la validation est faite dans _nextStep.
    } else if (_currentStep == SignUpStep.securitySetup) {
      isButtonEnabled =
          true; // Le bouton est activé pour la navigation, la validation est faite dans _nextStep.
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, 
        leading: _currentStep != SignUpStep.accountType
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  _previousStep(); // Navigue vers l'étape précédente.
                },
              )
            : null, 
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Indicateur de progression des étapes d'inscription.
            SignUpProgressIndicator(
              currentStep: _getStepIndex(_currentStep),
              totalSteps: 3, // Nombre total d'étapes.
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildStepContent(), // Affiche le contenu de l'étape actuelle.
              ),
            ),
            // Bouton "Continuer" en bas de l'écran.
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity, 
                height: 55,
                child: ElevatedButton(
                  onPressed: (isButtonEnabled && !_isSigningUp)
                      ? _nextStep
                      : null, // Désactive le bouton si l'inscription est en cours ou non activée.
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63), // Couleur de fond du bouton.
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

/// Widget pour afficher visuellement la progression de l'inscription.
class SignUpProgressIndicator extends StatelessWidget {
  final int currentStep; // L'étape actuelle (index zéro basé).
  final int totalSteps; // Le nombre total d'étapes.

  const SignUpProgressIndicator({
    Key? key,
    required this.currentStep,
    this.totalSteps = 3, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(totalSteps, (index) {
          bool isActive = index <=
              currentStep; // Détermine si l'étape est active (passée ou actuelle).
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(
                  right: index == totalSteps - 1
                      ? 0
                      : 8), // Ajoute une marge à droite sauf pour la dernière étape.
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFE91E63)
                    : Colors.grey[
                        300], // Les étapes actives sont roses, les inactives sont grises claires.
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}