import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../models/notification_model.dart';
import '../models/warranty_model.dart';
import '../pages/Notification/notification_success_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:math' hide log;
import 'dart:developer';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationController extends GetxController {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  RxBool isDefaultNotificationEnabled = false.obs;
  RxString notificationType = 'Unique'.obs;
  Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  final List<String> notificationTypes = [
    'Unique',
    'Hebdomadaire',
    'Mensuel',
    'Annuel',
  ];

  RxInt notificationCount = 0.obs;
  StreamSubscription<DatabaseEvent>? _notificationsSubscription;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _listenToNotifications();
      } else {
        notifications.clear();
        _notificationsSubscription?.cancel();
      }
    });
  }

  @override
  void onClose() {
    _notificationsSubscription?.cancel();
    super.onClose();
  }

  void resetState() {
    isDefaultNotificationEnabled.value = false;
    notificationType.value = 'Unique';
    selectedDateTime.value = null;
    errorMessage.value = '';
    isLoading.value = false;
  }

  void toggleDefaultNotification(bool value) {
    isDefaultNotificationEnabled.value = value;
  }

  Future<void> fetchNotifications() async {
    _listenToNotifications();
  }

  void _listenToNotifications() {
    final user = _auth.currentUser;
    if (user == null) {
      notifications.clear();
      _notificationsSubscription?.cancel();
      return;
    }

    _notificationsSubscription?.cancel();

    final notificationsRef = _database.ref('notifications_by_user/${user.uid}');
    isLoading.value = true;
    errorMessage.value = '';

    _notificationsSubscription = notificationsRef.onValue.listen((event) {
      final List<NotificationModel> fetchedList = [];
      final dynamic data = event.snapshot.value;

      if (data != null && data is Map) {
        final notificationsData = Map<String, dynamic>.from(data);
        notificationsData.forEach((key, value) {
          final notificationMap = Map<String, dynamic>.from(value);
          fetchedList.add(NotificationModel.fromMap(notificationMap, id: key));
        });
      }

      fetchedList.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
      notifications.assignAll(fetchedList);
      notificationCount.value = notifications.length;
      log('DEBUG: Notifications mises à jour via le stream. Nombre: ${notifications.length}');
      isLoading.value = false;
    }, onError: (Object error) {
      log('Échec de l\'écoute des notifications : $error');
      errorMessage.value = 'Échec du chargement des notifications.';
      Get.snackbar('Erreur', 'Échec de la mise à jour des notifications.',
          backgroundColor: Colors.red, colorText: Colors.white);
      isLoading.value = false;
    });
  }

  Future<void> saveNotification({
    required WarrantyModel warranty,
    required String? reminderName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Erreur', 'Utilisateur non authentifié.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (isDefaultNotificationEnabled.value) {
        final endDate = warranty.endDate;
        if (endDate == null) {
          errorMessage.value = 'La date de fin de garantie est manquante.';
          Get.snackbar('Erreur', 'La date de fin de garantie est manquante.',
              backgroundColor: Colors.red, colorText: Colors.white);
          isLoading.value = false;
          return;
        }

        final now = DateTime.now();
        final oneMonthBefore = endDate.subtract(const Duration(days: 30));
        final twoWeeksBefore = endDate.subtract(const Duration(days: 14));

        if (oneMonthBefore.isAfter(now)) {
          await _saveSingleNotification(
            userId: user.uid,
            warrantyId: warranty.id!,
            productId: warranty.productId,
            primaryEvent: 'default',
            customName: 'Rappel de pré-expiration (1 mois)',
            type: 'Unique',
            scheduledDate: oneMonthBefore,
          );
        }

        if (twoWeeksBefore.isAfter(now)) {
          await _saveSingleNotification(
            userId: user.uid,
            warrantyId: warranty.id!,
            productId: warranty.productId,
            primaryEvent: 'default',
            customName: 'Rappel de pré-expiration (2 semaines)',
            type: 'Unique',
            scheduledDate: twoWeeksBefore,
          );
        }
      } else {
        if (selectedDateTime.value == null || reminderName == null || reminderName.isEmpty) {
          errorMessage.value = 'Veuillez remplir tous les champs du rappel personnalisé.';
          Get.snackbar('Erreur',
              'Veuillez remplir tous les champs du rappel personnalisé.',
              backgroundColor: Colors.red, colorText: Colors.white);
          isLoading.value = false;
          return;
        }
        await _saveSingleNotification(
          userId: user.uid,
          warrantyId: warranty.id!,
          productId: warranty.productId,
          primaryEvent: 'custom',
          customName: reminderName,
          type: notificationType.value,
          scheduledDate: selectedDateTime.value!,
        );
      }

      isLoading.value = false;
      Get.off(() => NotificationSuccessPage(warranty: warranty));

    } catch (e) {
      errorMessage.value = 'Échec de l\'enregistrement des notifications: $e';
      log('ERREUR: Échec de l\'enregistrement des notifications: $e');
      Get.snackbar('Erreur', 'Échec de l\'enregistrement des notifications: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      isLoading.value = false;
    }
  }

  Future<void> _saveSingleNotification({
    required String userId,
    required String warrantyId,
    required String productId,
    required String primaryEvent,
    String? customName,
    required String type,
    required DateTime scheduledDate,
  }) async {
    final notificationId = Random().nextInt(1000000);

    final notification = NotificationModel(
      id: notificationId.toString(),
      userId: userId,
      warrantyId: warrantyId,
      productId: productId,
      primaryEvent: primaryEvent,
      customName: customName,
      type: type,
      scheduledDate: scheduledDate,
    );

    final newNotificationRef = _database
        .ref()
        .child('notifications_by_user')
        .child(userId)
        .push();
    await newNotificationRef.set(notification.toMap());

    if (scheduledDate.isAfter(DateTime.now())) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'warranty_channel',
        'Rappels de Garantie',
        channelDescription: 'Canal pour les rappels de garanties',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          'Rappel de Garantie',
          customName ?? 'Rappel pour votre garantie',
          tz.TZDateTime.from(scheduledDate, tz.local),
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        log('DEBUG: Notification locale planifiée pour $scheduledDate avec l\'ID $notificationId.');
      } catch (e) {
        log('ERREUR: Échec de la planification de la notification locale : $e');
        throw e;
      }
    } else {
      log('ATTENTION: La date de la notification est dans le passé, elle ne sera pas planifiée.');
    }
  }

  Future<void> deleteNotificationsForWarranty(String warrantyId) async {
    final user = _auth.currentUser;
    if (user == null) {
      log('User not authenticated. Cannot delete notifications.');
      return;
    }

    try {
      final notificationsRef = _database.ref('notifications_by_user/${user.uid}');
      final snapshot = await notificationsRef.orderByChild('warrantyId').equalTo(warrantyId).once();

      if (snapshot.snapshot.value != null) {
        final notificationsData = snapshot.snapshot.value as Map<dynamic, dynamic>;

        for (var notificationKey in notificationsData.keys) {
          final notificationData = Map<String, dynamic>.from(notificationsData[notificationKey]);
          final notificationId = int.tryParse(notificationData['id'] as String? ?? '');

          if (notificationId != null) {
            await flutterLocalNotificationsPlugin.cancel(notificationId);
            log('DEBUG: Notification locale avec l\'ID $notificationId annulée.');
          }

          await notificationsRef.child(notificationKey).remove();
        }
        log('DEBUG: Toutes les notifications pour la garantie $warrantyId ont été supprimées avec succès.');
      }
    } catch (e) {
      log('ERREUR: Échec de la suppression des notifications pour la garantie $warrantyId: $e');
    }
  }

  Future<void> deleteNotificationsByWarrantyId(String warrantyId) async {
    final user = _auth.currentUser;
    if (user == null) {
      log('User not authenticated. Cannot delete notifications.');
      return;
    }

    try {
      final notificationsRef = _database.ref('notifications_by_user/${user.uid}');
      final snapshot =
          await notificationsRef.orderByChild('warrantyId').equalTo(warrantyId).once();

      if (snapshot.snapshot.value != null) {
        final notificationsData = snapshot.snapshot.value as Map<dynamic, dynamic>;
        for (var notificationKey in notificationsData.keys) {
          final notificationRef = notificationsRef.child(notificationKey);
          await notificationRef.remove();
        }
        log('DEBUG: All notifications for warranty $warrantyId deleted successfully.');
      }
    } catch (e) {
      log('ERREUR: Échec de la suppression des notifications pour la garantie $warrantyId: $e');
    }
  }
}