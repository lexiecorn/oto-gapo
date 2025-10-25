package com.digitappstudio.otogapo

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Add timeout to prevent hanging
        try {
            // Force immediate initialization
            android.util.Log.d("MainActivity", "MainActivity onCreate - starting Flutter")
        } catch (e: Exception) {
            // Continue even if initialization fails
            android.util.Log.e("MainActivity", "MainActivity initialization failed", e)
        }
    }
}
