package com.example.missed_call_sms_new

import android.content.Intent
import android.os.Build
import android.content.SharedPreferences
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "missed_call_sms/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    startPersistentService()
                    result.success("Service started")
                }
                "stopService" -> {
                    stopPersistentService()
                    result.success("Service stopped")
                }
                "setSmsMessage" -> {
                    val message = call.arguments as? String
                    val prefs = getSharedPreferences("prefs", MODE_PRIVATE)
                    prefs.edit().putString("smsMessage", message).apply()
                    result.success("Message updated")
                }
                "isServiceRunning" -> {
                    val prefs = getSharedPreferences("ServicePrefs", MODE_PRIVATE)
                    val isRunning = prefs.getBoolean("serviceRunning", false)
                    result.success(isRunning)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startPersistentService() {
         val intent = Intent(this, SmsService::class.java) // CORRECT CLASS NAME
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    
    // Save service state
        val prefs = getSharedPreferences("ServicePrefs", MODE_PRIVATE)
         prefs.edit().putBoolean("serviceRunning", true).apply()
    }

    private fun stopPersistentService() {
    val intent = Intent(this, SmsService::class.java) // CORRECT CLASS NAME
    stopService(intent)
    
    // Save service state
    val prefs = getSharedPreferences("ServicePrefs", MODE_PRIVATE)
    prefs.edit().putBoolean("serviceRunning", false).apply()
    }

}