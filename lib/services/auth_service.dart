import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  final GoTrueClient _auth = SupabaseService.client.auth;
  final SupabaseClient _client = SupabaseService.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Register with email, password, and additional details
  Future<AuthResponse> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // Create user in Supabase Auth
      AuthResponse response = await _auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
          'role': 'client',
        },
      );

      // Save user details in 'profiles' table (optional if handled by triggers)
      // Here we explicitly insert it to ensure it exists
      if (response.user != null) {
        await _client.from('profiles').insert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'phone': phone,
          'role': 'client',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Verify Phone Number (Supabase uses OTP)
  // This is a placeholder as Supabase verify works differently (signInWithOtp)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(dynamic) onVerificationFailed,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.signInWithOtp(phone: phoneNumber);
      // Simulate code sent for existing UI compatibility
      // In reality, Supabase just sends the SMS.
      onCodeSent('dummy_verification_id', null);
    } catch (e) {
      onVerificationFailed(e);
    }
  }

  // Register User with Phone Verification and Email/Password
  // Adapting to Supabase: Link email/password to phone user or just update profile
  Future<AuthResponse?> registerUserWithPhoneAndEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // 1. Verify Phone OTP
      AuthResponse phoneResponse = await _auth.verifyOTP(
        type: OtpType.sms,
        token: smsCode,
        phone: phone,
      );

      if (phoneResponse.user != null) {
        // 2. Update user with email and password
        await _auth.updateUser(
          UserAttributes(
            email: email,
            password: password,
            data: {
              'name': name,
              'phone': phone,
              'role': 'client',
            },
          ),
        );

        // 3. Create Profile
        await _client.from('profiles').upsert({
          'id': phoneResponse.user!.id,
          'name': name,
          'email': email,
          'phone': phone,
          'role': 'client',
          'created_at': DateTime.now().toIso8601String(),
        });
        
        return phoneResponse;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Supabase allows password update directly if logged in
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;
}
