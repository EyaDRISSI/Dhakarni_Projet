import 'product_model.dart';

class WarrantyModel {
  String? id;
  String userId;
  String productId;
  String warrantyType;
  DateTime? startDate;  
  DateTime? endDate; 
  DateTime? purchaseDate; 
  String sellerName;
  String? invoiceFilePath;
  String? certificateFilePath;
  String? notes;
  DateTime? createdAt; 
  ProductModel? product;

  WarrantyModel({
    this.id,
    required this.userId,
    required this.productId,
    required this.warrantyType,
    this.startDate,
    this.endDate,
    this.purchaseDate,
    required this.sellerName,
    this.invoiceFilePath,
    this.certificateFilePath,
    this.notes,
    this.createdAt,
    this.product,
  });

  factory WarrantyModel.fromMap(Map<String, dynamic> data, {String? id}) {
    ProductModel? productData;
    final productMap = data['product'];
    if (productMap != null && productMap is Map) {
      try {
        productData = ProductModel.fromMap(
          Map<String, dynamic>.from(productMap),
          id: data['productId'] as String? ?? '',
        );
      } catch (e) {
        print('Erreur lors de la désérialisation du produit: $e');
      }
    }

    return WarrantyModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      productId: data['productId'] as String? ?? '',
      warrantyType: data['warrantyType'] as String? ?? '',
      startDate: data['warrantyStartDate'] != null ? DateTime.fromMillisecondsSinceEpoch(data['warrantyStartDate'] as int) : null,
  endDate: data['warrantyEndDate'] != null ? DateTime.fromMillisecondsSinceEpoch(data['warrantyEndDate'] as int) : null,
  purchaseDate: data['purchaseDate'] != null ? DateTime.fromMillisecondsSinceEpoch(data['purchaseDate'] as int) : null,
      sellerName: data['sellerName'] as String? ?? '',
      invoiceFilePath: data['invoiceFilePath'] as String?,
      certificateFilePath: data['certificateFilePath'] as String?,
      notes: data['notes'] as String?,
      createdAt: data['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int) : null,
      product: productData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'warrantyType': warrantyType,
      'warrantyStartDate': startDate?.millisecondsSinceEpoch,
      'warrantyEndDate': endDate?.millisecondsSinceEpoch,
      'purchaseDate': purchaseDate?.millisecondsSinceEpoch,
      'sellerName': sellerName,
      'invoiceFilePath': invoiceFilePath,
      'certificateFilePath': certificateFilePath,
      'notes': notes,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'product': product?.toJson(),
    };
  }

  WarrantyModel copyWith({
    String? id,
    String? userId,
    String? productId,
    String? warrantyType,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? purchaseDate,
    String? sellerName,
    String? invoiceFilePath,
    String? certificateFilePath,
    String? notes,
    DateTime? createdAt,
    ProductModel? product,
  }) {
    return WarrantyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      warrantyType: warrantyType ?? this.warrantyType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      sellerName: sellerName ?? this.sellerName,
      invoiceFilePath: invoiceFilePath ?? this.invoiceFilePath,
      certificateFilePath: certificateFilePath ?? this.certificateFilePath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      product: product ?? this.product,
    );
  }
}