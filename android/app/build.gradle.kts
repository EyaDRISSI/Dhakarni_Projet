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
    compileSdk = 35 
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Correct syntax for Kotlin DSL
        isCoreLibraryDesugaringEnabled = true // Corrected line
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.dhakarni_1"
        minSdk = 23
        targetSdk = 35 
        versionCode = flutter.versionCode as Int?
        versionName = flutter.versionName as String?
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
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
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")

    // Update the desugaring library version from 2.0.4 to 2.1.4
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}