import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static Future<void> initialize() async {
    // Use .env if available, otherwise fallback to constants (Safe for web clients if RLS is on)
    final url = dotenv.env['SUPABASE_URL'] ??
        'https://frsqtnmmhqvmcsvtjjbz.supabase.co';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZyc3F0bm1taHF2bWNzdnRqamJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk0MTk2NTEsImV4cCI6MjA4NDk5NTY1MX0.h2jePzp1AY6IPFAnHZJQi7uC-jAaogtUtbujIZHx9iY';

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
