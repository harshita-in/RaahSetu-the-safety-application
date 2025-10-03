import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'geofire_service.dart';

class LocationService {
  final _auth = FirebaseAuth.instance;
  final GeoFireService _geoFireService = GeoFireService();

  // Request location permission (already written earlier)

  void startUpdatingLocation() {
    _geoFireService.init();

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position pos) {
      final user = _auth.currentUser;
      if (user != null) {
        _geoFireService.updateLocation(pos.latitude, pos.longitude);
      }
    });
  }
}
