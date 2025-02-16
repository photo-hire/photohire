import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserGoogleMapScreen extends StatefulWidget {
   UserGoogleMapScreen({super.key, required this.latlong,this.latlnglist});


  final LatLng latlong;

  List<LatLng> ? latlnglist;

  @override
  State<UserGoogleMapScreen> createState() => _UserGoogleMapScreenState();
}

class _UserGoogleMapScreenState extends State<UserGoogleMapScreen> {
  late GoogleMapController mapController;
  
  // Initial position (centered on a general location)
   LatLng ? _initialPosition;

  // Set of markers
  final Set<Marker> _markers = {};

  @override
  void initState() {
    _initialPosition = widget.latlong;

    print(_initialPosition);
    super.initState();
    _addExampleMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Adding Example Locations
  void _addExampleMarkers() {
    List<LatLng> exampleLocations = [
     
      widget.latlong,
       ...widget.latlnglist!,
        // Paris
    ];

    for (int i = 0; i < exampleLocations.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('Location_$i'),
          position: exampleLocations[i],
          infoWindow: InfoWindow(
            title: "Location ${i + 1}",
            snippet: "Lat: ${exampleLocations[i].latitude}, Lng: ${exampleLocations[i].longitude}",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Locations")),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition!,
          zoom: 11.0,
        ),
        markers: _markers,
      ),
    );
  }
}
