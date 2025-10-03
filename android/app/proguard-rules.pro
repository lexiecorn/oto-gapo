# Flutter defaults
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Firebase models and annotations
-keep class com.google.firebase.** { *; }
-keep class com.google.gson.annotations.** { *; }

# Keep AutoRoute generated classes
-keep class * extends java.lang.annotation.Annotation { *; }
-keep class **$$* { *; }

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }

# Keep Google Play Core split install APIs used by Flutter deferred components
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

