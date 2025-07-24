import 'package:firebase_database/firebase_database.dart'; 

/// Représente le modèle de données pour un utilisateur de l'application.
class UserModel {
  // Propriétés obligatoires
  final String userId;      // L'identifiant unique de l'utilisateur, généralement fourni par Firebase Auth.
  final String prenom;      // Le prénom de l'utilisateur.
  final String nom;         // Le nom de famille de l'utilisateur.
  final String email;       // L'adresse email de l'utilisateur.

  // Propriétés optionnelles (peuvent être nulles)
  final String? status;         // Le statut de l'utilisateur (ex: 'Particulier' ou 'Entreprise').
  final String? address;        // L'adresse physique de l'utilisateur.
  final String? mobileNumber;   // Le numéro de téléphone portable de l'utilisateur.
  final String? registrationDate; // La date d'inscription de l'utilisateur, stockée comme une chaîne de caractères (ISO 8601).
  final String? birthDate;      // La date de naissance de l'utilisateur, stockée comme une chaîne de caractères.
  final String? website;        // Le site web de l'utilisateur (pour les entreprises ou profils spécifiques).

  /// Constructeur de la classe `UserModel`.
  /// Prend des paramètres obligatoires et optionnels pour initialiser un objet UserModel.
  UserModel({
    required this.userId,
    required this.email,
    required this.prenom,
    required this.nom,
    this.status,
    this.address,
    this.mobileNumber,
    this.registrationDate,
    this.birthDate,
    this.website,
  });

  
  /// Le casting `as String` ou `as String?` est utilisé pour garantir la sécurité des types.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] as String,
      email: map['email'] as String,
      prenom: map['prenom'] as String,
      nom: map['nom'] as String,
      status: map['status'] as String?,
      address: map['address'] as String?,
      mobileNumber: map['mobileNumber'] as String?,
      registrationDate: map['registrationDate'] as String?, 
      birthDate: map['birthDate'] as String?,
      website: map['website'] as String?,
    );
  }

  /// Méthode pour convertir l'instance actuelle de `UserModel` en un `Map<String, dynamic>`.
  /// Ceci est utilisé pour préparer les données de l'utilisateur avant de les envoyer
  /// à Firebase Realtime Database pour le stockage.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'prenom': prenom,
      'nom': nom,
      'status': status,
      'address': address,
      'mobileNumber': mobileNumber,
      'registrationDate': registrationDate,
      'birthDate': birthDate,
      'website': website,
    };
  }
}