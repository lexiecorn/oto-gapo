import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) {
        load(file.inputStream())
    }
}

val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) {
        load(FileInputStream(file))
    }
}

val hasReleaseKeystore = keystoreProperties["storeFile"] != null

val flutterMinSdkVersion = localProperties.getProperty("flutter.minSdkVersion")?.toIntOrNull() ?: 21


android {
    namespace = "com.digitappstudio.otogapo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.digitappstudio.otogapo"
        minSdk = flutterMinSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = localProperties.getProperty("flutter.versionCode")?.toInt() ?: 1
        versionName = localProperties.getProperty("flutter.versionName") ?: "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    flavorDimensions += "default"
    productFlavors {
        create("production") {
            dimension = "default"
            applicationIdSuffix = ""
            manifestPlaceholders["appName"] = "Otogapo"
        }
        create("staging") {
            dimension = "default"
            applicationIdSuffix = ".stg"
            manifestPlaceholders["appName"] = "[STG] Otogapo"
        }
        create("development") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            manifestPlaceholders["appName"] = "[DEV] Otogapo"
        }
    }

    signingConfigs {
        create("release") {
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
        }
        getByName("debug") {
            // Keep debug config unchanged
        }
    }

    buildTypes {
        getByName("release") {
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                println("[Gradle] No key.properties found. Configure release signing before Play Store uploads.")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Ensure native libraries use 16 KB page alignment for Android 15+ requirements
    // This is required for Google Play Store compliance starting Nov 1, 2025
    // See: https://developer.android.com/guide/practices/page-alignment
    packagingOptions {
        jniLibs {
            // Use modern packaging to ensure proper alignment for 16 KB page sizes
            useLegacyPackaging = false
        }
    }
    
    // Additional configuration for 16 KB page size support
    packaging {
        // Ensure proper alignment for native libraries
        jniLibs {
            useLegacyPackaging = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required for Activity.enableEdgeToEdge()
    implementation("androidx.activity:activity-ktx:1.9.3")
}
