import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'date_purchase_step.dart'; 

class DocumentsNotesStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final File? invoiceFile; 
  final File? certificateFile; 
  final TextEditingController notesController;
  final Function(FileType, Function(File?)) pickFile;
  final Function(File?) onPickInvoice;
  final Function(File?) onPickCertificate;

  const DocumentsNotesStep({
    super.key,
    required this.formKey,
    required this.invoiceFile,
    required this.certificateFile,
    required this.notesController,
    required this.pickFile,
    required this.onPickInvoice,
    required this.onPickCertificate,
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
            'Documents et Notes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ajoutez les documents importants et des notes supplémentaires si nécessaire.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          const Text(
            'Copie de la Facture',
            style: TextStyle(
                fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            child: invoiceFile == null
                ? ElevatedButton.icon( 
                    onPressed: () => pickFile(FileType.image, onPickInvoice),
                    icon: const Icon(Icons.cloud_upload_outlined, color: Color.fromARGB(255, 138, 138, 138)), 
                    label: const Text(
                      'Joindre document',
                      style: TextStyle(color: Color.fromARGB(255, 138, 138, 138)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, 
                      shadowColor: Colors.transparent, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15), 
                      minimumSize: const Size(double.infinity, 60), 
                      elevation: 0, 
                    ),
                  )
                : Column(
                    children: [
                      if (invoiceFile!.path.endsWith('.png') ||
                          invoiceFile!.path.endsWith('.jpg') ||
                          invoiceFile!.path.endsWith('.jpeg'))
                        Image.file(
                          invoiceFile!,
                          height: 150, 
                          fit: BoxFit.contain,
                        )
                      else 
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(Icons.insert_drive_file, size: 80, color: Colors.grey),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        invoiceFile!.path.split('/').last,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => pickFile(FileType.image, onPickInvoice), 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                        child: const Text('Modifier document'),
                      ),
                      const SizedBox(height: 8), 
                    ],
                  ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Copie du Certificat de Garantie',
            style: TextStyle(
                fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          // L'AFFICHAGE DU CERTIFICAT 
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(10),
              color: certificateFile == null ? const Color.fromARGB(255, 235, 235, 235) : null,
            ),
            child: certificateFile == null
                ? ElevatedButton.icon(
                    onPressed: () => pickFile(FileType.image, onPickCertificate),
                    icon: const Icon(Icons.cloud_upload_outlined, color: Color.fromARGB(255, 127, 126, 126)),
                    label: const Text(
                      'Joindre document',
                      style: TextStyle(color: Color.fromARGB(255, 127, 126, 126)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, 
                      shadowColor: Colors.transparent, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                      minimumSize: const Size(double.infinity, 60),
                      elevation: 0,
                    ),
                  )
                : Column(
                    children: [
                      if (certificateFile!.path.endsWith('.png') ||
                          certificateFile!.path.endsWith('.jpg') ||
                          certificateFile!.path.endsWith('.jpeg'))
                        Image.file(
                          certificateFile!,
                          height: 150, 
                          fit: BoxFit.contain,
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(Icons.insert_drive_file, size: 80, color: Colors.grey),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        certificateFile!.path.split('/').last,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => pickFile(FileType.image, onPickCertificate),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                        child: const Text('Modifier document'),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
          ),
          const SizedBox(height: 22),
          CustomTextField(
            controller: notesController,
            labelText: 'Note (Optionnel)',
            hintText: 'Entrez toute information supplémentaire ici...',
            maxLines: 4,
          ),
          const SizedBox(height: 24),
         
        ],
      ),
    );
  }
}