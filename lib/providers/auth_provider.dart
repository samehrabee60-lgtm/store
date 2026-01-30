import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _role;
  bool _isLoading = true;

  User? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;

  bool get isAdmin => _role == 'admin';

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _user = _authService.currentUser;
    if (_user != null) {
      await _fetchRole();
    }
    _isLoading = false;
    notifyListeners();

    // Listen to auth changes
    _authService.authStateChanges.listen((AuthState state) async {
      final previousUser = _user;
      _user = state.session?.user;

      if (_user != null && (_user?.id != previousUser?.id)) {
        await _fetchRole();
      } else if (_user == null) {
        _role = null;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _fetchRole() async {
    if (_user == null) return;
    try {
      _role = await _authService.getUserRole(_user!.id);
      // Fallback/Legacy check (remove later)
      if (_role == null && _user!.email == 'sameh.rabee007@gmail.com') {
        _role = 'admin';
      }
    } catch (e) {
      debugPrint('Error fetching role: $e');
      _role = 'client';
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithEmail(email, password);
      // _init listener will handle the rest
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Let UI handle error
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.registerUser(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _role = null;
    notifyListeners();
  }
}
