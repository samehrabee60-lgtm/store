import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class StorageService {
  final SupabaseClient _client = SupabaseService.client;
  final String _bucketName = 'products'; // Must ensure this bucket exists

  // Upload generic file (image or pdf)
  Future<String?> uploadFile({
    required dynamic file,
    required String bucketName,
    required String fileExtension,
    required String contentType,
  }) async {
    try {
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      String path = fileName;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        await _client.storage.from(bucketName).uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(contentType: contentType, upsert: true),
            );
      } else {
        await _client.storage.from(bucketName).upload(
              path,
              file,
              fileOptions: FileOptions(contentType: contentType, upsert: true),
            );
      }

      final String publicUrl =
          _client.storage.from(bucketName).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('DEBUG: Error in uploadFile: $e');
      rethrow;
    }
  }

  // Backward compatibility alias if needed, or update usage
  Future<String?> uploadImage(dynamic file) async {
    return uploadFile(
      file: file,
      bucketName: _bucketName,
      fileExtension: 'jpg',
      contentType: 'image/jpeg',
    );
  }
}
