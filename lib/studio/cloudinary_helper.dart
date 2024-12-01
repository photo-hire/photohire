import 'dart:io';
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
