import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../models/warranty_model.dart';
import '../../../../controller/warranty_controller.dart';

class MigrateWarrantyPage extends StatefulWidget {
  final WarrantyModel warranty;

  const MigrateWarrantyPage({Key? key, required this.warranty}) : super(key: key);

  @override
  State<MigrateWarrantyPage> createState() => _MigrateWarrantyPageState();
}

class _MigrateWarrantyPageState extends State<MigrateWarrantyPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final WarrantyController _warrantyController = Get.find<WarrantyController>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    const Color customPink = Color(0xFFE91E63);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: customPink),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/migration.png', height: 200),
              const SizedBox(height: 24),
              const Text(
                'Migration de Garantie',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Partagez cette garantie avec un autre utilisateur en entrant son adresse e-mail.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Adresse e-mail du destinataire',
                    hintText: 'exemple@email.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email, color: customPink),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: customPink, width: 2.0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelStyle: const TextStyle(color: customPink),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une adresse e-mail.';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Veuillez entrer une adresse e-mail valide.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _warrantyController.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Commencer',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
}