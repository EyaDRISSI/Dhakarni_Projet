import 'package:flutter/material.dart';

class ProductModel {
  final String productId;
  final String productName;
  final double price;
  final String reference;
  final String productCategoryId;
  final String? productPhotoUrl; 
  final String? manufacturingDate; 
  final String? supplier; 

  ProductModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.reference,
    required this.productCategoryId,
    this.productPhotoUrl,
    this.manufacturingDate, 
    this.supplier, 
  });

  // Convertit un objet ProductModel en Map pour Firebase Realtime Database
  Map<String, dynamic> toJson() {
    return {
      'productID': productId, 
      'productName': productName,
      'price': price,
      'reference': reference,
      'productCategoryId': productCategoryId,
      'productPhotoUrl': productPhotoUrl,
      'manufacturingDate': manufacturingDate, 
      'supplier': supplier, 
    };
  }

  // Crée un objet ProductModel à partir d'un Map de Firebase Realtime Database
  factory ProductModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return ProductModel(
      productId: id, 
      productName: map['productName'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      reference: map['reference'] ?? '',
      productCategoryId: map['productCategoryId'] ?? '',
      productPhotoUrl: map['productPhotoUrl'],
      manufacturingDate: map['manufacturingDate'], 
      supplier: map['supplier'], 
    );
  }
}