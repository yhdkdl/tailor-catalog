import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';

class CloudinaryUploadResult {
  const CloudinaryUploadResult({
    required this.publicId,
    required this.secureUrl,
  });

  final String publicId;
  final String secureUrl;
}

abstract interface class CloudinaryService {
  Future<CloudinaryUploadResult> uploadImage({
    required Uint8List imageBytes,
    required String filename,
    required String authUid,
    required String designId,
  });
}

class HttpCloudinaryService implements CloudinaryService {
  const HttpCloudinaryService({this.client});

  final http.Client? client;

  @override
  Future<CloudinaryUploadResult> uploadImage({
    required Uint8List imageBytes,
    required String filename,
    required String authUid,
    required String designId,
  }) async {
    final cloudName = AppConfig.cloudinaryCloudName;
    final uploadPreset = AppConfig.cloudinaryUploadPreset.trim();

    if (cloudName.isEmpty) {
      throw Exception('Cloudinary cloud name is not configured.');
    }

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = uploadPreset;
    request.fields['folder'] = 'tailor-designs/$authUid/$designId';

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: filename.isNotEmpty ? filename : 'design_photo.jpg',
    );
    request.files.add(multipartFile);

    final httpClient = client ?? http.Client();
    try {
      final streamedResponse = await httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final publicId = data['public_id'] as String? ?? '';
        final secureUrl = data['secure_url'] as String? ?? '';
        return CloudinaryUploadResult(publicId: publicId, secureUrl: secureUrl);
      } else {
        final body = response.body;
        throw Exception('Cloudinary upload failed (${response.statusCode}): $body');
      }
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }
}
