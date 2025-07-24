// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import './pages/loading/SingleSplashPage.dart';
import 'package:get/get.dart'; // <<< ADD THIS IMPORT
import './controller/user_controller.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize your UserController (important for authStateChanges listener)
  Get.put(UserController()); // Make sure this is called once at startup
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Change MaterialApp to GetMaterialApp
    return GetMaterialApp( // <<< CHANGED HERE
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