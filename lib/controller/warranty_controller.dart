import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './notification_controller.dart';
import '../models/warranty_model.dart';
import '../models/product_model.dart';
import './product_controller.dart';
import '../models/product_category_model.dart';

const String CLOUDINARY_CLOUD_NAME = 'ddwjxlj6e';
const String CLOUDINARY_UPLOAD_PRESET = 'Dhakarni';

class WarrantyController extends GetxController {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final Uuid _uuid = const Uuid();
  late final ProductController _productController;
  late final NotificationController _notificationController;

  final RxList<WarrantyModel> _allWarranties = <WarrantyModel>[].obs;
  final RxList<WarrantyModel> filteredWarranties = <WarrantyModel>[].obs;

  List<WarrantyModel> get allWarranties => _allWarranties.toList();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  final RxString userId = ''.obs;
  final RxString searchTerm = ''.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      _productController = Get.find<ProductController>();
      _notificationController = Get.find<NotificationController>();
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          userId.value = user.uid;
          fetchWarrantiesByUserId(user.uid);
        } else {
          _allWarranties.clear();
          filteredWarranties.clear();
          userId.value = '';
        }
      });
      debounce(searchTerm, (_) => filterWarranties(searchTerm.value),
          time: const Duration(milliseconds: 300));
    } catch (e) {
      errorMessage.value =
          "Erreur critique: Le contrôleur de produits n'a pas été initialisé.";
    }
  }

  void filterWarranties(String query) {
    if (query.isEmpty) {
      filteredWarranties.assignAll(_allWarranties);
    } else {
      final lowerCaseQuery = query.toLowerCase();
      filteredWarranties.assignAll(_allWarranties.where((warranty) {
        final productName = warranty.product?.productName.toLowerCase() ?? '';
        return productName.contains(lowerCaseQuery);
      }).toList());
    }
  }

  String generateUniqueId() => _uuid.v4();

  Future<String?> uploadFile(File file, String folderName) async {
    try {
      final url = Uri.parse(
          'https://api.cloudinary.com/v1_1/$CLOUDINARY_CLOUD_NAME/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = CLOUDINARY_UPLOAD_PRESET
        ..fields['folder'] = folderName
        ..files.add(
          await http.MultipartFile.fromPath('file', file.path),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        final String downloadUrl = data['secure_url'];
        return downloadUrl;
      } else {
        log('Échec de l\'upload, statut: ${response.statusCode}');
        log('Raison: ${await response.stream.bytesToString()}');
        return null;
      }
    } catch (e) {
      log('Erreur lors de l\'upload vers Cloudinary: $e');
      return null;
    }
  }

  Future<WarrantyModel> addWarranty({
    required String userId,
    required String productName,
    required double price,
    required String manufactureDate,
    required String reference,
    required String productCategoryId,
    required String productCategoryName,
    required String productSubCategoryName,
    required String supplier,
    required String warrantyType,
    File? productPhotoFile,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime purchaseDate,
    required String sellerName,
    File? invoiceFile,
    File? certificateFile,
    String? notes,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final ProductCategoryModel? parentCategory = _productController
          .productCategories
          .firstWhereOrNull((cat) => cat.categoryId == productCategoryId);
      final ProductCategoryModel? subCategory = parentCategory?.subCategories
          .firstWhereOrNull((sub) => sub.categoryName == productSubCategoryName);

      final ProductCategoryModel? finalProductCategory;
      if (parentCategory != null && subCategory != null) {
        finalProductCategory = ProductCategoryModel(
          categoryId: parentCategory.categoryId,
          categoryName: parentCategory.categoryName,
          subCategories: [subCategory],
        );
      } else {
        throw Exception("Catégorie ou sous-catégorie non trouvée.");
      }

      ProductModel? existingProduct = _productController.products
          .firstWhereOrNull((p) => p.reference == reference);

      final ProductModel finalProduct;
      if (existingProduct != null) {
        finalProduct = existingProduct.copyWith(
          productName: productName,
          productCategory: finalProductCategory,
          price: price,
          reference: reference,
          manufacturingDate: manufactureDate,
          supplier: supplier,
        );
        await _productController.updateProduct(finalProduct);
      } else {
        final newProduct = ProductModel(
          productId: generateUniqueId(),
          productName: productName,
          productCategory: finalProductCategory,
          price: price,
          reference: reference,
          manufacturingDate: manufactureDate,
          supplier: supplier,
        );
        finalProduct = await _productController.addProduct(newProduct);
      }
      
      String? productPhotoUrl;
      String? invoiceUrl;
      String? certificateUrl;

      await Future.wait([
        if (productPhotoFile != null)
          uploadFile(productPhotoFile, 'product_photos').then((url) => productPhotoUrl = url),
        if (invoiceFile != null)
          uploadFile(invoiceFile, 'invoice_files').then((url) => invoiceUrl = url),
        if (certificateFile != null)
          uploadFile(certificateFile, 'certificate_files').then((url) => certificateUrl = url),
      ]);
      
      final updatedProduct = finalProduct.copyWith(productPhotoUrl: productPhotoUrl);
      await _productController.updateProduct(updatedProduct);

      final String warrantyId = generateUniqueId();
      final WarrantyModel newWarranty = WarrantyModel(
        id: warrantyId,
        userId: userId,
        productId: updatedProduct.productId,
        warrantyType: warrantyType,
        startDate: startDate,
        endDate: endDate,
        purchaseDate: purchaseDate,
        sellerName: sellerName,
        notes: notes,
        createdAt: DateTime.now(),
        product: updatedProduct,
        invoiceFilePath: invoiceUrl,
        certificateFilePath: certificateUrl,
      );

      await _databaseRef
          .child('warranties_by_user')
          .child(userId)
          .child(newWarranty.id!)
          .set(newWarranty.toJson());

      _allWarranties.add(newWarranty);
      filterWarranties(searchTerm.value);

      successMessage.value = 'Garantie ajoutée avec succès !';
      isLoading.value = false;
      log('DEBUG: Garantie ajoutée avec succès. Photos et fichiers inclus.');

      return newWarranty;
    } catch (e) {
      errorMessage.value =
          'Erreur lors de l\'ajout de la garantie: ${e.toString()}';
      log('ERROR: Erreur dans addWarranty: $e');
      isLoading.value = false;
      rethrow;
    }
  }

  Future<void> updateWarranty({
    required WarrantyModel updatedWarranty,
    File? productPhotoFile,
    File? invoiceFile,
    File? certificateFile,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      if (updatedWarranty.id == null || userId.value.isEmpty) {
        throw Exception("ID de garantie ou ID utilisateur manquant.");
      }

      String? productPhotoUrl;
      String? invoiceUrl;
      String? certificateUrl;

      await Future.wait([
        if (productPhotoFile != null)
          uploadFile(productPhotoFile, 'product_photos').then((url) => productPhotoUrl = url),
        if (invoiceFile != null)
          uploadFile(invoiceFile, 'invoice_files').then((url) => invoiceUrl = url),
        if (certificateFile != null)
          uploadFile(certificateFile, 'certificate_files').then((url) => certificateUrl = url),
      ]);

      final updatedProduct = updatedWarranty.product?.copyWith(
        productPhotoUrl: productPhotoUrl,
      );
      final newLocalWarranty = updatedWarranty.copyWith(
        product: updatedProduct,
        invoiceFilePath: invoiceUrl ?? updatedWarranty.invoiceFilePath,
        certificateFilePath: certificateUrl ?? updatedWarranty.certificateFilePath,
      );

      if (updatedProduct != null) {
        await _productController.updateProduct(updatedProduct);
      }
      await _databaseRef
          .child('warranties_by_user')
          .child(userId.value)
          .child(newLocalWarranty.id!)
          .update(newLocalWarranty.toJson());

      final index = _allWarranties.indexWhere((w) => w.id == updatedWarranty.id);
      if (index != -1) {
        _allWarranties[index] = newLocalWarranty;
        filterWarranties(searchTerm.value);
      }

      successMessage.value = 'Garantie mise à jour avec succès !';
    } catch (e) {
      errorMessage.value = 'Erreur lors de la mise à jour de la garantie: ${e.toString()}';
      log('ERROR: Erreur dans updateWarranty: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWarrantiesByUserId(String userId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final DatabaseEvent event =
          await _databaseRef.child('warranties_by_user').child(userId).once();
      final data = event.snapshot.value;

      if (data != null && data is Map<dynamic, dynamic>) {
        final List<Future<WarrantyModel>> futures = [];

        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final warrantyMap = Map<String, dynamic>.from(value);
            final warrantyId = key as String;

            futures.add(() async {
              final warranty = WarrantyModel.fromMap(warrantyMap, id: warrantyId);
              final product =
                  await _productController.getProductById(warranty.productId);
              if (product != null) {
                warranty.product = product;
                return warranty;
              } else {
                log('WARNING: Produit avec l\'ID ${warranty.productId} introuvable pour la garantie $warrantyId.');
                return warranty;
              }
            }());
          }
        });

        final fetchedWarranties = await Future.wait(futures);

        final validWarranties =
            fetchedWarranties.where((w) => w.product != null).toList();

        _allWarranties.assignAll(validWarranties);
        filterWarranties(searchTerm.value);
      } else {
        _allWarranties.clear();
        filteredWarranties.clear();
      }
    } catch (e) {
      errorMessage.value =
          'Erreur lors de la récupération des garanties: ${e.toString()}';
      log('ERROR: Erreur dans fetchWarrantiesByUserId: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<WarrantyModel?> getWarrantyById(String warrantyId) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        log('Erreur: Utilisateur non authentifié.');
        return null;
      }

      final DatabaseEvent event = await _databaseRef
          .child('warranties_by_user')
          .child(currentUser.uid)
          .child(warrantyId)
          .once();

      final data = event.snapshot.value;

      if (data != null && data is Map<dynamic, dynamic>) {
        final warrantyMap = Map<String, dynamic>.from(data);
        final warranty = WarrantyModel.fromMap(warrantyMap, id: warrantyId);
        final product = await _productController.getProductById(warranty.productId);

        if (product != null) {
          warranty.product = product;
          return warranty;
        }
      }
      return null;
    } catch (e) {
      log('ERROR: Erreur lors de la récupération de la garantie: $e');
      return null;
    }
  }

  Future<void> deleteWarranty(String warrantyId) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    try {
      final warranty = _allWarranties.firstWhereOrNull((w) => w.id == warrantyId);
      if (warranty == null) {
        throw Exception("Garantie non trouvée.");
      }

      await _databaseRef
          .child('warranties_by_user')
          .child(userId.value)
          .child(warrantyId)
          .remove();

      await _notificationController.deleteNotificationsByWarrantyId(warrantyId);

      _allWarranties.removeWhere((w) => w.id == warrantyId);
      filterWarranties(searchTerm.value);

      successMessage.value = 'Garantie supprimée avec succès !';
    } catch (e) {
      errorMessage.value =
          'Erreur lors de la suppression de la garantie: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestWarrantyMigration(String warrantyId, String recipientEmail) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
      if (currentUserId == null || currentUserEmail == null) {
        throw Exception("Utilisateur non authentifié.");
      }

      final recipientUserSnapshot = await _databaseRef
          .child('users_by_email')
          .child(recipientEmail.replaceAll('.', ',')) 
          .once();

      if (recipientUserSnapshot.snapshot.value == null) {
        throw Exception("L'utilisateur avec cet email n'existe pas.");
      }
      final recipientUserId = recipientUserSnapshot.snapshot.value as String;

      if (recipientUserId == currentUserId) {
        throw Exception("Vous ne pouvez pas vous transférer une garantie à vous-même.");
      }

      final existingWarranty = _allWarranties.firstWhereOrNull((w) => w.id == warrantyId);
      if (existingWarranty == null) {
        throw Exception("Garantie non trouvée.");
      }

      // Créer une demande de migration
      final migrationRef = _databaseRef
          .child('pending_migrations')
          .child(recipientUserId)
          .child(warrantyId);
      
      await migrationRef.set({
        'senderId': currentUserId,
        'senderEmail': currentUserEmail, 
        'warrantyId': warrantyId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      successMessage.value = 'Demande de migration envoyée avec succès.';
      Get.snackbar('Succès', 'Demande de migration envoyée à $recipientEmail.');

    } catch (e) {
      errorMessage.value = "Erreur: ${e.toString()}";
      Get.snackbar('Erreur', 'Échec de l\'envoi de la demande: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}