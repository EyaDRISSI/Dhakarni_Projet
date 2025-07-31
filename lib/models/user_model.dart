import 'package:firebase_database/firebase_database.dart'; 

class UserModel {
  
  final String userId;     
  final String prenom;      
  final String nom;         
  final String email;       
  final String? status;        
  final String? address;        
  final String? mobileNumber;   
  final String? registrationDate; 
  final String? birthDate;      
  final String? website;        

  /// Constructeur de la classe `UserModel`.
  ///   initialiser un objet UserModel.
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