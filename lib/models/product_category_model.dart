class ProductCategoryModel {
  final String categoryId;
  final String categoryName;
  final List<ProductCategoryModel> subCategories; // Ajout pour les sous-catégories

  ProductCategoryModel({
    required this.categoryId,
    required this.categoryName,
    this.subCategories = const [], 
  });

  factory ProductCategoryModel.fromMap(Map<String, dynamic> data, {String? id}) {
    final String categoryId = id ?? data['categoryId'] ?? '';
    final String categoryName = data['categoryName'] ?? '';

    
    List<ProductCategoryModel> fetchedSubCategories = [];
    if (data['subCategories'] is List) {
      
      for (var subCategoryData in data['subCategories']) {
        if (subCategoryData is Map<dynamic, dynamic>) {
          
          fetchedSubCategories.add(ProductCategoryModel.fromMap(Map<String, dynamic>.from(subCategoryData)));
        }
      }
    } else if (data['subCategories'] is Map) {
     
      (data['subCategories'] as Map<dynamic, dynamic>).forEach((subId, subValue) {
        if (subValue is Map<dynamic, dynamic>) {
          fetchedSubCategories.add(ProductCategoryModel.fromMap(Map<String, dynamic>.from(subValue), id: subId));
        }
      });
    }

    return ProductCategoryModel(
      categoryId: categoryId,
      categoryName: categoryName,
      subCategories: fetchedSubCategories,
    );
  }

 
  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'subCategories': subCategories.map((sub) => sub.toJson()).toList(),
    };
  }
}