import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import 'dart:developer';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  RxDouble profileCompletionPercentage = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    log('DEBUG_TIME: [UserController] Initialisation du contrôleur utilisateur.');

    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        log('DEBUG_TIME: [UserController] État d\'authentification changé - Utilisateur connecté (UID: ${user.uid}).');
        await fetchCurrentUserDetails(user.uid);
        calculateProfileCompletion(); 
        log('DEBUG_TIME: [UserController] Détails utilisateur récupérés et `currentUser` mis à jour.');
      } else {
        currentUser.value = null;
        profileCompletionPercentage.value = 0.0; 
        log('DEBUG_TIME: [UserController] Utilisateur déconnecté.');
      }
    });

    ever(currentUser, (_) {
      calculateProfileCompletion();
    });
  }

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

  void calculateProfileCompletion() {
    if (currentUser.value == null) {
      profileCompletionPercentage.value = 0.0;
      return;
    }

    int completedFields = 0;
    int totalFields = 7; 

    if (currentUser.value!.prenom != null && currentUser.value!.prenom.isNotEmpty) completedFields++;
    if (currentUser.value!.nom != null && currentUser.value!.nom.isNotEmpty) completedFields++;
    if (currentUser.value!.status != null && currentUser.value!.status!.isNotEmpty) completedFields++;
    if (currentUser.value!.address != null && currentUser.value!.address!.isNotEmpty) completedFields++;
    if (currentUser.value!.mobileNumber != null && currentUser.value!.mobileNumber!.isNotEmpty) completedFields++;
    if (currentUser.value!.birthDate != null && currentUser.value!.birthDate!.isNotEmpty) completedFields++;
    if (currentUser.value!.website != null && currentUser.value!.website!.isNotEmpty) completedFields++;


    profileCompletionPercentage.value = (completedFields / totalFields) * 100;
    log('DEBUG_TIME: [UserController] Profile completion: ${profileCompletionPercentage.value.toInt()}% for ${currentUser.value?.email ?? 'unknown'}');
  }

  Future<void> signUp(String email, String password, String prenom, String nom) async {
    try {
      log('DEBUG_TIME: [UserController] Tentative d\'inscription pour l\'email: $email.');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        UserModel newUser = UserModel(
          userId: userCredential.user!.uid,
          email: userCredential.user!.email!,
          prenom: prenom,
          nom: nom,
          registrationDate: DateTime.now().toIso8601String(),
        );

        log('DEBUG_TIME: [UserController] Utilisateur Firebase Auth créé. Sauvegarde des données utilisateur...');
        await saveUserData(newUser);

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