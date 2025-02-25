import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photohire/user/photographer_details_screen.dart';

class UserGoogleMapScreen extends StatefulWidget {
  UserGoogleMapScreen({super.key, required this.latlong, this.latlnglist});

  final LatLng latlong;
  List<LatLng>? latlnglist;

  @override
  State<UserGoogleMapScreen> createState() => _UserGoogleMapScreenState();
}

class _UserGoogleMapScreenState extends State<UserGoogleMapScreen> {
  late GoogleMapController mapController;
  LatLng? _initialPosition;
  final Set<Marker> _markers = {};
  Map<String, dynamic>? selectedPhotographer; // Store photographer details

  @override
  void initState() {
    _initialPosition = widget.latlong;
    super.initState();
    _addExampleMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Fetch photographer details from Firestore
  Future<void> _fetchPhotographerDetails(LatLng position) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('photgrapher')
        .where('latitude', isEqualTo: position.latitude)
        .where('longitude', isEqualTo: position.longitude)
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        selectedPhotographer = {'data': query.docs.first.data(), 'id': query.docs.first.id} as Map<String, dynamic>;
      });

      _showBottomSheet();
    }
  }

  // Show Bottom Sheet with Photographer Details
  void _showBottomSheet() {
    if (selectedPhotographer == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 200,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Text(
                selectedPhotographer!['data']['company'] ?? 'Unknown',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(selectedPhotographer!['data']['email'] ?? 'No details available'),
              const SizedBox(height: 8),
              Text("Contact: ${selectedPhotographer!['data']['phone'] ?? 'N/A'}"),
              SizedBox(height: 8),
              Text("Price: ${selectedPhotographer!['data']['startingPrice'] ?? 'N/A'}"),
              SizedBox(height: 8),


              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PhotographerDetailsScreen(studioDetails: selectedPhotographer!['data'],pid: selectedPhotographer!['id'],),));// Close the bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 68, 118),
                  ),
                  child: const Text("Book now",style: TextStyle(color: Colors.white),),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Adding Markers
  void _addExampleMarkers() {
    List<LatLng> exampleLocations = [
      widget.latlong,
      ...widget.latlnglist!,
    ];

    for (int i = 0; i < exampleLocations.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('Location_$i'),
          position: exampleLocations[i],
          infoWindow: InfoWindow(
            title: "Location ${i + 1}",
            snippet: "Tap for details",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          onTap: () => _fetchPhotographerDetails(exampleLocations[i]), // Fetch details on tap
        ),
      );
    }

    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Photographers Map")),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition!,
              zoom: 11.0,
            ),
            markers: _markers,
          ),
        ],
      ),
    );
  }
}
