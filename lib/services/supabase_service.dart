import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    // Hardcoded credentials for debugging Web Crash (Z9 error workaround)
    const url = 'https://frsqtnmmhqvmcsvtjjbz.supabase.co';
    const anonKey =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZyc3F0bm1taHF2bWNzdnRqamJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk0MTk2NTEsImV4cCI6MjA4NDk5NTY1MX0.h2jePzp1AY6IPFAnHZJQi7uC-jAaogtUtbujIZHx9iY';

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: true, // Enable debug mode
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
