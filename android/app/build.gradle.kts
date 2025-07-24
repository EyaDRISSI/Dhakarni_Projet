// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin") 
}

android {
    namespace = "com.example.dhakarni_1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // Ou JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_17 // Ou JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString() // Ou JavaVersion.VERSION_11.toString()
    }

    // Ces blocs DOIVENT être à l'intérieur du bloc 'android { ... }'
    defaultConfig {
        applicationId = "com.example.dhakarni_1"
        minSdk = 23 // Ceci est correct
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner" 
    }

    buildTypes {
        release {
             signingConfig = signingConfigs.getByName("debug") 
            isMinifyEnabled = true // Active la minification du code
            isShrinkResources = true // Active la suppression des ressources inutilisées
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.16.0"))
    implementation("com.google.firebase:firebase-database-ktx")
    implementation("com.google.firebase:firebase-auth") // Exemple: pour Firebase Auth
    implementation("com.google.firebase:firebase-firestore") // Exemple: pour Cloud Firestore
    
}