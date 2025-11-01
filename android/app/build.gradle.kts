import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("com.google.firebase.firebase-perf")
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

// Firebase Auth requires minSdkVersion 23+, but integration_test requires 24+
val flutterMinSdkVersion = localProperties.getProperty("flutter.minSdkVersion")?.toIntOrNull() ?: 24


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
        // Enable core library desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
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
            // Check if running on CI (Codemagic)
            if (System.getenv("CI") == "true") {
                // Use Codemagic environment variables
                storeFile = System.getenv("CM_KEYSTORE_PATH")?.let { file(it) }
                storePassword = System.getenv("CM_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("CM_KEY_ALIAS")
                keyPassword = System.getenv("CM_KEY_PASSWORD")
            } else if (hasReleaseKeystore) {
                // Use local key.properties for local builds
                storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
                storePassword = keystoreProperties["storePassword"] as String?
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
            }
        }
        getByName("debug") {
            // Keep debug config unchanged
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            // CRITICAL FIX: Disable R8 minification to prevent splash screen hang
            // R8 was removing critical initialization code in production
            isMinifyEnabled = false  // Disable R8 code shrinking and obfuscation
            isShrinkResources = false  // Disable resource shrinking
            // Keep ProGuard rules commented out since we're not using minification
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Temporarily disable ABI splits to debug build issues
    // splits {
    //     abi {
    //         // Only enable splits for release builds, not debug builds
    //         isEnable = gradle.startParameter.taskNames.any { 
    //             it.contains("Release") && !it.contains("Debug") 
    //         }
    //         reset()
    //         include("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
    //         // Universal APK for debug, split APKs for release
    //         isUniversalApk = !gradle.startParameter.taskNames.any { 
    //             it.contains("Release") && !it.contains("Debug") 
    //         }
    //     }
    // }

    // Ensure native libraries use 16 KB page alignment for Android 15+ requirements
    // This is required for Google Play Store compliance starting Nov 1, 2025
    // See: https://developer.android.com/guide/practices/page-alignment
    packaging {
        jniLibs {
            // Use modern packaging to ensure proper alignment for 16 KB page sizes
            useLegacyPackaging = false
        }
    }

    // Copy APKs to Flutter-expected location after build
    // This ensures APKs are in the location Flutter expects for verification
    applicationVariants.all {
        val variantName = name.replaceFirstChar { it.uppercaseChar() }
        val assembleTask = tasks.named("assemble$variantName")
        
        val copyApkTask = tasks.register("copy${variantName}ApkToFlutter", Copy::class) {
            description = "Copy $variantName APK to Flutter output directory"
            group = "flutter"
            
            from(layout.buildDirectory.dir("outputs/apk/${flavorName}/${buildType.name}"))
            into("${project.rootDir}/../build/app/outputs/flutter-apk")
            include("*.apk")
            
            doLast {
                val copiedFiles = destinationDir.listFiles { _, name -> name.endsWith(".apk") }
                copiedFiles?.forEach { file ->
                    println("✓ Copied APK: ${file.name} to: ${destinationDir}")
                }
            }
        }
        
        assembleTask.configure {
            finalizedBy(copyApkTask)
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required for Activity.enableEdgeToEdge()
    implementation("androidx.activity:activity-ktx:1.9.3")
    // Core library desugaring for flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
