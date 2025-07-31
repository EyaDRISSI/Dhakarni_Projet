import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/product_category_model.dart';

class ProductController extends GetxController {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  RxList<ProductModel> products = <ProductModel>[].obs;
  RxList<ProductCategoryModel> productCategories = <ProductCategoryModel>[].obs;
  RxBool isLoadingProducts = false.obs;
  RxBool isLoadingCategories = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    log('DEBUG_TIME: [ProductController] Initialisation du contrôleur de produits.');
    fetchProductCategories();
    fetchAllProducts();
  }

 
  Future<void> fetchProductCategories() async {
    isLoadingCategories.value = true;
    errorMessage.value = '';
    try {
      log('DEBUG_TIME: [ProductController] Récupération des catégories de produits...');
      final DatabaseEvent event = await _databaseRef.child('productCategories').once();
      final data = event.snapshot.value;

      if (data != null && data is Map<dynamic, dynamic>) {
        final List<ProductCategoryModel> fetchedCategories = [];
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            
            fetchedCategories.add(ProductCategoryModel.fromMap(Map<String, dynamic>.from(value), id: key));
          }
        });
        productCategories.assignAll(fetchedCategories);
        log('DEBUG_TIME: [ProductController] Catégories récupérées avec succès: ${fetchedCategories.length}');
      } else {
        productCategories.clear();
        log('DEBUG_TIME: [ProductController] Aucune catégorie de produit trouvée.');
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors de la récupération des catégories: ${e.toString()}';
      log('DEBUG_TIME: [ProductController] Erreur lors de la récupération des catégories: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  
  Future<void> addProductCategory(ProductCategoryModel category, {String? parentCategoryId}) async {
    try {
      if (parentCategoryId != null && parentCategoryId.isNotEmpty) {
       
        log('DEBUG_TIME: [ProductController] Ajout de la sous-catégorie: ${category.categoryName} pour la catégorie parente: $parentCategoryId');
        final parentRef = _databaseRef.child('productCategories').child(parentCategoryId);
        final DataSnapshot snapshot = await parentRef.get();
        if (snapshot.exists && snapshot.value is Map) {
          final parentData = Map<String, dynamic>.from(snapshot.value as Map);
          final ProductCategoryModel parent = ProductCategoryModel.fromMap(parentData, id: parentCategoryId);

          // Vérifier si la sous-catégorie existe déjà par son ID
          if (!parent.subCategories.any((sub) => sub.categoryId == category.categoryId)) {
            List<ProductCategoryModel> updatedSubCategories = List.from(parent.subCategories);
            updatedSubCategories.add(category);

            await parentRef.update({
              'subCategories': updatedSubCategories.map((sub) => sub.toJson()).toList(),
            });

            final int parentIndex = productCategories.indexWhere((cat) => cat.categoryId == parentCategoryId);
            if (parentIndex != -1) {
              productCategories[parentIndex] = ProductCategoryModel(
                categoryId: parent.categoryId,
                categoryName: parent.categoryName,
                subCategories: updatedSubCategories,
              );
            }
            Get.snackbar('Succès', 'Sous-catégorie ajoutée avec succès !', snackPosition: SnackPosition.BOTTOM);
          } else {
            Get.snackbar('Attention', 'Cette sous-catégorie existe déjà pour cette catégorie parente.', snackPosition: SnackPosition.BOTTOM);
          }
        } else {
          Get.snackbar('Erreur', 'Catégorie parente introuvable.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        log('DEBUG_TIME: [ProductController] Ajout de la catégorie principale: ${category.categoryName}');

        await _databaseRef.child('productCategories').child(category.categoryId).set(category.toJson());
        if (!productCategories.any((cat) => cat.categoryId == category.categoryId)) {
          productCategories.add(category);
        }
        Get.snackbar('Succès', 'Catégorie principale ajoutée avec succès !', snackPosition: SnackPosition.BOTTOM);
      }
      fetchProductCategories(); // Re-fetch pour s'assurer que la liste locale est synchronisée
    } catch (e) {
      log('DEBUG_TIME: [ProductController] Erreur lors de l\'ajout de la catégorie/sous-catégorie: $e');
      Get.snackbar('Erreur', 'Impossible d\'ajouter la catégorie/sous-catégorie: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      rethrow;
    }
  }

  ProductCategoryModel? findProductCategoryById(String categoryId) {
    for (var category in productCategories) {
      if (category.categoryId == categoryId) {
        return category;
      }
      for (var subCategory in category.subCategories) {
        if (subCategory.categoryId == categoryId) {
          return subCategory;
        }
      }
    }
    return null;
  }

  ProductCategoryModel? findProductCategoryByName(String categoryName) {
    return productCategories.firstWhereOrNull((cat) => cat.categoryName == categoryName);
  }

  
  Future<void> fetchAllProducts() async {
    isLoadingProducts.value = true;
    errorMessage.value = '';
    try {
      log('DEBUG_TIME: [ProductController] Récupération de tous les produits...');
      final DatabaseEvent event = await _databaseRef.child('products').once();
      final data = event.snapshot.value;

      if (data != null && data is Map<dynamic, dynamic>) {
        final List<ProductModel> fetchedProducts = [];
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            fetchedProducts.add(ProductModel.fromMap(Map<String, dynamic>.from(value), id: key));
          }
        });
        products.assignAll(fetchedProducts);
        log('DEBUG_TIME: [ProductController] Produits récupérés avec succès: ${fetchedProducts.length}');
      } else {
        products.clear();
        log('DEBUG_TIME: [ProductController] Aucun produit trouvé.');
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors de la récupération des produits: ${e.toString()}';
      log('DEBUG_TIME: [ProductController] Erreur lors de la récupération des produits: $e');
    } finally {
      isLoadingProducts.value = false;
    }
  }

 
  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      log('DEBUG_TIME: [ProductController] Ajout du produit: ${product.productName}');
      final newProductRef = _databaseRef.child('products').push();
      final String? newProductId = newProductRef.key;

      if (newProductId != null) {
        final ProductModel productWithId = ProductModel(
          productId: newProductId, // Utilise l'ID généré par Firebase
          productName: product.productName,
          price: product.price,
          reference: product.reference,
          productCategoryId: product.productCategoryId,
          productPhotoUrl: product.productPhotoUrl,
          manufacturingDate: product.manufacturingDate,
          supplier: product.supplier,
        );
        await newProductRef.set(productWithId.toJson()); // Sauvegarde les données y compris le productID
        products.add(productWithId);
        Get.snackbar('Succès', 'Produit ajouté avec succès !', snackPosition: SnackPosition.BOTTOM);
        return productWithId; 
      } else {
        throw Exception('Impossible de générer un nouvel ID pour le produit.');
      }
    } catch (e) {
      log('DEBUG_TIME: [ProductController] Erreur lors de l\'ajout du produit: $e');
      Get.snackbar('Erreur', 'Impossible d\'ajouter le produit: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      log('DEBUG_TIME: [ProductController] Mise à jour du produit: ${product.productName}');
      // Utiliser l'ID du produit pour la mise à jour
      await _databaseRef.child('products').child(product.productId).update(product.toJson());
      int index = products.indexWhere((p) => p.productId == product.productId);
      if (index != -1) {
        products[index] = product;
      }
      Get.snackbar('Succès', 'Produit mis à jour avec succès !', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      log('DEBUG_TIME: [ProductController] Erreur lors de la mise à jour du produit: $e');
      Get.snackbar('Erreur', 'Impossible de mettre à jour le produit: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      rethrow;
    }
  }

  ProductModel? getProductById(String productId) {
    return products.firstWhereOrNull((p) => p.productId == productId);
  }
}