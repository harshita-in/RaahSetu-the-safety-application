import 'package:flutter_sms/flutter_sms.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyContactService {
  final List<String> _contacts = ["+919876543210", "+911234567890"]; // change to real contacts

  Future<void> sendEmergencySMS(String message) async {
    if (await Permission.sms.request().isGranted) {
      await sendSMS(message: message, recipients: _contacts);
    } else {
      print("❌ SMS permission denied");
    }
  }

  Future<void> makeEmergencyCall() async {
    final Uri callUri = Uri(scheme: 'tel', path: _contacts.first);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      print("❌ Cannot place call");
    }
  }
}
