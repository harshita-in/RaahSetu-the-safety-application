import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'location_service.dart';

class EmergencyService {
  final _db = FirebaseDatabase.instance;
  final _auth = FirebaseAuth.instance;
  final LocationService _locationService = LocationService();

  Future<void> triggerEmergency() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final pos = await _locationService.getCurrentLocation();

    final ref = _db.ref("emergencies").push();
    await ref.set({
      "userId": user.uid,
      "lat": pos.latitude,
      "lng": pos.longitude,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "status": "active",
    });
  }
}
