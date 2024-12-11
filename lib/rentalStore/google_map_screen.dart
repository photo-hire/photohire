import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
   late GoogleMapController _mapController;
  LatLng? _currentLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 2,
        ),
        onMapCreated: (controller) async {
          _mapController = controller;
          Position position = await _determinePosition();
          LatLng userLocation = LatLng(position.latitude, position.longitude);
          setState(() {
            _currentLocation = userLocation;
          });
          _mapController.animateCamera(
            CameraUpdate.newLatLng(userLocation),
          );
        },
        onTap: (LatLng location) {
          setState(() {
            _currentLocation = location;
          });
        },
        markers: _currentLocation != null
            ? {
                Marker(
                  markerId: MarkerId('selected-location'),
                  position: _currentLocation!,
                ),
              }
            : {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentLocation != null) {
            Navigator.pop(context, _currentLocation);
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

}