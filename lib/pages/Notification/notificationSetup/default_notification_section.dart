import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/warranty_model.dart';

class DefaultNotificationSection extends StatelessWidget {
  final WarrantyModel warranty;

  const DefaultNotificationSection({Key? key, required this.warranty}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final endDate = warranty.endDate;
    
  
    if (endDate == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "Erreur: Date de fin de garantie manquante.",
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    final now = DateTime.now();
    final oneMonthBefore = endDate.subtract(const Duration(days: 30));
    final twoWeeksBefore = endDate.subtract(const Duration(days: 14));

    if (oneMonthBefore.isBefore(now) && twoWeeksBefore.isBefore(now)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "La garantie est déjà expirée ou expire dans moins de deux semaines. Les notifications par défaut ne peuvent pas être configurées.",
          style: TextStyle(color: Color(0xFFE91E63), fontSize: 16),
        ),
      );
    }

    final List<Widget> reminderCards = [];
    
    if (oneMonthBefore.isAfter(now)) {
      reminderCards.add(_buildDefaultReminderCard(
        'Rappel de Préexpiration 1',
        DateFormat('dd-MM-yyyy').format(oneMonthBefore),
        '(Un mois avant la fin de la garantie)',
      ));
    }

    if (reminderCards.isNotEmpty && twoWeeksBefore.isAfter(now)) {
      reminderCards.add(const SizedBox(height: 16));
    }
    
    if (twoWeeksBefore.isAfter(now)) {
      reminderCards.add(_buildDefaultReminderCard(
        'Rappel de Préexpiration 2',
        DateFormat('dd-MM-yyyy').format(twoWeeksBefore),
        '(Deux semaines avant la fin de la garantie)',
      ));
    }
    
    if(reminderCards.isEmpty){
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "La garantie est déjà expirée ou expire dans moins de deux semaines. Les notifications par défaut ne peuvent pas être configurées.",
          style: TextStyle(color: Color(0xFFE91E63), fontSize: 16),
        ),
      );
    }
        return Column(
      children: reminderCards,
    );
  }

  Widget _buildDefaultReminderCard(String title, String date, String subtitle) {
    return Container(
      width: double.infinity,
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF333333))),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontSize: 14, color: Color(0xFFE91E63))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF888888))),
        ],
      ),
    );
  }
}