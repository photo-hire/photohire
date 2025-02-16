import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Future<void> sendNotificationToDevice(String title, String body) async {
  const String oneSignalRestApiKey =
      'os_v2_app_mfyhj42elbd5febwakisecemgp74msqtewwerdm4qsavnp7ulpn6giak7zt6s7hwkont5vm37odjworsa4xtrzps4g6v5s36lnu7n3q';
  const String oneSignalAppId = '617074f3-4458-47d2-9036-029122088c33';

  var playId = [];

  final addedData = await FirebaseFirestore.instance
      .collection('contact')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

      print('--------------------');

      print(addedData);


  
  final addedContacts = addedData.data();

  if(addedContacts==null){
    return;
  }
  
  
  final contactList = addedContacts['contactList'] as List<dynamic>;

  

  // Iterate over the contactList
  for (var contact in contactList) {
    if (contact is Map<String, dynamic>) {
      playId.add(contact['playerId']);
    }
  }

  // Get the current position
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  // Use the position data in your notification
  var url = Uri.parse('https://api.onesignal.com/notifications?c=push');
  var notificationData = {
    "app_id": oneSignalAppId,
    "headings": {"en": title},
    "contents": {"en": body},
    "target_channel": "push",
    "include_player_ids": playId,
    "url": generateNearbyPoliceStationsUrl(startLat:position.latitude,startLng: position.longitude ), // Optionally, you can include a URL
    "data": {
      "latitude": position.latitude,
      "longitude": position.longitude,
    }
  };

  var headers = {
    "Content-Type": "application/json; charset=utf-8",
    "Authorization": "Basic $oneSignalRestApiKey",
  };

  try {
    var response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(notificationData),
    );
    if (response.statusCode == 200) {
      print("Notification Sent Successfully!");
      print(response.body);
    } else {
      print("Failed to send notification: ${response.statusCode}");
    }
  } catch (e) {
    print("Error sending notification: $e");
  }
}


String generateNearbyPoliceStationsUrl({
  required double startLat,
  required double startLng,
}) {
 final  link = 'https://www.google.com/maps/search/?api=1'
      '&query=Police+Station&location=$startLat,$startLng';


      return link;
}
