import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; 
import 'package:intl/intl.dart';
import '../../../models/notification_model.dart';

class RemindersTabContent extends StatelessWidget {
  final String warrantyId;

  const RemindersTabContent({Key? key, required this.warrantyId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Utilisateur non authentifié.'));
    }

    final notificationsRef = FirebaseDatabase.instance
        .ref('notifications_by_user')
        .child(user.uid)
        .orderByChild('warrantyId')
        .equalTo(warrantyId);

    return StreamBuilder(
      stream: notificationsRef.onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('Aucun rappel programmé.'));
        }

        final Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        final notifications = data.entries
            .map((entry) => NotificationModel.fromMap(entry.value, id: entry.key))
            .toList();

        notifications.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildReminderCard(
              notification.customName ?? 'Rappel',
              DateFormat('dd-MM-yyyy à HH:mm').format(notification.scheduledDate),
              notification.infoDescription ?? '',
            );
          },
        );
      },
    );
  }

  Widget _buildReminderCard(String title, String date, String subtitle) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF333333))),
          const SizedBox(height: 4),
          Text(date,
              style: const TextStyle(fontSize: 14, color: Color(0xFFE91E63))),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(fontSize: 14, color: Color(0xFF888888))),
        ],
      ),
    );
  }
}