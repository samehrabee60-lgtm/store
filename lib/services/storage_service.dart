import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class StorageService {
  final SupabaseClient _client = SupabaseService.client;
  final String _bucketName = 'products'; // Must ensure this bucket exists

  // Upload image
  Future<String?> uploadImage(dynamic file) async {
    // debugPrint('DEBUG: Starting uploadImage (Supabase)...');
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      String path = fileName; // Path inside the bucket

      if (kIsWeb) {
        // debugPrint('DEBUG: Reading file as bytes for Web...');
        final bytes = await file.readAsBytes();
        // debugPrint('DEBUG: Read ${bytes.length} bytes. uploading...');

        await _client.storage.from(_bucketName).uploadBinary(
              path,
              bytes,
              fileOptions:
                  const FileOptions(contentType: 'image/jpeg', upsert: true),
            );
      } else {
        // debugPrint('DEBUG: Uploading file for Mobile/Desktop...');
        await _client.storage.from(_bucketName).upload(
              path,
              file,
              fileOptions:
                  const FileOptions(contentType: 'image/jpeg', upsert: true),
            );
      }

      // debugPrint('DEBUG: Upload complete. Getting public URL...');
      final String publicUrl =
          _client.storage.from(_bucketName).getPublicUrl(path);
      // debugPrint('DEBUG: Got public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('DEBUG: Error in uploadImage: $e');
      rethrow;
    }
  }
}
