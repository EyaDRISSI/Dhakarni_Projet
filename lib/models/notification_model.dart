
class NotificationModel {
  final String? id;
  final String userId;
  final String warrantyId;
  final String productId;
  final String primaryEvent;
  final String? customName;
  final String type;
  final DateTime scheduledDate; 
  final String? recipient;
  final String? infoDescription;

  NotificationModel({
    this.id,
    required this.userId,
    required this.warrantyId,
    required this.productId,
    required this.primaryEvent,
    this.customName,
    required this.type,
    required this.scheduledDate,
    this.recipient,
    this.infoDescription,
  });

  factory NotificationModel.fromMap(Map<dynamic, dynamic> data, {String? id}) {
    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      warrantyId: data['warrantyId'] ?? '',
      productId: data['productId'] ?? '',
      primaryEvent: data['primaryEvent'] ?? '',
      customName: data['customName'],
      type: data['type'] ?? '',
      scheduledDate: DateTime.fromMillisecondsSinceEpoch(data['scheduledDate']),
      recipient: data['recipient'],
      infoDescription: data['infoDescription'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'warrantyId': warrantyId,
      'productId': productId,
      'primaryEvent': primaryEvent,
      'customName': customName,
      'type': type,
      'scheduledDate': scheduledDate.millisecondsSinceEpoch,
      'recipient': recipient,
      'infoDescription': infoDescription,
    };
  }
}