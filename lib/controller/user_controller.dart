import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import 'dart:developer'; 

/// `UserController` gère l'état de l'utilisateur et les interactions avec Firebase Authentication
/// et Firebase Realtime Database.
class UserController extends GetxController {
 
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    log('DEBUG_TIME: [UserController] Initialisation du contrôleur utilisateur.');

    
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // L'utilisateur est connecté.
        log('DEBUG_TIME: [UserController] État d\'authentification changé - Utilisateur connecté (UID: ${user.uid}).');
        // Récupère les détails complets de l'utilisateur depuis la base de données.
        await fetchCurrentUserDetails(user.uid);
        log('DEBUG_TIME: [UserController] Détails utilisateur récupérés et `currentUser` mis à jour.');
      } else {
        // L'utilisateur est déconnecté.
        currentUser.value = null; // Réinitialise l'utilisateur actuel à nul.
        log('DEBUG_TIME: [UserController] Utilisateur déconnecté.');
      }
    });
  }

  /// Sauvegarde les données d'un utilisateur dans Firebase Realtime Database.
  /// Prend un `UserModel` en paramètre et le stocke sous l'ID de l'utilisateur.
  Future<void> saveUserData(UserModel user) async {
    try {
      log('DEBUG_TIME: [UserController] Début de la sauvegarde des données utilisateur pour UID: ${user.userId}.');
      await _databaseRef.child('users').child(user.userId).set(user.toMap());
      currentUser.value = user; 
      log('DEBUG_TIME: [UserController] Données utilisateur sauvegardées avec succès pour UID: ${user.userId}.');
    } catch (e) {
      log('DEBUG_TIME: [UserController] Erreur lors de la sauvegarde des données utilisateur: $e.');
      rethrow; 
    }
  }

  /// Récupère les détails d'un utilisateur spécifique depuis Firebase Realtime Database.
  /// Prend l'ID de l'utilisateur (`uid`) comme paramètre.
  Future<void> fetchCurrentUserDetails(String uid) async {
    try {
      log('DEBUG_TIME: [UserController] Début de la récupération des détails utilisateur pour UID: $uid.');
      final DatabaseEvent event = await _databaseRef.child('users').child(uid).once();
      final data = event.snapshot.value;

      if (data != null && data is Map<dynamic, dynamic>) {
        final Map<String, dynamic> userData = Map<String, dynamic>.from(data);
        currentUser.value = UserModel.fromMap(userData);
        log('DEBUG_TIME: [UserController] Données utilisateur récupérées avec succès pour ${currentUser.value?.email}.');
      } else {
        
        log('DEBUG_TIME: [UserController] Aucune donnée utilisateur trouvée pour UID: $uid.');
        currentUser.value = null; 
      }
    } catch (e) {
      log('DEBUG_TIME: [UserController] Erreur lors de la récupération des données utilisateur: $e.');
      currentUser.value = null;
    }
  }

  /// Tente de connecter un utilisateur avec son email et mot de passe.
  Future<void> signIn(String email, String password) async {
    try {
      log('DEBUG_TIME: [UserController] Tentative de connexion pour l\'email: $email.');
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      log('DEBUG_TIME: [UserController] Connexion Firebase Auth réussie pour $email.');
      
    } on FirebaseAuthException catch (e) {
      log('DEBUG_TIME: [UserController] Erreur de connexion Firebase Auth pour $email: ${e.code} - ${e.message}.');
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'Aucun utilisateur trouvé pour cet e-mail.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'Mot de passe incorrect.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Trop de tentatives. Veuillez réessayer plus tard.';
      } else {
        errorMessage = 'Erreur de connexion : ${e.message}';
      }
      Get.snackbar("Erreur de connexion", errorMessage, snackPosition: SnackPosition.BOTTOM);
      rethrow;
    } catch (e) {
      log('DEBUG_TIME: [UserController] Erreur inattendue lors de la connexion: $e.');
      Get.snackbar("Erreur", "Une erreur inattendue est survenue : $e", snackPosition: SnackPosition.BOTTOM);
      rethrow; 
    }
  }

  /// Enregistre un nouvel utilisateur avec son email, mot de passe, prénom et nom.
  Future<void> signUp(String email, String password, String prenom, String nom) async {
    try {
      log('DEBUG_TIME: [UserController] Tentative d\'inscription pour l\'email: $email.');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Crée un nouveau modèle d'utilisateur avec les informations fournies.
        UserModel newUser = UserModel(
          userId: userCredential.user!.uid,
          email: userCredential.user!.email!,
          prenom: prenom,
          nom: nom,
          registrationDate: DateTime.now().toIso8601String(), 
        );

        log('DEBUG_TIME: [UserController] Utilisateur Firebase Auth créé. Sauvegarde des données utilisateur...');
        await saveUserData(newUser); // Sauvegarde les données du nouvel utilisateur dans la Realtime Database.

        currentUser.value = newUser;
        log('DEBUG_TIME: [UserController] Processus d\'inscription terminé. `currentUser` mis à jour.');

        Get.snackbar("Succès", "Compte créé avec succès !");
          }
    } on FirebaseAuthException catch (e) {
      log('DEBUG_TIME: [UserController] Erreur Firebase Auth lors de l\'inscription: ${e.code} - ${e.message}.');
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'Le mot de passe est trop faible.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Un compte existe déjà pour cet email.';
      } else {
        errorMessage = 'Erreur d\'authentification : ${e.message}';
      }
      Get.snackbar("Erreur d'inscription", errorMessage, snackPosition: SnackPosition.BOTTOM);
      rethrow; 
    } catch (e) {
      log('DEBUG_TIME: [UserController] Erreur inattendue lors de l\'inscription: $e.');
      Get.snackbar("Erreur", "Une erreur inattendue est survenue : $e", snackPosition: SnackPosition.BOTTOM);
      rethrow; 
    }
  }
}