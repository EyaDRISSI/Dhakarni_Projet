// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import './pages/loading/SingleSplashPage.dart';
import 'package:get/get.dart'; 
import './controller/user_controller.dart'; 
import './controller/product_controller.dart'; 
import './controller/warranty_controller.dart'; 



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  Get.put(UserController()); 
  Get.put(ProductController()); // Initialise ProductController
  Get.put(WarrantyController()); // Initialise WarrantyController
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Dhakarni',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SingleSplashPage(),
    );
  }
}