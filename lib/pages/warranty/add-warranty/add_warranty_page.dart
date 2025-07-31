import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart'; 

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; 

import 'product_info_step.dart';
import '../add-warranty/date_purchase_step.dart';
import '../add-warranty/documents_notes_step.dart';
import '../add-warranty/success_warranty_page.dart';
import '../../warranty/warranty-home.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(totalSteps, (index) {
          bool isActive = index <= currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 8),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFE91E63) : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

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

class AddWarrantyPage extends StatefulWidget {
  const AddWarrantyPage({super.key});

  @override
  State<AddWarrantyPage> createState() => _AddWarrantyPageState();
}

class _AddWarrantyPageState extends State<AddWarrantyPage> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final _productInfoFormKey = GlobalKey<FormState>();
  final _datePurchaseFormKey = GlobalKey<FormState>();
  final _documentsNotesFormKey = GlobalKey<FormState>();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _manufactureDateController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  String? _selectedCategory;
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

  final Map<String, List<String>> categories = {
    'Informatique': [
      'Ordinateurs portables',
      'Ordinateurs de bureau',
      'Imprimantes & scanners',
      'Disques durs & SSD',
      'Écrans',
      'Claviers & souris',
      'Réseaux & routeurs',
      'Logiciels'
    ],
    ' Électroménager': [
      'Réfrigérateurs',
      'Lave-linge',
      'Fours & micro-ondes',
      'Cuisinières',
      'Aspirateurs',
      'Robots de cuisine',
      'Chauffe-eau',
      'Climatiseurs'
    ],
    ' TV, Photo et Son': [
      'Téléviseurs LED/OLED',
      'Home cinéma',
      'Appareils photo numériques',
      'Caméras de surveillance',
      'Vidéoprojecteurs',
      'Enceintes Bluetooth',
      'Casques audio'
    ],
    ' Téléphonie': [
      'Smartphones',
      'Téléphones fixes',
      'Tablettes',
      'Accessoires de téléphone',
      'Cartes SIM & recharge',
      'Écouteurs Bluetooth'
    ],
    ' Accessoires': [
      'Coques & housses',
      'Chargeurs & câbles',
      'Supports téléphones / PC',
      'Batteries externes',
      'Clés USB',
      'Accessoires gaming',
      'Adaptateurs'
    ],
    ' Véhicules': [
      'Voitures',
      'Motos & scooters',
      'Vélos',
      'Pièces détachées auto/moto',
      'Accessoires auto (GPS, tapis, caméras)',
      'Pneus & jantes'
    ],
    ' Énergie et Solaire': [
      'Panneaux solaires',
      'Batteries solaires',
      'Régulateurs de charge',
      'Onduleurs',
      'Lampes solaires',
      'Kits solaires portables'
    ],
  };

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

  Future<String?> _uploadFile(File? file, String path) async {
    if (file == null) return null;
    try {
      final ref = FirebaseStorage.instance.ref().child(path).child(file.path.split('/').last);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur lors de l\'upload du fichier $path: $e');
      return null;
    }
  }

  Future<void> _saveWarrantyToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        'Erreur d\'authentification',
        'Veuillez vous connecter pour ajouter une garantie.',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63))),
        barrierDismissible: false,
      ); 

      final String userId = user.uid;
      final databaseRef = FirebaseDatabase.instance.ref();

      // Upload des fichiers vers Firebase Storage
      final productPhotoUrl = await _uploadFile(_productPhoto, 'warranty_photos/$userId/products');
      final invoiceFileUrl = await _uploadFile(_invoiceFile, 'warranty_documents/$userId/invoices');
      final certificateFileUrl = await _uploadFile(_certificateFile, 'warranty_documents/$userId/certificates');

      final newWarrantyId = databaseRef.child('warranties_by_user').child(userId).push().key;
      if (newWarrantyId == null) {
        throw Exception('Impossible de générer un ID de garantie unique.');
      }

      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      String? manufactureDateFormatted;
      if (_manufactureDateController.text.isNotEmpty) {
        try {
          manufactureDateFormatted = formatter.format(DateTime.parse(_manufactureDateController.text));
        } catch (e) {
          print("Erreur de formatage de la date de fabrication: $e");
        }
      }
      String? startDateFormatted;
      if (_startDateController.text.isNotEmpty) {
        try {
          startDateFormatted = formatter.format(DateTime.parse(_startDateController.text));
        } catch (e) {
          print("Erreur de formatage de la date de début de garantie: $e");
        }
      }
      String? endDateFormatted;
      if (_endDateController.text.isNotEmpty) {
        try {
          endDateFormatted = formatter.format(DateTime.parse(_endDateController.text));
        } catch (e) {
          print("Erreur de formatage de la date de fin de garantie: $e");
        }
      }
      String? purchaseDateFormatted;
      if (_purchaseDateController.text.isNotEmpty) {
        try {
          purchaseDateFormatted = formatter.format(DateTime.parse(_purchaseDateController.text));
        } catch (e) {
          print("Erreur de formatage de la date d'achat: $e");
        }
      }


      final productData = {
        'productID': newWarrantyId, 
        'productName': _productNameController.text,
        'productCategory': _selectedCategory,
        'productSubCategory': _selectedSubCategory, 
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'reference': _referenceController.text,
        'manufacturingDate': manufactureDateFormatted,
        'supplier': _supplierController.text,
        'productPhotoUrl': productPhotoUrl, 
      };

      final warrantyData = {
        'warrantyID': newWarrantyId,
        'product': productData, 
        'warrantyStartDate': startDateFormatted,
        'warrantyEndDate': endDateFormatted,
        'warrantyType': _selectedWarrantyType,
        'purchaseDate': purchaseDateFormatted,
        'sellerName': _sellerNameController.text,
        'invoiceUrl': invoiceFileUrl, 
        'certificateUrl': certificateFileUrl, 
        'notes': _notesController.text,
        'addedBy': userId, 
        'timestamp': ServerValue.timestamp, 
      };

      await databaseRef.child('warranties_by_user').child(userId).child(newWarrantyId).set(warrantyData);

      

      Get.back();
      Get.to(() => const SuccessWarrantyPage());

    } catch (e) {
      Get.back(); 
      print('Erreur lors de l\'enregistrement de la garantie : $e');
      Get.snackbar(
        'Erreur',
        'Échec de l\'enregistrement de la garantie: $e',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }


  void _nextStep() {
    bool isValid = false;
    if (_currentStep == 0) {
      isValid = _productInfoFormKey.currentState?.validate() ?? false;
      if (isValid && (_selectedSubCategory == null || _selectedSubCategory!.isEmpty)) {
        isValid = false;
        Get.snackbar(
          'Validation manquante',
          'Veuillez sélectionner une catégorie de produit.',
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
      if (isValid && (_selectedWarrantyType == null || _selectedWarrantyType!.isEmpty)) {
        isValid = false;
        Get.snackbar(
          'Validation manquante',
          'Veuillez sélectionner un type de garantie.',
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    


    } else if (_currentStep == 1) {
      isValid = _datePurchaseFormKey.currentState?.validate() ?? false;
    } else if (_currentStep == 2) {
      isValid = _documentsNotesFormKey.currentState?.validate() ?? false;
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
        
        _saveWarrantyToFirebase();
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
      Get.back();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70); // Qualité réduite
    setState(() {
      if (pickedFile != null) {
        _productPhoto = File(pickedFile.path);
      }
    });
  }

  Future<void> _pickFile(
      FileType fileType, Function(File?) onFileSelected) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: fileType,
    );

    if (result != null && result.files.single.path != null) {
      onFileSelected(File(result.files.single.path!));
    }
  }

  void _showCategorySelection() {
    Get.bottomSheet(
      SizedBox(
        height: Get.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Sélectionner une Catégorie',
                style: Get.textTheme.headlineSmall
                    ?.copyWith(color: const Color(0xFFE91E63)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: categories.keys.length,
                itemBuilder: (context, index) {
                  String category = categories.keys.elementAt(index);
                  return ListTile(
                    title: Text(category),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: Colors.black54, size: 20),
                    onTap: () {
                      Get.back();
                      _showSubCategorySelection(category);
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

  void _showSubCategorySelection(String category) {
    List<String> subCategories = categories[category]!;
    Get.bottomSheet(
      SizedBox(
        height: Get.height * 0.6,
        child: Column(
          children: [
              Expanded(
              child: ListView.builder(
                itemCount: subCategories.length,
                itemBuilder: (context, index) {
                  final subCategory = subCategories[index];
                  return ListTile(
                    title: Text(subCategory),
                    trailing: _selectedSubCategory == subCategory
                        ? const Icon(Icons.check, color: Color(0xFFE91E63))
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                        _selectedSubCategory = subCategory;
                      });
                      Get.back();
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
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

  void _showWarrantyTypeSelection() {
    Get.bottomSheet(
      SizedBox(
        height: Get.height * 0.6,
        child: Column(
          children: [
          Expanded(
              child: ListView.builder(
                itemCount: warrantyTypes.length,
                itemBuilder: (context, index) {
                  final type = warrantyTypes[index];
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
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

  Future<void> _pickAndSetDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
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
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StepProgressIndicator(currentStep: _currentStep, totalSteps: 3),
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
                    selectedCategory: _selectedCategory,
                    selectedSubCategory: _selectedSubCategory,
                    onCategoryTap: _showCategorySelection,
                    selectedWarrantyType: _selectedWarrantyType,
                    onWarrantyTypeTap: _showWarrantyTypeSelection,
                    productPhoto: _productPhoto,
                    onPickImage: _pickImage,
                    onSelectManufactureDate: () => _pickAndSetDate(context, _manufactureDateController), 
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
                    onSelectDate: (controller) => _pickAndSetDate(context, controller), 
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
                if (_currentStep > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(_currentStep < 2 ? 'Suivant' : 'Ajouter Garantie'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fonctions UPDATE FILE
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