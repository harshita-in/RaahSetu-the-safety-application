import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyContactService {
  final List<String> _contacts = ["+919876543210", "+911234567890"]; // change to real contacts

  Future<void> sendEmergencySMS(String message) async {
    // For now, we'll use the SMS app to send messages
    // This is a fallback approach that opens the default SMS app
    for (String contact in _contacts) {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: contact,
        query: 'body=${Uri.encodeComponent(message)}',
      );
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        print("❌ Cannot open SMS app");
      }
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
