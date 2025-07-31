import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/warranty_model.dart';
import '../controller/product_controller.dart';
import '../models/product_model.dart';
import '../models/product_category_model.dart';


class WarrantyController extends GetxController {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  late final ProductController _productController;

  RxList<WarrantyModel> warranties = <WarrantyModel>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxString successMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    log('DEBUG_TIME: [WarrantyController] Initialisation du contrôleur de garantie.');
    try {
      _productController = Get.find<ProductController>();
      log('DEBUG_TIME: [WarrantyController] ProductController trouvé et initialisé.');
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          fetchWarrantiesByUserId(user.uid);
        } else {
          warranties.clear();
        }
      });
    } catch (e) {
      log('ERROR: [WarrantyController] ProductController non trouvé. Assurez-vous de l\'initialiser avec Get.put() au démarrage de votre application. Erreur: $e');
      errorMessage.value = "Erreur critique: Le contrôleur de produits n'a pas été initialisé.";
    }
  }

  String generateUniqueId() {
    return _uuid.v4();
  }

  Future<String?> uploadFile(File file, String folderName) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final String userId = currentUser?.uid ?? 'anonymous';

      final String fileName = '$folderName/${userId}/${generateUniqueId()}_${file.path.split('/').last}';
      final Reference storageRef = _storage.ref().child(fileName);
      final UploadTask uploadTask = storageRef.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      log('DEBUG_TIME: [WarrantyController] Fichier uploadé: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      log('DEBUG_TIME: [WarrantyController] Erreur lors de l\'upload du fichier: $e');
      Get.snackbar(
        "Erreur d'upload",
        "Impossible d'uploader le fichier: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  /// Ajoute une nouvelle garantie à la base de données.
  /// Le 'productCategoryId' est l'ID de la catégorie (ou sous-catégorie) référencée.
  Future<void> addWarranty({
    required String userId,
    required String productName,
    required double price,
    required String manufactureDate,
    required String reference,
    required String productCategoryId, 
    required String supplier, 
    required String warrantyType,
    File? productPhotoFile,
    required String startDate,
    required String endDate,
    required String purchaseDate,
    required String sellerName,
    File? invoiceFile,
    File? certificateFile,
    String? notes,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      log('DEBUG_TIME: [WarrantyController] Début de l\'ajout de la garantie pour: $productName (User ID: $userId)');

      
      ProductCategoryModel? existingProductCategoryDefinition = _productController.findProductCategoryById(productCategoryId);
      if (existingProductCategoryDefinition == null) {
        throw Exception("La catégorie de produit avec l'ID '$productCategoryId' n'existe pas. Veuillez la créer d'abord.");
      } else {
        log('DEBUG_TIME: [WarrantyController] Définition de catégorie de produit existante trouvée: ${existingProductCategoryDefinition.categoryName} (ID: $productCategoryId)');
      }

     
      ProductModel? product;
      // Chercher le produit par référence (qui devrait être unique par produit)
      product = _productController.products.firstWhereOrNull((p) => p.reference == reference);

      String? productImageUrl;
      if (productPhotoFile != null) {
        productImageUrl = await uploadFile(productPhotoFile, 'product_photos');
        if (productImageUrl == null) {
          throw Exception("Échec de l'upload de la photo du produit.");
        }
        log('DEBUG_TIME: [WarrantyController] Photo produit uploadée: $productImageUrl');
      }

      String finalProductId;
      if (product != null) {
        // Mettre à jour le produit existant
        finalProductId = product.productId;
        final updatedProduct = ProductModel(
          productId: product.productId,
          productName: productName,
          productCategoryId: productCategoryId,
          price: price,
          reference: reference,
          manufacturingDate: manufactureDate,
          productPhotoUrl: productImageUrl ?? product.productPhotoUrl, // Conserver l'URL existante si pas de nouvelle photo
          supplier: supplier, 
        );
        await _productController.updateProduct(updatedProduct);
        log('DEBUG_TIME: [WarrantyController] Produit existant mis à jour: ${updatedProduct.productName}');
      } else {
        final newProduct = ProductModel(
          productId: '', 
          productName: productName,
          productCategoryId: productCategoryId,
          price: price,
          reference: reference,
          manufacturingDate: manufactureDate,
          productPhotoUrl: productImageUrl,
          supplier: supplier, 
        );
        // addProduct retourne le ProductModel avec l'ID généré par Firebase
        final ProductModel addedProduct = await _productController.addProduct(newProduct);
        finalProductId = addedProduct.productId; 
        log('DEBUG_TIME: [WarrantyController] Nouveau produit créé avec ID: $finalProductId');
      }

      // --- 3. Uploader les fichiers spécifiques à la garantie (facture, certificat) ---
      String? uploadedInvoiceUrl;
      if (invoiceFile != null) {
        uploadedInvoiceUrl = await uploadFile(invoiceFile, 'invoice_files');
        if (uploadedInvoiceUrl == null) {
          throw Exception("Échec de l'upload du fichier de facture.");
        }
        log('DEBUG_TIME: [WarrantyController] Facture uploadée: $uploadedInvoiceUrl');
      }

      String? uploadedCertificateUrl;
      if (certificateFile != null) {
        uploadedCertificateUrl = await uploadFile(certificateFile, 'certificate_files');
        if (uploadedCertificateUrl == null) {
          throw Exception("Échec de l'upload du fichier de certificat.");
        }
        log('DEBUG_TIME: [WarrantyController] Certificat uploadé: $uploadedCertificateUrl');
      }

      // Créer le modèle de garantie ---
      final String warrantyId = generateUniqueId();
      final WarrantyModel newWarranty = WarrantyModel(
        id: warrantyId,
        userId: userId,
        productId: finalProductId, 
        warrantyType: warrantyType,
        startDate: startDate,
        endDate: endDate,
        purchaseDate: purchaseDate,
        sellerName: sellerName,
        invoiceFilePath: uploadedInvoiceUrl,
        certificateFilePath: uploadedCertificateUrl,
        notes: notes,
        createdAt: DateTime.now().toIso8601String(),
      );

      // Enregistrer la garantie dans Firebase Realtime Database ---
      await _databaseRef.child('warranties_by_user').child(userId).child(newWarranty.id!).set(newWarranty.toJson());

      // Mettre à jour la liste observable locale si l'utilisateur est le même
      if (FirebaseAuth.instance.currentUser?.uid == userId) {
        warranties.add(newWarranty);
      }

      successMessage.value = 'Garantie ajoutée avec succès !';
      log('DEBUG_TIME: [WarrantyController] Garantie ajoutée avec succès !');
      Get.snackbar(
        'Succès',
        successMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back(); // Revenir de AddWarrantyPage
    } catch (e) {
      errorMessage.value = 'Erreur lors de l\'ajout de la garantie: ${e.toString()}';
      log('DEBUG_TIME: [WarrantyController] Erreur lors de l\'ajout de la garantie: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Récupère toutes les garanties pour l'utilisateur actuellement connecté.
  Future<void> fetchWarrantiesForCurrentUser() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      log('WARNING: [WarrantyController] Aucun utilisateur connecté pour récupérer les garanties.');
      warranties.clear();
      return;
    }
    await fetchWarrantiesByUserId(currentUser.uid);
  }

  /// Récupère toutes les garanties associées à un ID utilisateur spécifique.
  Future<void> fetchWarrantiesByUserId(String userId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      log('DEBUG_TIME: [WarrantyController] Début de la récupération des garanties pour l\'utilisateur: $userId.');
      final DatabaseEvent event = await _databaseRef.child('warranties_by_user').child(userId).once();
      final data = event.snapshot.value;

      if (data != null && data is Map<dynamic, dynamic>) {
        final List<WarrantyModel> fetchedWarranties = [];
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            fetchedWarranties.add(WarrantyModel.fromMap(Map<String, dynamic>.from(value), id: key));
          }
        });
        warranties.assignAll(fetchedWarranties);
        log('DEBUG_TIME: [WarrantyController] Garanties récupérées avec succès (${fetchedWarranties.length} trouvées) pour l\'utilisateur $userId.');
      } else {
        warranties.clear();
        log('DEBUG_TIME: [WarrantyController] Aucune garantie trouvée pour l\'utilisateur: $userId.');
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors de la récupération des garanties: ${e.toString()}';
      log('DEBUG_TIME: [WarrantyController] Erreur lors de la récupération des garanties pour l\'utilisateur $userId: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Récupère une seule garantie par son ID et l'ID de l'utilisateur.
  Future<WarrantyModel?> getWarrantyByIdAndUserId(String userId, String warrantyId) async {
    try {
      log('DEBUG_TIME: [WarrantyController] Récupération de la garantie $warrantyId pour l\'utilisateur $userId.');
      final DatabaseEvent event = await _databaseRef.child('warranties_by_user').child(userId).child(warrantyId).once();
      final data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        log('DEBUG_TIME: [WarrantyController] Garantie trouvée.');
        return WarrantyModel.fromMap(Map<String, dynamic>.from(data), id: warrantyId);
      }
      log('DEBUG_TIME: [WarrantyController] Garantie non trouvée pour ID: $warrantyId et utilisateur: $userId.');
      return null;
    } catch (e) {
      log('DEBUG_TIME: [WarrantyController] Erreur lors de la récupération de la garantie par ID et utilisateur: $e.');
      return null;
    }
  }

  /// Met à jour une garantie existante dans la base de données.
  Future<void> updateWarranty(String userId, WarrantyModel warranty) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    try {
      if (warranty.id == null) {
        throw Exception("L'ID de la garantie est manquant pour la mise à jour.");
      }
      log('DEBUG_TIME: [WarrantyController] Début de la mise à jour de la garantie (ID: ${warranty.id}, User ID: $userId).');
      await _databaseRef.child('warranties_by_user').child(userId).child(warranty.id!).set(warranty.toJson());

      int index = warranties.indexWhere((w) => w.id == warranty.id);
      if (index != -1) {
        warranties[index] = warranty;
      }
      successMessage.value = 'Garantie mise à jour avec succès !';
      log('DEBUG_TIME: [WarrantyController] Garantie mise à jour avec succès.');
      Get.snackbar(
        'Succès',
        successMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors de la mise à jour de la garantie: ${e.toString()}';
      log('DEBUG_TIME: [WarrantyController] Erreur lors de la mise à jour de la garantie: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Supprime une garantie de la base de données.
  Future<void> deleteWarranty(String userId, String warrantyId) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    try {
      log('DEBUG_TIME: [WarrantyController] Début de la suppression de la garantie (ID: $warrantyId, User ID: $userId).');
      await _databaseRef.child('warranties_by_user').child(userId).child(warrantyId).remove();
      warranties.removeWhere((w) => w.id == warrantyId);
      successMessage.value = 'Garantie supprimée avec succès !';
      log('DEBUG_TIME: [WarrantyController] Garantie supprimée avec succès.');
      Get.snackbar(
        'Succès',
        successMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors de la suppression de la garantie: ${e.toString()}';
      log('DEBUG_TIME: [WarrantyController] Erreur lors de la suppression de la garantie: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  
  Future<List<WarrantyModel>> getWarrantiesForProduct(String productId) async {
    try {
      log('DEBUG_TIME: [WarrantyController] Tentative de récupération des garanties pour le produit: $productId sur l\'ensemble des utilisateurs.');
      List<WarrantyModel> productWarranties = [];

      final allUsersWarrantiesSnapshot = await _databaseRef.child('warranties_by_user').once();
      final usersData = allUsersWarrantiesSnapshot.snapshot.value;

      if (usersData != null && usersData is Map<dynamic, dynamic>) {
        usersData.forEach((userId, userWarrantiesMap) {
          if (userWarrantiesMap is Map<dynamic, dynamic>) {
            userWarrantiesMap.forEach((warrantyId, warrantyData) {
              if (warrantyData is Map<dynamic, dynamic>) {
                if (warrantyData['productId'] == productId) {
                  final warranty = WarrantyModel.fromMap(Map<String, dynamic>.from(warrantyData), id: warrantyId);
                  productWarranties.add(warranty);
                }
              }
            });
          }
        });
      }

      log('DEBUG_TIME: [WarrantyController] ${productWarranties.length} garanties trouvées pour le produit $productId (recherche inter-utilisateurs).');
      return productWarranties;
    } catch (e) {
      log('DEBUG_TIME: [WarrantyController] Erreur lors de la récupération des garanties pour le produit: $e.');
      return [];
    }
  }

  // Ajout d'une méthode pour récupérer un ProductModel à partir de son ID
  Future<ProductModel?> getProductDetails(String productId) async {
    return _productController.getProductById(productId);
  }

  // Ajout d'une méthode pour récupérer ProductCategoryModel à partir de son ID
  Future<ProductCategoryModel?> getProductCategoryDetails(String categoryId) async {
    return _productController.findProductCategoryById(categoryId);
  }
}