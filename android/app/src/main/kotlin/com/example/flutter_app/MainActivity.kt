package com.example.flutter_app

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channelName = "app.contact_launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchPhone" -> {
                    val phone = call.argument<String>("phone")
                    if (phone.isNullOrBlank()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    val intent = Intent(Intent.ACTION_DIAL).apply {
                        data = Uri.parse("tel:$phone")
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    runCatching {
                        startActivity(intent)
                        result.success(true)
                    }.getOrElse {
                        result.success(false)
                    }
                }
                "launchWhatsApp" -> {
                    val phone = call.argument<String>("phone")
                    val message = call.argument<String>("message") ?: ""
                    if (phone.isNullOrBlank()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    val intent = Intent(Intent.ACTION_VIEW).apply {
                        data = Uri.parse("https://wa.me/$phone?text=${Uri.encode(message)}")
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    runCatching {
                        startActivity(intent)
                        result.success(true)
                    }.getOrElse {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
