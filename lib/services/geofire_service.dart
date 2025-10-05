import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

class GeoFireService {
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance;
  late DatabaseReference _locationsRef;

  // Initialize with a DB path
  void init() {
    _locationsRef = _database.ref("locations");
  }

  // Update current user's location
  Future<void> updateLocation(double lat, double lng) async {
    final user = _auth.currentUser;
    if (user != null) {
      // Simple location storage - you can implement GeoHash for better performance
      await _locationsRef.child(user.uid).set({
        'lat': lat,
        'lng': lng,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // Remove user when they logout
  Future<void> removeUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _locationsRef.child(user.uid).remove();
    }
  }

  // Query nearby users (simplified version)
  Future<List<Map<String, dynamic>>> queryNearby(double lat, double lng, double radiusKm) async {
    final snapshot = await _locationsRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final nearbyUsers = <Map<String, dynamic>>[];
      
      for (final entry in data.entries) {
        final userData = entry.value as Map<dynamic, dynamic>;
        final userLat = userData['lat'] as double;
        final userLng = userData['lng'] as double;
        
        final distance = _calculateDistance(lat, lng, userLat, userLng);
        if (distance <= radiusKm) {
          nearbyUsers.add({
            'uid': entry.key,
            'lat': userLat,
            'lng': userLng,
            'distance': distance,
            'timestamp': userData['timestamp'],
          });
        }
      }
      
      return nearbyUsers;
    }
    return [];
  }

  // Calculate distance between two points in kilometers
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
