import 'product_category_model.dart';

class ProductModel {
  final String productId;
  final String productName;
  final double price;
  final String reference;
  final String? productPhotoUrl;
  final String? manufacturingDate;
  final String supplier;
  final ProductCategoryModel? productCategory;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.reference,
    this.manufacturingDate,
    required this.supplier,
    this.productPhotoUrl,
    this.productCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'productID': productId,
      'productName': productName,
      'price': price,
      'reference': reference,
      'productPhotoUrl': productPhotoUrl,
      'manufacturingDate': manufacturingDate,
      'supplier': supplier,
      'productCategory': productCategory?.toJson(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, {required String id}) {
    ProductCategoryModel? productCategoryData;
    if (map['productCategory'] != null && map['productCategory'] is Map) {
      try {
        productCategoryData = ProductCategoryModel.fromMap(
          Map<String, dynamic>.from(map['productCategory']),
          id: map['productCategory']['categoryId'] as String? ?? '',
        );
      } catch (e) {
        print('Erreur lors de la désérialisation de la catégorie de produit: $e');
      }
    }

    return ProductModel(
      productId: id,
      productName: map['productName'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      reference: map['reference'] as String? ?? '',
      productPhotoUrl: map['productPhotoUrl'] as String?,
      manufacturingDate: map['manufacturingDate'] as String?,
      supplier: map['supplier'] as String? ?? '',
      productCategory: productCategoryData,
    );
  }

  ProductModel copyWith({
    String? productId,
    String? productName,
    double? price,
    String? reference,
    ProductCategoryModel? productCategory,
    String? productPhotoUrl,
    String? manufacturingDate,
    String? supplier,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      reference: reference ?? this.reference,
      productCategory: productCategory ?? this.productCategory,
      productPhotoUrl: productPhotoUrl ?? this.productPhotoUrl,
      manufacturingDate: manufacturingDate ?? this.manufacturingDate,
      supplier: supplier ?? this.supplier,
    );
  }
}