import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

import '../models/product_category_model.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxList<ProductCategoryModel> productCategories = <ProductCategoryModel>[].obs;
  RxList<ProductModel> products = <ProductModel>[].obs;
  RxBool isLoadingCategories = true.obs;
  RxBool isLoadingProducts = false.obs;

  final Uuid _uuid = const Uuid();

  final Map<String, List<String>> categoriesMap = {
    'Informatique': [
      'Ordinateurs portables',
      'Ordinateurs de bureau',
      'Imprimantes & scanners',
      'Disques durs & SSD',
      'Écrans',
      'Claviers & souris',
      'Réseaux & routeurs',
      'Logiciels'
    ],
    'Électroménager': [
      'Réfrigérateurs',
      'Lave-linge',
      'Fours & micro-ondes',
      'Cuisinières',
      'Aspirateurs',
      'Robots de cuisine',
      'Chauffe-eau',
      'Climatiseurs'
    ],
    'TV, Photo et Son': [
      'Téléviseurs LED/OLED',
      'Home cinéma',
      'Appareils photo numériques',
      'Caméras de surveillance',
      'Vidéo projecteurs',
      'Bluetooth',
      'Casques audio'
    ],
    'Téléphonie': [
      'Smartphones',
      'Téléphones fixes',
      'Tablettes',
      'Accessoires de téléphone',
      'Cartes SIM & recharge',
      'Écouteurs Bluetooth'
    ],
    'Accessoires': [
      'Coques & housses',
      'Chargeurs & câbles',
      'Supports téléphones / PC',
      'Batteries externes',
      'Clés USB',
      'Accessoires gaming',
      'Adaptateurs'
    ],
    'Véhicules': [
      'Voitures',
      'Motos & scooters',
      'Vélos',
      'Pièces détachées auto/moto',
      'Accessoires auto (GPS, tapis, caméras)',
      'Pneus & jantes'
    ],
    'Énergie et Solaire': [
      'Panneaux solaires',
      'Batteries solaires',
      'Régulateurs de charge',
      'Onduleurs',
      'Lampes solaires',
      'Kits solaires portables'
    ],
  };

  @override
  void onInit() {
    super.onInit();
    loadCategoriesFromMap();
    fetchProducts();
  }

  void loadCategoriesFromMap() {
    productCategories.clear();
    categoriesMap.forEach((categoryName, subCategoryNames) {
      final subCategories = subCategoryNames.map((name) => ProductCategoryModel(
        categoryId: _uuid.v4(),
        categoryName: name,
        subCategories: [],
      )).toList();

      productCategories.add(ProductCategoryModel(
        categoryId: _uuid.v4(),
        categoryName: categoryName,
        subCategories: subCategories,
      ));
    });
    isLoadingCategories.value = false;
  }
  
  Future<void> fetchProducts() async {
    isLoadingProducts.value = true;
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        log('Utilisateur non authentifié. Impossible de récupérer les produits.');
        products.clear();
        return;
      }
      final dataSnapshot = await _databaseRef.child('products').child(user.uid).get();

      if (dataSnapshot.exists) {
        final Map<dynamic, dynamic> data = dataSnapshot.value as Map<dynamic, dynamic>;
        final fetchedProducts = data.entries.map((entry) {
          final productId = entry.key as String;
          final productMap = Map<String, dynamic>.from(entry.value);
          return ProductModel.fromMap(productMap, id: productId);
        }).toList();
        products.assignAll(fetchedProducts);
      } else {
        products.clear();
      }
      log('Produits récupérés : ${products.length}');
    } catch (e) {
      log('Erreur lors de la récupération des produits: $e');
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non authentifié.');
      }
      await _databaseRef
          .child('products')
          .child(user.uid)
          .child(product.productId)
          .set(product.toJson());
      products.add(product);
      return product;
    } catch (e) {
      log('Erreur lors de l\'ajout du produit: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel updatedProduct) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non authentifié.');
      }
      final index = products.indexWhere((p) => p.productId == updatedProduct.productId);
      if (index != -1) {
        products[index] = updatedProduct;
        await _databaseRef
            .child('products')
            .child(user.uid)
            .child(updatedProduct.productId)
            .update(updatedProduct.toJson());
      }
    } catch (e) {
      log('Erreur lors de la mise à jour du produit: $e');
    }
  }

  ProductModel? getProductById(String productId) {
    return products.firstWhereOrNull((p) => p.productId == productId);
  }
}