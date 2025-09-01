import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/notification_controller.dart';
import '../../../models/notification_model.dart';
import 'notification_details.dart';

class NotificationHistoryPage extends StatelessWidget {
  const NotificationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController notificationController = Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final List<NotificationModel> notifications = notificationController.notifications;

        if (notificationController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (notifications.isEmpty) {
          return const Center(
            child: Text(
              'Aucune notification à afficher.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        final Map<String, List<NotificationModel>> groupedNotifications = {};
        for (var notification in notifications) {
          final String formattedDate = _getFormattedDate(notification.scheduledDate);
          if (!groupedNotifications.containsKey(formattedDate)) {
            groupedNotifications[formattedDate] = [];
          }
          groupedNotifications[formattedDate]!.add(notification);
        }

        final List<String> sortedDates = groupedNotifications.keys.toList()
          ..sort((a, b) => _parseDateString(b).compareTo(_parseDateString(a)));

        return ListView.builder(
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final String date = sortedDates[index];
            final List<NotificationModel> notificationsForDate = groupedNotifications[date]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notificationsForDate.length,
                  itemBuilder: (context, innerIndex) {
                    final notification = notificationsForDate[innerIndex];
                    return _buildNotificationCard(context, notification);
                  },
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel notification) {
    return InkWell(
      onTap: () {
        Get.to(() => NotificationDetailsPage(notification: notification));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.notifications_active, color: Color(0xFFE91E63)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.customName ?? 'Notification de garantie',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Votre garantie ${notification.warrantyId.substring(0, 8)}... arrive à expiration ! Ne manquez pas l\'occasion...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    DateFormat('d MMM yyyy').format(notification.scheduledDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          
          ],
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return 'Aujourd\'hui';
    } else if (notificationDate == yesterday) {
      return 'Hier';
    } else {
      return DateFormat('d MMMM', 'fr_FR').format(date);
    }
  }

  DateTime _parseDateString(String dateString) {
    if (dateString == 'Aujourd\'hui') {
      return DateTime.now();
    } else if (dateString == 'Hier') {
      return DateTime.now().subtract(const Duration(days: 1));
    }
    return DateFormat('d MMMM', 'fr_FR').parse(dateString);
  }
}