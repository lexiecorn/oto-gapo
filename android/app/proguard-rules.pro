# Flutter defaults
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Firebase models and annotations
-keep class com.google.firebase.** { *; }
-keep class com.google.gson.annotations.** { *; }

# Keep Crashlytics classes
-keep class com.google.firebase.crashlytics.** { *; }
-dontwarn com.google.firebase.crashlytics.**

# Keep AutoRoute generated classes
-keep class * extends java.lang.annotation.Annotation { *; }
-keep class **$$* { *; }

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }

# Keep Google Play Core split install APIs used by Flutter deferred components
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep PocketBase and authentication classes
-keep class com.digitappstudio.otogapo.** { *; }
-keep class * extends java.lang.Exception { *; }

# Keep SharedPreferences and Hive classes
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class hive_flutter.** { *; }

# Keep Dio and networking classes
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keep class com.squareup.okhttp3.** { *; }

# Keep PocketBase classes
-keep class pocketbase.** { *; }

# Keep all Flutter plugin classes
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

# Keep JSON serialization classes
-keep class * implements java.io.Serializable { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep all classes with @Keep annotation
-keep @androidx.annotation.Keep class * { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# Keep all classes with @Keep annotation (support library)
-keep @android.support.annotation.Keep class * { *; }
-keepclassmembers class * {
    @android.support.annotation.Keep *;
}

# CRITICAL: Keep all Flutter initialization and engine code
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }

# CRITICAL: Keep all Firebase initialization code
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.gson.** { *; }

# CRITICAL: Keep all PocketBase and networking code
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keep class com.squareup.okhttp3.** { *; }
-keep class pocketbase.** { *; }

# CRITICAL: Keep all SharedPreferences and storage code
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class hive_flutter.** { *; }

# CRITICAL: Keep all plugin registration and reflection code
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class * extends io.flutter.plugin.common.PluginRegistry$Registrar { *; }

# CRITICAL: Keep all JSON serialization and data models
-keep class * implements java.io.Serializable { *; }
-keep class * implements java.lang.Cloneable { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# CRITICAL: Keep all exception handling code
-keep class * extends java.lang.Exception { *; }
-keep class * extends java.lang.Throwable { *; }

# CRITICAL: Keep all annotation classes
-keep class * extends java.lang.annotation.Annotation { *; }
-keep @interface * { *; }

# CRITICAL: Keep all enum classes
-keep class * extends java.lang.Enum { *; }

# CRITICAL: Keep all native method implementations
-keepclasseswithmembernames class * {
    native <methods>;
}

