import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../services/geofire_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final GeoFireService _geoFireService = GeoFireService();
  final Completer<GoogleMapController> _controller = Completer();

  LatLng? _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool granted = await _locationService.requestPermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return;
    }

    // Start location updates to Firebase
    _locationService.startUpdatingLocation();

    // Get first location
    final pos = await _locationService.getCurrentLocation();
    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    });

    // Query nearby users (within 2 km)
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
    );
  }
}
