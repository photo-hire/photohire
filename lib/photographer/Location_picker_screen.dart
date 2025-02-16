import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerScreen extends StatefulWidget {
  final Function(double, double) onLocationSelected;
  final double latitude;
  final double longitude;

  const LocationPickerScreen({Key? key, required this.onLocationSelected, required this.latitude, required this.longitude})
      : super(key: key);

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;
  String? _selectedAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              if (_selectedLocation != null) {
                // Convert coordinates to address
                List<Placemark> placemarks = await placemarkFromCoordinates(
                  _selectedLocation!.latitude,
                  _selectedLocation!.longitude,
                );

                if (placemarks.isNotEmpty) {
                  Placemark place = placemarks.first;
                  setState(() {
                    _selectedAddress =
                        "${place.street}, ${place.locality}, ${place.country}";
                  });

                  // Return the selected location to the previous screen
                  widget.onLocationSelected(
                    _selectedLocation!.latitude,
                    _selectedLocation!.longitude,
                  );
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.latitude, widget.longitude,), // Default location
              zoom: 10,
            ),
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
            onTap: (LatLng location) {
              setState(() {
                _selectedLocation = location;
              });
            },
            markers: _selectedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: MarkerId('selectedLocation'),
                      position: _selectedLocation!,
                    ),
                  },
          ),
          if (_selectedAddress != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  _selectedAddress!,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}