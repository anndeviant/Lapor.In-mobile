package com.example.laporin_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Bundle

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.laporin_app/config"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getGoogleApiKey" -> {
                    try {
                        val apiKey = getGoogleApiKey()
                        if (apiKey != null) {
                            result.success(apiKey)
                        } else {
                            result.error("API_KEY_NOT_FOUND", "Google API key not found in manifest", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to get Google API key: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getGoogleApiKey(): String? {
        return try {
            val ai: ApplicationInfo = packageManager.getApplicationInfo(
                packageName, 
                PackageManager.GET_META_DATA
            )
            val bundle = ai.metaData
            bundle?.getString("com.google.android.geo.API_KEY")
        } catch (e: Exception) {
            null
        }
    }
}
