import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://frsqtnmmhqvmcsvtjjbz.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_rxijMmTUNLtDauSBv5ik1w_8Tx056F0';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
