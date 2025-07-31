// date_purchase_step.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; 


class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText = '',
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
              fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE91E63)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }
}


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
          const SizedBox(height: 10),
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
                final start = DateFormat('yyyy-MM-dd').parse(startDateController.text);
                final end = DateFormat('yyyy-MM-dd').parse(value);
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