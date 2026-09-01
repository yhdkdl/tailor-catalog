import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';

class QrService {
  const QrService({this.client});

  final SupabaseClient? client;

  static String buildCatalogUrl(String shopSlug) {
    // If supabase URL is configured, link to public web domain
    return 'https://tailor-catalog.vercel.app/$shopSlug';
  }

  static String getQrStoragePath(String authUid, String shopSlug) {
    return '$authUid/$shopSlug-qr.png';
  }

  Future<String?> uploadQrCode({
    required Uint8List pngBytes,
    required String authUid,
    required String shopSlug,
  }) async {
    final supabase = client ?? (AppConfig.hasSupabase ? Supabase.instance.client : null);
    if (supabase == null) return null;

    final path = getQrStoragePath(authUid, shopSlug);
    try {
      await supabase.storage.from('qr-codes').uploadBinary(
            path,
            pngBytes,
            fileOptions: const FileOptions(
              contentType: 'image/png',
              upsert: true,
            ),
          );
      return supabase.storage.from('qr-codes').getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }
}
