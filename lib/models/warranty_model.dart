import 'package:flutter/foundation.dart';

class WarrantyModel {
  final String? id; 
  final String userId;
  final String productId;
  final String warrantyType;
  final String startDate;
  final String endDate;
  final String purchaseDate;
  final String sellerName; 
  final String? invoiceFilePath; 
  final String? certificateFilePath;
  final String? notes; 
  final String createdAt; 

  WarrantyModel({
    this.id,
    required this.userId,
    required this.productId,
    required this.warrantyType,
    required this.startDate,
    required this.endDate,
    required this.purchaseDate,
    required this.sellerName,
    this.invoiceFilePath,
    this.certificateFilePath,
    this.notes,
    required this.createdAt,
  });

 
  factory WarrantyModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return WarrantyModel(
      id: id ?? data['warrantyID'], // Utilisez l'ID passé ou celui dans la Map
      userId: data['addedBy'] ?? '', // Assurez-vous que 'addedBy' correspond à l'userId
      productId: data['product']['productID'] ?? '', // Accédez à l'ID du produit imbriqué
      warrantyType: data['warrantyType'] ?? '',
      startDate: data['warrantyStartDate'] ?? '',
      endDate: data['warrantyEndDate'] ?? '',
      purchaseDate: data['purchaseDate'] ?? '',
      sellerName: data['sellerName'] ?? '',
      invoiceFilePath: data['copyOfBill'],
      certificateFilePath: data['copyOfWarrantyCertif'],
      notes: data['note'],
      createdAt: data['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'] is int ? data['timestamp'] : int.parse(data['timestamp'].toString())).toIso8601String() : DateTime.now().toIso8601String(), 
    );
  }

 
  Map<String, dynamic> toJson() {
    return {
      'warrantyID': id,
      'addedBy': userId,
      'productId': productId, 
      'warrantyType': warrantyType,
      'warrantyStartDate': startDate,
      'warrantyEndDate': endDate,
      'purchaseDate': purchaseDate,
      'sellerName': sellerName,
      'copyOfBill': invoiceFilePath,
      'copyOfWarrantyCertif': certificateFilePath,
      'note': notes,
      'timestamp': DateTime.parse(createdAt).millisecondsSinceEpoch, 
    };
  }
}