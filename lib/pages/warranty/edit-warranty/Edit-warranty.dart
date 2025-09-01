import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../../../controller/warranty_controller.dart';
import '../../../../models/warranty_model.dart';
import '../../../../controller/product_controller.dart';
import '../../../../models/product_category_model.dart';
import '../add-warranty/steps/success_warranty_page.dart';

class EditWarrantyPage extends StatefulWidget {
  final WarrantyModel warranty;

  const EditWarrantyPage({Key? key, required this.warranty}) : super(key: key);

  @override
  State<EditWarrantyPage> createState() => _EditWarrantyPageState();
}

class _EditWarrantyPageState extends State<EditWarrantyPage> {
  final WarrantyController warrantyController = Get.find<WarrantyController>();
  final ProductController productController = Get.find<ProductController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _productNameController;
  late TextEditingController _priceController;
  late TextEditingController _manufactureDateController;
  late TextEditingController _referenceController;
  late TextEditingController _supplierController;
  late TextEditingController _purchaseDateController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _sellerNameController;
  late TextEditingController _notesController;

  String? _selectedCategoryName;
  String? _selectedSubCategoryName;
  String? _selectedWarrantyType;

  File? _newProductPhotoFile;
  File? _newInvoiceFile;
  File? _newCertificateFile;

  final List<String> _warrantyTypes = [
    'Garantie du Fabricant',
    'Garantie Étendue',
    'Garantie Commerciale',
    'Garantie Constructeur',
    'Garantie Pièces et Main d\'Œuvre',
    'Garantie Satisfait ou Remboursé',
    'Garantie Protection des Achats',
    'Garantie Service Après-Vente',
    'Garantie de Remplacement',
    'Garantie Limitée',
  ];

  @override
  void initState() {
    super.initState();

    _productNameController = TextEditingController(text: widget.warranty.product?.productName);
    _priceController = TextEditingController(text: widget.warranty.product?.price.toString() ?? '');
    _manufactureDateController = TextEditingController(
      text: _formatDateForInput(widget.warranty.product?.manufacturingDate),
    );
    _referenceController = TextEditingController(text: widget.warranty.product?.reference);
    _supplierController = TextEditingController(text: widget.warranty.product?.supplier);
    _purchaseDateController = TextEditingController(text: _formatDateForInput(widget.warranty.purchaseDate));
    _startDateController = TextEditingController(text: _formatDateForInput(widget.warranty.startDate));
    _endDateController = TextEditingController(text: _formatDateForInput(widget.warranty.endDate));
    _sellerNameController = TextEditingController(text: widget.warranty.sellerName);
    _notesController = TextEditingController(text: widget.warranty.notes);

    final productCategory = widget.warranty.product?.productCategory;
    if (productCategory != null) {
      if (productCategory.subCategories.isNotEmpty) {
        _selectedCategoryName = productCategory.categoryName;
        _selectedSubCategoryName = productCategory.subCategories.first.categoryName;
      } else {
        _selectedCategoryName = productCategory.categoryName;
        _selectedSubCategoryName = null;
      }
    }

    _selectedWarrantyType = _warrantyTypes.contains(widget.warranty.warrantyType)
        ? widget.warranty.warrantyType
        : null;
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _manufactureDateController.dispose();
    _referenceController.dispose();
    _supplierController.dispose();
    _purchaseDateController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _sellerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDateForInput(dynamic date) {
    if (date == null) return '';
    DateTime parsedDate;
    if (date is DateTime) {
      parsedDate = date;
    } else if (date is String) {
      try {
        parsedDate = DateTime.parse(date);
      } catch (e) {
        try {
          final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
          parsedDate = inputFormat.parse(date);
        } catch (e) {
          return '';
        }
      }
    } else {
      return '';
    }
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  DateTime? _parseDateFromInput(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  DateTime _parseDateForDatePicker(String? date) {
    if (date == null || date.isEmpty) {
      return DateTime.now();
    }
    try {
      return DateFormat('dd/MM/yyyy').parse(date);
    } catch (e) {
      return DateTime.now();
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _parseDateForDatePicker(controller.text),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE91E63),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> _pickFile(Function(File?) onFileSelected) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      final file = File(result.files.single.path!);
      onFileSelected(file);
    } else {
      onFileSelected(null);
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      warrantyController.isLoading.value = true;

      try {
        final DateTime? purchaseDate = _parseDateFromInput(_purchaseDateController.text);
        final DateTime? startDate = _parseDateFromInput(_startDateController.text);
        final DateTime? endDate = _parseDateFromInput(_endDateController.text);
        final DateTime? manufactureDate = _parseDateFromInput(_manufactureDateController.text);

        if (purchaseDate == null || startDate == null || endDate == null) {
          throw Exception("Une ou plusieurs dates sont invalides.");
        }

        final updatedProduct = widget.warranty.product?.copyWith(
          productName: _productNameController.text,
          price: double.tryParse(_priceController.text) ?? 0.0,
          manufacturingDate: manufactureDate?.toIso8601String(),
          reference: _referenceController.text,
          supplier: _supplierController.text,
          productCategory: _getProductCategoryModel(),
          productPhotoUrl: _newProductPhotoFile?.path ?? widget.warranty.product?.productPhotoUrl,
        );

        final updatedWarranty = widget.warranty.copyWith(
          product: updatedProduct,
          purchaseDate: purchaseDate,
          startDate: startDate,
          endDate: endDate,
          warrantyType: _selectedWarrantyType,
          sellerName: _sellerNameController.text,
          invoiceFilePath: _newInvoiceFile?.path ?? widget.warranty.invoiceFilePath,
          certificateFilePath: _newCertificateFile?.path ?? widget.warranty.certificateFilePath,
          notes: _notesController.text,
        );

        await warrantyController.updateWarranty(
          updatedWarranty: updatedWarranty,
          productPhotoFile: _newProductPhotoFile,
          invoiceFile: _newInvoiceFile,
          certificateFile: _newCertificateFile,
        );

        Get.off(() => SuccessWarrantyPage(newWarranty: updatedWarranty));
        Get.snackbar(
          'Succès',
          'Garantie mise à jour avec succès.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Échec de la mise à jour de la garantie: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        warrantyController.isLoading.value = false;
      }
    }
  }

  ProductCategoryModel? _getProductCategoryModel() {
    if (_selectedCategoryName != null) {
      final parentCat = productController.productCategories.firstWhereOrNull(
            (cat) => cat.categoryName == _selectedCategoryName,
      );
      if (parentCat != null) {
        if (_selectedSubCategoryName != null) {
          final subCategory = parentCat.subCategories.firstWhereOrNull(
                (sub) => sub.categoryName == _selectedSubCategoryName,
          );
          if (subCategory != null) {
            return ProductCategoryModel(
              categoryId: parentCat.categoryId,
              categoryName: parentCat.categoryName,
              subCategories: [subCategory],
            );
          }
        } else {
          return parentCat;
        }
      }
    }
    return null;
  }

  void _showCategorySelection() {
    Get.bottomSheet(
      SizedBox(
        height: Get.height * 0.7,
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (productController.isLoadingCategories.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: productController.productCategories.length,
                  itemBuilder: (context, index) {
                    ProductCategoryModel category = productController.productCategories[index];
                    return ListTile(
                      title: Text(category.categoryName),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 20),
                      onTap: () {
                        Get.back();
                        _showSubCategorySelection(category);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 20,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void _showSubCategorySelection(ProductCategoryModel category) {
    List<String> subCategoryNames = category.subCategories.map((e) => e.categoryName).toList();
    Get.bottomSheet(
      SizedBox(
        height: Get.height * 0.6,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: subCategoryNames.length,
                itemBuilder: (context, index) {
                  final subCategory = subCategoryNames[index];
                  return ListTile(
                    title: Text(subCategory),
                    trailing: _selectedSubCategoryName == subCategory
                        ? const Icon(Icons.check, color: Color(0xFFE91E63))
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCategoryName = category.categoryName;
                        _selectedSubCategoryName = subCategory;
                      });
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 20,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void _showWarrantyTypeSelection() {
    Get.bottomSheet(
      SizedBox(
        height: Get.height * 0.6,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _warrantyTypes.length,
                itemBuilder: (context, index) {
                  final type = _warrantyTypes[index];
                  return ListTile(
                    title: Text(type),
                    trailing: _selectedWarrantyType == type
                        ? const Icon(Icons.check, color: Color(0xFFE91E63))
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedWarrantyType = type;
                      });
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 20,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Modifier la Garantie', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFE91E63)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informations sur le Produit'),
              _buildTextField(
                label: 'Nom du produit',
                controller: _productNameController,
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              _buildTextField(
                label: 'Prix',
                controller: _priceController,
                keyboardType: TextInputType.number,
              ),
              _buildDateField(
                label: 'Date de fabrication',
                controller: _manufactureDateController,
                onTap: () => _selectDate(_manufactureDateController),
              ),
              _buildTextField(
                label: 'Référence',
                controller: _referenceController,
              ),
              _buildTextField(
                label: 'Fournisseur',
                controller: _supplierController,
              ),
              _buildFilePickerField(
                label: 'Photo du produit',
                currentFileUrl: widget.warranty.product?.productPhotoUrl,
                onFilePicked: (file) {
                  setState(() {
                    _newProductPhotoFile = file;
                  });
                },
                newFile: _newProductPhotoFile,
              ),

              const SizedBox(height: 20),
              _buildSectionTitle('Informations de la Garantie'),
              _buildDateField(
                label: 'Date d\'achat',
                controller: _purchaseDateController,
                onTap: () => _selectDate(_purchaseDateController),
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              _buildDateField(
                label: 'Date de début de garantie',
                controller: _startDateController,
                onTap: () => _selectDate(_startDateController),
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              _buildDateField(
                label: 'Date de fin de garantie',
                controller: _endDateController,
                onTap: () => _selectDate(_endDateController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Champ requis';
                  }
                  try {
                    final startDate = DateFormat('dd/MM/yyyy').parse(_startDateController.text);
                    final endDate = DateFormat('dd/MM/yyyy').parse(value);
                    if (endDate.isBefore(startDate)) {
                      return 'La date de fin doit être après la date de début';
                    }
                  } catch (e) {
                    return 'Format de date invalide';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: 'Vendeur',
                controller: _sellerNameController,
              ),
              _buildCategoryDropdown(),
              if (_selectedCategoryName != null &&
                      productController.productCategories.firstWhereOrNull(
                                  (cat) => cat.categoryName == _selectedCategoryName
                              )?.subCategories.isNotEmpty ==
                          true)
                _buildSubCategoryDropdown(),
              _buildWarrantyTypeDropdown(),

              const SizedBox(height: 20),
              _buildSectionTitle('Documents & Notes'),
              _buildFilePickerField(
                label: 'Facture',
                currentFileUrl: widget.warranty.invoiceFilePath,
                onFilePicked: (file) {
                  setState(() {
                    _newInvoiceFile = file;
                  });
                },
                newFile: _newInvoiceFile,
              ),
              _buildFilePickerField(
                label: 'Certificat de garantie',
                currentFileUrl: widget.warranty.certificateFilePath,
                onFilePicked: (file) {
                  setState(() {
                    _newCertificateFile = file;
                  });
                },
                newFile: _newCertificateFile,
              ),
              _buildTextField(
                label: 'Notes',
                controller: _notesController,
                maxLines: 3,
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: Obx(() => warrantyController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Enregistrer les modifications',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE91E63), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.grey.shade50,
          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFFE91E63)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE91E63), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFE91E63), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE91E63)),
              items: items.map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(color: Colors.black87)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return _buildDropdownField(
      label: 'Catégorie',
      value: _selectedCategoryName,
      items: productController.productCategories.map((e) => e.categoryName).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedCategoryName = newValue;
          _selectedSubCategoryName = null;
        });
      },
      validator: (value) => value == null ? 'Veuillez sélectionner une catégorie' : null,
      onTap: _showCategorySelection,
    );
  }

  Widget _buildSubCategoryDropdown() {
    if (_selectedCategoryName == null) return const SizedBox.shrink();

    final mainCategory = productController.productCategories.firstWhereOrNull(
            (cat) => cat.categoryName == _selectedCategoryName,
    );

    if (mainCategory == null || mainCategory.subCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    final subCategoryNames = mainCategory.subCategories.map((sub) => sub.categoryName).toList();

    return _buildDropdownField(
      label: 'Sous-catégorie',
      value: _selectedSubCategoryName,
      items: subCategoryNames,
      onChanged: (newValue) {
        setState(() {
          _selectedSubCategoryName = newValue;
        });
      },
      validator: (value) => value == null ? 'Veuillez sélectionner une sous-catégorie' : null,
      onTap: () => _showSubCategorySelection(mainCategory),
    );
  }

  Widget _buildWarrantyTypeDropdown() {
    return _buildDropdownField(
      label: 'Type de garantie',
      value: _selectedWarrantyType,
      items: _warrantyTypes,
      onChanged: (newValue) {
        setState(() {
          _selectedWarrantyType = newValue;
        });
      },
      validator: (value) => value == null ? 'Veuillez sélectionner un type de garantie' : null,
      onTap: _showWarrantyTypeSelection,
    );
  }

  Widget _buildFilePickerField({
    required String label,
    String? currentFileUrl,
    required Function(File?) onFilePicked,
    File? newFile,
  }) {
    String fileName = 'Aucun fichier sélectionné';
    String? displayPath;
    if (newFile != null) {
      displayPath = newFile.path;
    } else if (currentFileUrl != null && currentFileUrl.isNotEmpty) {
      displayPath = currentFileUrl;
    }

    if (displayPath != null) {
      try {
        fileName = displayPath.split('/').last;
        final parts = fileName.split('_');
        if (parts.length > 1) {
          fileName = parts.sublist(1).join('_');
        }
      } catch (e) {
        fileName = 'Fichier';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    fileName,
                    style: TextStyle(color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.upload_file, color: Color(0xFFE91E63)),
                  onPressed: () => _pickFile(onFilePicked),
                  tooltip: 'Choisir un fichier',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}