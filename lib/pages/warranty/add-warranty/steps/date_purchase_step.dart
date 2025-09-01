import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../add-w-widgets/custom_text_field.dart';

class DatePurchaseStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController purchaseDateController;
  final TextEditingController sellerNameController;
  final Function(TextEditingController) onSelectDate;

  const DatePurchaseStep({
    super.key,
    required this.formKey,
    required this.startDateController,
    required this.endDateController,
    required this.purchaseDateController,
    required this.sellerNameController,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const SizedBox(height: 20),
          const Text(
            'Dates et Achats',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Indiquez les dates pertinentes et les détails d achat de votre produit.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: startDateController,
            labelText: 'Date de début de garantie',
            hintText: 'JJ/MM/AAAA',
            readOnly: true,
            onTap: () => onSelectDate(startDateController),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez sélectionner la date de début de garantie';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: endDateController,
            labelText: 'Date de fin de garantie',
            hintText: 'JJ/MM/AAAA',
            readOnly: true,
            onTap: () => onSelectDate(endDateController),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez sélectionner la date de fin de garantie';
              }
              try {
                final dateFormat = DateFormat('dd/MM/yyyy'); 
                final start = dateFormat.parse(startDateController.text);
                final end = dateFormat.parse(value);
                if (end.isBefore(start)) {
                  return 'La date de fin ne peut pas être antérieure à la date de début';
                }
              } catch (e) {
                return 'Format de date invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: purchaseDateController,
            labelText: 'Date d\'achat',
            hintText: 'JJ/MM/AAAA',
            readOnly: true,
            onTap: () => onSelectDate(purchaseDateController),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez sélectionner la date d\'achat';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: sellerNameController,
            labelText: 'Nom du vendeur',
            hintText: 'Ex: Darty, Fnac...',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le nom du vendeur';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}