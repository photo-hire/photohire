import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photohire/user/photographer_details_screen.dart';

class UserGoogleMapScreen extends StatefulWidget {
  UserGoogleMapScreen({super.key, required this.latlong, this.latlnglist});

  final LatLng latlong;
  final List<LatLng>? latlnglist;

  @override
  State<UserGoogleMapScreen> createState() => _UserGoogleMapScreenState();
}

class _UserGoogleMapScreenState extends State<UserGoogleMapScreen> {
  late GoogleMapController mapController;
  LatLng? _initialPosition;
  final Set<Marker> _markers = {};
  Map<String, dynamic>? selectedPhotographer;

  @override
  void initState() {
    _initialPosition = widget.latlong;
    super.initState();
    _addPhotographerMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _recenterMap() {
    mapController.animateCamera(CameraUpdate.newLatLng(_initialPosition!));
  }

  Future<void> _fetchPhotographerDetails(LatLng position) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('photgrapher')
        .where('latitude', isEqualTo: position.latitude)
        .where('longitude', isEqualTo: position.longitude)
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        selectedPhotographer = {
          'data': query.docs.first.data(),
          'id': query.docs.first.id
        } as Map<String, dynamic>;
      });

      _showBottomSheet();
    }
  }

  void _showBottomSheet() {
    if (selectedPhotographer == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                selectedPhotographer!['data']['company'] ?? 'Unknown Studio',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email, size: 20, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Text(
                    selectedPhotographer!['data']['email'] ??
                        'No email available',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 20, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    "Contact: ${selectedPhotographer!['data']['phone'] ?? 'N/A'}",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.attach_money,
                      size: 20, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    "Starting Price: ${selectedPhotographer!['data']['startingPrice'] ?? 'N/A'}",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotographerDetailsScreen(
                          studioDetails: selectedPhotographer!['data'],
                          pid: selectedPhotographer!['id'],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "View Details",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addPhotographerMarkers() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('photgrapher').get();

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('latitude') && data.containsKey('longitude')) {
        LatLng position = LatLng(data['latitude'], data['longitude']);

        _markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: position,
            infoWindow: InfoWindow(
              title: data['company'] ?? "Photographer",
              snippet: "Tap for details",
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            onTap: () => _fetchPhotographerDetails(position),
          ),
        );
      }
    }

    _addUserLocationMarker();
    setState(() {});
  }

  void _addUserLocationMarker() {
    _markers.add(
      Marker(
        markerId: const MarkerId('User_Location'),
        position: _initialPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "Your Location"),
      ),
    );
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
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _recenterMap,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
