import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static Future<void> initialize() async {
    // Use .env if available, otherwise fallback to constants (Safe for web clients if RLS is on)
    final url = dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL_FALLBACK';
    final anonKey =
        dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY_FALLBACK';

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
