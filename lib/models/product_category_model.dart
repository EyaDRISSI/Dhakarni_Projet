import 'package:flutter/foundation.dart';

class ProductCategoryModel {
  final String categoryId;
  final String categoryName;
  final List<ProductCategoryModel> subCategories;

  ProductCategoryModel({
    required this.categoryId,
    required this.categoryName,
    this.subCategories = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subCategories': subCategories.map((e) => e.toJson()).toList(),
    };
  }

  factory ProductCategoryModel.fromMap(Map<String, dynamic> map,
      {required String id}) {
    List<ProductCategoryModel> subCategories = [];
    if (map['subCategories'] != null && map['subCategories'] is List) {
      subCategories = (map['subCategories'] as List)
          .map((e) => ProductCategoryModel.fromMap(
                Map<String, dynamic>.from(e),
                id: e['categoryId'] ?? '',
              ))
          .toList();
    }
    return ProductCategoryModel(
      categoryId: id,
      categoryName: map['categoryName'] ?? '',
      subCategories: subCategories,
    );
  }

  ProductCategoryModel copyWith({
    String? categoryId,
    String? categoryName,
    List<ProductCategoryModel>? subCategories,
  }) {
    return ProductCategoryModel(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subCategories: subCategories ?? this.subCategories,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductCategoryModel &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName &&
        listEquals(other.subCategories, subCategories);
  }

  @override
  int get hashCode =>
      categoryId.hashCode ^ categoryName.hashCode ^ subCategories.hashCode;
}