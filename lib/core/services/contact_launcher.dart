import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ContactLauncher {
  static const MethodChannel _channel = MethodChannel('app.contact_launcher');

  static Future<bool> launchPhone(String phoneNumber) async {
    if (kIsWeb) return false;
    if (!(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      return false;
    }
    final sanitized = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    try {
      final result = await _channel.invokeMethod<bool>(
        'launchPhone',
        {'phone': sanitized},
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> launchWhatsApp(String phoneNumber, String message) async {
    if (kIsWeb) return false;
    if (!(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      return false;
    }
    final sanitized = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    try {
      final result = await _channel.invokeMethod<bool>(
        'launchWhatsApp',
        {'phone': sanitized, 'message': message},
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
