import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../services/location_service.dart';
import '../services/geofire_service.dart';
import '../services/emergency_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final GeoFireService _geoFireService = GeoFireService();
  final EmergencyService _emergencyService = EmergencyService();

  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    final fcm = FirebaseMessaging.instance;
    final settings = await fcm.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Notifications permission granted");
    }

    String? token = await fcm.getToken();
    if (token != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseDatabase.instance.ref("users/${user.uid}/fcmToken").set(token);
        print("✅ FCM Token saved for user: ${user.uid}");
      }
    }
  }

  Future<void> _initLocation() async {
    bool granted = await _locationService.requestPermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return;
    }

    final pos = await _locationService.getCurrentLocation();
    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    });

    // Start uploading location + listen to nearby users
    _locationService.startUpdatingLocation();
    _geoFireService.init();
    _geoFireService.queryNearby(pos.latitude, pos.longitude, 2.0).listen((map) {
      if (map != null) {
        final String? key = map['key'];
        final double? lat = map['latitude'];
        final double? lng = map['longitude'];
        final String? call = map['callBack'];

        if (call == Geofire.onKeyEntered) {
          setState(() {
            _markers.add(Marker(
              markerId: MarkerId(key!),
              position: LatLng(lat!, lng!),
              infoWindow: const InfoWindow(title: "Nearby User"),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ));
          });
        } else if (call == Geofire.onKeyExited) {
          setState(() {
            _markers.removeWhere((m) => m.markerId.value == key);
          });
        } else if (call == Geofire.onKeyMoved) {
          setState(() {
            _markers.removeWhere((m) => m.markerId.value == key);
            _markers.add(Marker(
              markerId: MarkerId(key!),
              position: LatLng(lat!, lng!),
              infoWindow: const InfoWindow(title: "Nearby User (moved)"),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ));
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RaahSetu - Live Map")),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 15,
        ),
        myLocationEnabled: true,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _emergencyService.triggerEmergency();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("🚨 Emergency Alert Sent!")),
          );
        },
        icon: const Icon(Icons.warning, color: Colors.white),
        label: const Text("HELP ME"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
