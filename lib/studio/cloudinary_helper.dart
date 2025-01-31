import 'dart:io';
import 'package:cloudinary/cloudinary.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryHelper {
  final String uploadUrl;
  final String uploadPreset;

  CloudinaryHelper({
    required this.uploadUrl,
    required this.uploadPreset,
  });

  Future<String> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse(uploadUrl),
      );
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return json.decode(responseData)['secure_url'];
      } else {
        throw Exception("Failed to upload image to Cloudinary");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}



Future<String> uploadImageToCloudinary(File image) async {
  // Your Cloudinary credentials
  final cloudinary = Cloudinary.signedConfig(
    apiKey: '976747581113527',
    apiSecret: 'hOJ8rFPYe6E0ILThBPHLulv4BE0',
    cloudName: 'darkzcjm0'
     // Replace with your Cloudinary API Secret
  );

  try {
    // Upload the image
    final response = await cloudinary.upload(
      file: image.path,
      resourceType: CloudinaryResourceType.image,
    );

    if (response.isSuccessful) {
      // Return the secure URL of the uploaded image
      return response.secureUrl!;
    } else {
      throw Exception('Image upload failed');
    }
  } catch (e) {
    print('Error uploading image: $e');
    throw Exception('Error uploading image');
  }
}
