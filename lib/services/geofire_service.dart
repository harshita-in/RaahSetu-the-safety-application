import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GeoFireService {
  final _auth = FirebaseAuth.instance;

  // Initialize GeoFire with a DB path
  void init() {
    Geofire.initialize("locations");
  }

  // Update current user's location in GeoFire
  Future<void> updateLocation(double lat, double lng) async {
    final user = _auth.currentUser;
    if (user != null) {
      await Geofire.setLocation(user.uid, lat, lng);
    }
  }

  // Remove user when they logout
  Future<void> removeUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await Geofire.removeLocation(user.uid);
    }
  }

  // Query nearby users
  Stream<Map<String, dynamic>?> queryNearby(double lat, double lng, double radiusKm) {
    return Geofire.queryAtLocation(lat, lng, radiusKm);
  }
}
