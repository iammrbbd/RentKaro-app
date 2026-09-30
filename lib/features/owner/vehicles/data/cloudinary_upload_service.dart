import 'dart:io';

import 'package:dio/dio.dart';

class CloudinaryUploadService {
  CloudinaryUploadService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  // ============================================================
  // CLOUDINARY CONFIGURATION
  // ============================================================

  static const String cloudName = 'dadjouvur';
  static const String uploadPreset = 'RentKaro';

  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  // ============================================================
  // UPLOAD SINGLE IMAGE
  // ============================================================

  Future<String> uploadImage({
    required File file,
    required String folder,
    String? publicId,
  }) async {
    // Check whether Cloudinary configuration is present.
    if (cloudName == 'YOUR_CLOUD_NAME' ||
        uploadPreset == 'YOUR_UPLOAD_PRESET') {
      throw Exception(
        'Cloudinary is not configured. '
            'Please add Cloud Name and Upload Preset.',
      );
    }

    // Check selected file.
    if (!await file.exists()) {
      throw Exception('Selected image file was not found.');
    }

    try {
      final fileName = file.path.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'upload_preset': uploadPreset,
        'folder': folder,
        if (publicId != null && publicId.trim().isNotEmpty)
          'public_id': publicId.trim(),
      });

      final response = await _dio.post(
        _uploadUrl,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception(
          'Invalid response received from Cloudinary.',
        );
      }

      final secureUrl = data['secure_url']?.toString();

      if (secureUrl == null || secureUrl.trim().isEmpty) {
        throw Exception(
          'Cloudinary uploaded the image but no URL was returned.',
        );
      }

      return secureUrl;
    } on DioException catch (error) {
      final responseData = error.response?.data;

      if (responseData is Map) {
        final errorData = responseData['error'];

        if (errorData is Map &&
            errorData['message'] != null) {
          throw Exception(
            'Cloudinary: ${errorData['message']}',
          );
        }

        if (errorData != null) {
          throw Exception(
            'Cloudinary: $errorData',
          );
        }
      }

      throw Exception(
        'Unable to upload image to Cloudinary.',
      );
    }
  }

  // ============================================================
  // UPLOAD MULTIPLE IMAGES
  // ============================================================

  Future<List<String>> uploadImages({
    required List<File> files,
    required String folder,
  }) async {
    if (files.isEmpty) {
      return [];
    }

    final uploadedUrls = <String>[];

    for (final file in files) {
      final url = await uploadImage(
        file: file,
        folder: folder,
      );

      uploadedUrls.add(url);
    }

    return uploadedUrls;
  }
}