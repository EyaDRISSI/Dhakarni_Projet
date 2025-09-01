
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../add-w-widgets/custom_text_field.dart';

class ProductInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController productNameController;
  final TextEditingController priceController;
  final TextEditingController manufactureDateController;
  final TextEditingController referenceController;
  final TextEditingController supplierController;
  final String? selectedCategory;
  final String? selectedSubCategory;
  final VoidCallback onCategoryTap;
  final String? selectedWarrantyType;
  final VoidCallback onWarrantyTypeTap;
  final File? productPhoto;
  final Function(ImageSource) onPickImage;
  final VoidCallback onSelectManufactureDate;

  const ProductInfoStep({
    Key? key,
    required this.formKey,
    required this.productNameController,
    required this.priceController,
    required this.manufactureDateController,
    required this.referenceController,
    required this.supplierController,
    this.selectedCategory,
    this.selectedSubCategory,
    required this.onCategoryTap,
    required this.selectedWarrantyType,
    required this.onWarrantyTypeTap,
    required this.productPhoto,
    required this.onPickImage,
    required this.onSelectManufactureDate,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    String categoryDisplay = '';
    if (selectedCategory != null && selectedSubCategory != null) {
      categoryDisplay = '$selectedCategory > $selectedSubCategory';
    } else if (selectedCategory != null) {
      categoryDisplay = selectedCategory!;
    }

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Informations du Produit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Commencez par saisir les informations de base sur votre produit.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: productNameController,
            labelText: 'Nom du produit',
            hintText: 'Choisissez un nom pour votre produit',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le nom du produit';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          CustomTextField(
            controller: TextEditingController(text: categoryDisplay),
            labelText: 'Catégorie du produit',
            hintText: 'Choisir',
            suffixIcon: const Icon(Icons.arrow_forward_ios,
                color: Colors.black54, size: 20),
            readOnly: true,
            onTap: onCategoryTap,
            validator: (value) {
              if (selectedSubCategory == null || selectedSubCategory!.isEmpty) {
                return 'Veuillez sélectionner une catégorie';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          const Text(
            'Photo du produit',
            style: TextStyle(
                fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: productPhoto == null
                ? ElevatedButton.icon(
              onPressed: () => onPickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_camera,
                  color: Color.fromARGB(255, 132, 131, 131)),
              label: const Text('Prendre une photo',
                  style: TextStyle(color: Color.fromARGB(255, 133, 133, 133))),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 235, 235, 235),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
              ),
            )
                : Column(
              children: [
                Image.file(
                  productPhoto!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                Text(
                  productPhoto!.path.split('/').last,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => onPickImage(ImageSource.gallery),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                  child: const Text('Modifier la photo'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          CustomTextField(
            controller: priceController,
            labelText: 'Prix (en TND)',
            hintText: 'Entrez le prix du produit',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le prix';
              }
              if (double.tryParse(value) == null) {
                return 'Veuillez entrer un nombre valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          CustomTextField(
            controller: referenceController,
            labelText: 'Référence',
            hintText: 'Entrez la référence du produit',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer la référence';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          CustomTextField(
            controller: manufactureDateController,
            labelText: 'Date de fabrication',
            hintText: 'JJ/MM/AAAA',
            readOnly: true,
            onTap: onSelectManufactureDate,
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez sélectionner la date de fabrication';
              }
              try {
                final dateFormat = DateFormat('dd/MM/yyyy');
                final manufactureDate = dateFormat.parse(value);
                final now = DateTime.now();
                if (manufactureDate.isAfter(now)) {
                  return 'La date de fabrication ne peut pas être dans le futur';
                }
              } catch (e) {
                return 'Format de date invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          CustomTextField(
            controller: supplierController,
            labelText: 'Fournisseur',
            hintText: 'Nom du fournisseur',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le nom du fournisseur';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          CustomTextField(
            controller: TextEditingController(text: selectedWarrantyType ?? ''),
            labelText: 'Type de Garantie',
            hintText: 'Choisir',
            suffixIcon: const Icon(Icons.arrow_forward_ios,
                color: Colors.black54, size: 20),
            readOnly: true,
            onTap: onWarrantyTypeTap,
            validator: (value) {
              if (selectedWarrantyType == null || selectedWarrantyType!.isEmpty) {
                return 'Veuillez sélectionner un type de garantie';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}