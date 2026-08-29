import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AfricasTalkingService {
  // Credentials configured from .env (sandbox mode)
  static const String _defaultApiKey = 'atsk_01473b32929a59d945723b08e45b7d06c42776c0f3ed04657c11b3d42b3869b10009ef30';
  static const String _defaultUsername = 'sandbox';

  final String apiKey;
  final String username;

  AfricasTalkingService({
    this.apiKey = _defaultApiKey,
    this.username = _defaultUsername,
  });

  bool get isSandbox => username.toLowerCase() == 'sandbox';

  String get _smsUrl => isSandbox
      ? 'https://api.sandbox.africastalking.com/version1/messaging'
      : 'https://api.africastalking.com/version1/messaging';

  String get _voiceUrl => isSandbox
      ? 'https://voice.sandbox.africastalking.com/call'
      : 'https://voice.africastalking.com/call';

  /// Send an automated SMS reminder
  Future<Map<String, dynamic>> sendReminderSMS({
    required String recipientPhone,
    required String message,
  }) async {
    try {
      final formattedPhone = _formatPhoneNumber(recipientPhone);
      final response = await http.post(
        Uri.parse(_smsUrl),
        headers: {
          'apiKey': apiKey,
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'to': formattedPhone,
          'message': message,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'SMS reminder successfully queued via Africa\'s Talking.',
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': response.body,
          'message': 'Failed to send SMS (Status: ${response.statusCode})',
        };
      }
    } catch (e) {
      debugPrint('AfricasTalking SMS Error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Connection notice: $e',
      };
    }
  }

  /// Initiate an automated Voice call to a debtor
  Future<Map<String, dynamic>> initiateVoiceCall({
    required String recipientPhone,
    String? callerId,
  }) async {
    try {
      final formattedPhone = _formatPhoneNumber(recipientPhone);
      // In sandbox, the virtual caller number is typically provided by the sandbox console
      final fromNumber = callerId ?? (isSandbox ? '+254711082000' : '+234800000000');

      final response = await http.post(
        Uri.parse(_voiceUrl),
        headers: {
          'apiKey': apiKey,
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'from': fromNumber,
          'to': formattedPhone,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Call placed successfully via Africa\'s Talking Voice Gateway.',
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': response.body,
          'message': 'Failed to place call (Status: ${response.statusCode})',
        };
      }
    } catch (e) {
      debugPrint('AfricasTalking Voice Error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Voice gateway notice: $e',
      };
    }
  }

  String _formatPhoneNumber(String phone) {
    var cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('0')) {
      // Default to Nigerian country code +234
      cleaned = '+234${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }
    return cleaned;
  }
}
