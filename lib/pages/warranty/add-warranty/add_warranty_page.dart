import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

import 'steps/product_info_step.dart';
import 'steps/date_purchase_step.dart';
import 'steps/documents_notes_step.dart';
import '../warranty-home/warranty-home.dart';
import './add-w-widgets/step_progress_indicator.dart';
import 'steps/success_warranty_page.dart';

import '../../../controller/product_controller.dart';
import '../../../controller/warranty_controller.dart';
import '../../../models/product_category_model.dart';

class AddWarrantyPage extends StatefulWidget {
  const AddWarrantyPage({super.key});

  @override
  State<AddWarrantyPage> createState() => _AddWarrantyPageState();
}

class _AddWarrantyPageState extends State<AddWarrantyPage> {
  final ProductController _productController = Get.find<ProductController>();
  final WarrantyController _warrantyController = Get.find<WarrantyController>();

  int _currentStep = 0;
  final PageController _pageController = PageController();

  bool _isLoading = false;

  final _productInfoFormKey = GlobalKey<FormState>();
  final _datePurchaseFormKey = GlobalKey<FormState>();
  final _documentsNotesFormKey = GlobalKey<FormState>();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _manufactureDateController =
      TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedSubCategory;
  String? _selectedWarrantyType;
  File? _productPhoto;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _purchaseDateController = TextEditingController();
  final TextEditingController _sellerNameController = TextEditingController();

  File? _invoiceFile;
  File? _certificateFile;
  final TextEditingController _notesController = TextEditingController();

  final List<String> warrantyTypes = [
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
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _manufactureDateController.dispose();
    _referenceController.dispose();
    _supplierController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _purchaseDateController.dispose();
    _sellerNameController.dispose();
    _notesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showValidationSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.orange.withOpacity(0.7),
      colorText: Colors.white,
    );
  }

  void _saveWarranty() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showValidationSnackbar('Erreur d\'authentification',
          'Veuillez vous connecter pour ajouter une garantie.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (_productNameController.text.isEmpty ||
        _selectedCategoryId == null ||
        _selectedCategoryName == null ||
        _selectedSubCategory == null ||
        _priceController.text.isEmpty ||
        _referenceController.text.isEmpty ||
        _supplierController.text.isEmpty ||
        _selectedWarrantyType == null ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        _purchaseDateController.text.isEmpty ||
        _sellerNameController.text.isEmpty) {
      _showValidationSnackbar('Données manquantes',
          'Veuillez remplir toutes les informations requises.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final dateFormat = DateFormat('dd/MM/yyyy');
      final DateTime purchaseDate =
          dateFormat.parse(_purchaseDateController.text);
      final DateTime startDate = dateFormat.parse(_startDateController.text);
      final DateTime endDate = dateFormat.parse(_endDateController.text);
      final String manufactureDate = _manufactureDateController.text;

      await _warrantyController.addWarranty(
        userId: user.uid,
        productName: _productNameController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        manufactureDate: manufactureDate,
        reference: _referenceController.text,
        productCategoryId: _selectedCategoryId!,
        productCategoryName: _selectedCategoryName!,
        productSubCategoryName: _selectedSubCategory!,
        supplier: _supplierController.text,
        warrantyType: _selectedWarrantyType!,
        productPhotoFile: _productPhoto,
        startDate: startDate,
        endDate: endDate,
        purchaseDate: purchaseDate,
        sellerName: _sellerNameController.text,
        invoiceFile: _invoiceFile,
        certificateFile: _certificateFile,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      setState(() {
        _isLoading = false;
      });

      if (_warrantyController.allWarranties.isNotEmpty) {
        final newWarranty = _warrantyController.allWarranties.last;
        Get.off(() => SuccessWarrantyPage(newWarranty: newWarranty));
      } else {
        Get.offAll(() => const WarrantyHomePage());
      }
    } catch (e) {
      log('Erreur détaillée: $e');
      _showValidationSnackbar('Erreur',
          'Échec de l\'ajout de la garantie. Veuillez réessayer. Erreur: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextStep() {
    bool isValid = false;
    if (_currentStep == 0) {
      isValid = _productInfoFormKey.currentState?.validate() ?? false;
      if (isValid && (_selectedCategoryId == null || _selectedCategoryName == null)) {
        isValid = false;
        _showValidationSnackbar(
            'Validation manquante', 'Veuillez sélectionner une catégorie de produit.');
      }
      if (isValid && (_selectedSubCategory == null || _selectedSubCategory!.isEmpty)) {
        isValid = false;
        _showValidationSnackbar('Validation manquante',
            'Veuillez sélectionner une sous-catégorie de produit.');
      }
      if (isValid &&
          (_selectedWarrantyType == null || _selectedWarrantyType!.isEmpty)) {
        isValid = false;
        _showValidationSnackbar(
            'Validation manquante', 'Veuillez sélectionner un type de garantie.');
      }
    } else if (_currentStep == 1) {
      isValid = _datePurchaseFormKey.currentState?.validate() ?? false;
      if (isValid) {
        final dateFormat = DateFormat('dd/MM/yyyy');
        final DateTime? manufactureDate =
            _manufactureDateController.text.isNotEmpty
                ? dateFormat.parse(_manufactureDateController.text)
                : null;
        final DateTime? purchaseDate = _purchaseDateController.text.isNotEmpty
            ? dateFormat.parse(_purchaseDateController.text)
            : null;

        if (manufactureDate != null &&
            purchaseDate != null &&
            manufactureDate.isAfter(purchaseDate)) {
          isValid = false;
          _showValidationSnackbar('Erreur de date',
              'La date de fabrication ne peut pas être postérieure à la date d\'achat.');
        }
        final DateTime? startDate = _startDateController.text.isNotEmpty
            ? dateFormat.parse(_startDateController.text)
            : null;
        final DateTime? endDate = _endDateController.text.isNotEmpty
            ? dateFormat.parse(_endDateController.text)
            : null;

        if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
          isValid = false;
          _showValidationSnackbar('Erreur de date',
              'La date de début de garantie ne peut pas être postérieure à la date de fin.');
        }
      }
    } else if (_currentStep == 2) {
      isValid = true;
    }

    if (isValid) {
      if (_currentStep < 2) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        if (!_isLoading) {
          _saveWarranty();
        }
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _showExitConfirmationDialog();
    }
  }

  void _showExitConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Abandonner le formulaire ?'),
        content: const Text(
            'Êtes-vous sûr de vouloir quitter ? Toutes les informations saisies seront perdues.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.offAll(() => const WarrantyHomePage());
            },
            child:
                const Text('Confirmer', style: TextStyle(color: Color(0xFFE91E63))),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    setState(() {
      if (pickedFile != null) {
        _productPhoto = File(pickedFile.path);
      }
    });
  }

  Future<void> _pickFile(FileType fileType, List<String>? allowedExtensions,
      Function(File?) onFileSelected) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: fileType,
      allowedExtensions: allowedExtensions,
    );

    if (result != null && result.files.single.path != null) {
      onFileSelected(File(result.files.single.path!));
    }
  }

  void _showSelectionBottomSheet({
    required List<String> items,
    required String? selectedItem,
    required Function(String) onItemSelected,
    bool showButton = true,
    String? title,
  }) {
    Get.bottomSheet(
      SizedBox(
        height: Get.height * 0.6,
        child: Column(
          children: [
            if (title != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item),
                    trailing: selectedItem == item
                        ? const Icon(Icons.check, color: Color(0xFFE91E63))
                        : null,
                    onTap: () {
                      onItemSelected(item);
                      if (!showButton) {
                        Get.back();
                      }
                    },
                  );
                },
              ),
            ),
            if (showButton)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Choisir'),
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

  void _showCategorySelection() {
    Get.bottomSheet(
      SizedBox(
        height: Get.height * 0.7,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Text(
                'Catégorie du produit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_productController.isLoadingCategories.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: _productController.productCategories.length,
                  itemBuilder: (context, index) {
                    ProductCategoryModel category =
                        _productController.productCategories[index];
                    return ListTile(
                      title: Text(category.categoryName),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.black54, size: 20),
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
    List<String> subCategories =
        category.subCategories.map((e) => e.categoryName).toList();
    _showSelectionBottomSheet(
      title: 'Sous-catégorie du produit',
      items: subCategories,
      selectedItem: _selectedSubCategory,
      onItemSelected: (subCategory) {
        setState(() {
          _selectedCategoryId = category.categoryId;
          _selectedCategoryName = category.categoryName;
          _selectedSubCategory = subCategory;
        });
      },
      showButton: false,
    );
  }

  void _showWarrantyTypeSelection() {
    _showSelectionBottomSheet(
      title: 'Type de Garantie',
      items: warrantyTypes,
      selectedItem: _selectedWarrantyType,
      onItemSelected: (type) {
        setState(() {
          _selectedWarrantyType = type;
        });
      },
      showButton: false,
    );
  }

  Future<void> _pickAndSetDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(248, 255, 255, 255),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child:
                        StepProgressIndicator(currentStep: _currentStep, totalSteps: 3)),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: Color.fromARGB(255, 86, 86, 86), size: 30),
                  onPressed: _showExitConfirmationDialog,
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: ProductInfoStep(
                    formKey: _productInfoFormKey,
                    productNameController: _productNameController,
                    priceController: _priceController,
                    manufactureDateController: _manufactureDateController,
                    referenceController: _referenceController,
                    supplierController: _supplierController,
                    selectedCategory: _selectedCategoryName,
                    selectedSubCategory: _selectedSubCategory,
                    onCategoryTap: _showCategorySelection,
                    selectedWarrantyType: _selectedWarrantyType,
                    onWarrantyTypeTap: _showWarrantyTypeSelection,
                    productPhoto: _productPhoto,
                    onPickImage: _pickImage,
                    onSelectManufactureDate: () =>
                        _pickAndSetDate(context, _manufactureDateController),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: DatePurchaseStep(
                    formKey: _datePurchaseFormKey,
                    startDateController: _startDateController,
                    endDateController: _endDateController,
                    purchaseDateController: _purchaseDateController,
                    sellerNameController: _sellerNameController,
                    onSelectDate: (controller) =>
                        _pickAndSetDate(context, controller),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: DocumentsNotesStep(
                    formKey: _documentsNotesFormKey,
                    invoiceFile: _invoiceFile,
                    certificateFile: _certificateFile,
                    notesController: _notesController,
                    pickFile: _pickFile,
                    onPickInvoice: _updateInvoiceFile,
                    onPickCertificate: _updateCertificateFile,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                if (_currentStep > 0 && _currentStep < 2)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE91E63),
                        side: const BorderSide(color: Color(0xFFE91E63)),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Retour'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(_currentStep < 2 ? 'Suivant' : 'Ajouter Garantie'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateInvoiceFile(File? file) {
    setState(() {
      _invoiceFile = file;
    });
  }

  void _updateCertificateFile(File? file) {
    setState(() {
      _certificateFile = file;
    });
  }
}