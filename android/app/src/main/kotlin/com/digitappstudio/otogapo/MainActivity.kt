package com.digitappstudio.otogapo

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Add timeout to prevent hanging
        try {
            // Force immediate initialization
            android.util.Log.d("MainActivity", "MainActivity onCreate - starting Flutter")
            
            // Create notification channel for FCM
            createNotificationChannel()
        } catch (e: Exception) {
            // Continue even if initialization fails
            android.util.Log.e("MainActivity", "MainActivity initialization failed", e)
        }
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "otogapo_notifications",
                "OtoGapo Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "OtoGapo push notifications"
                enableVibration(true)
                enableLights(true)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager?.createNotificationChannel(channel)
            android.util.Log.d("MainActivity", "Notification channel created")
        }
    }
}
