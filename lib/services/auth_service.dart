import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/notification_banner.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Restore session when app starts**
  Future<bool> restoreSession() async {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  // Sign up with email and password
  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      showNotificationBanner(context, 'Account created! Please verify your email.', isSuccess: true);
      return response;
    } on AuthException catch (e) {
      _handleAuthError(context, e);
      return null;
    } catch (e) {
      showNotificationBanner(context, 'An unexpected error occurred. Try again.');
      return null;
    }
  }

  // Sign in with email and password
  Future<AuthResponse?> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        showNotificationBanner(context, 'Invalid credentials. Try again.');
        return null;
      }

      showNotificationBanner(context, 'Login successful!', isSuccess: true);
      return response;
    } on AuthException catch (e) {
      _handleAuthError(context, e);
      return null;
    } catch (e) {
      showNotificationBanner(context, 'An unexpected error occurred. Try again.');
      return null;
    }
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    await _supabase.auth.signOut();
    showNotificationBanner(context, 'Logged out successfully.', isSuccess: true);
  }

  // Handle specific authentication errors
  void _handleAuthError(BuildContext context, AuthException e) {
    String message;

    if (e.message.contains('invalid login credentials')) {
      message = 'Invalid email or password.';
    } else if (e.message.contains('email not confirmed')) {
      message = 'Please verify your email before logging in.';
    } else {
      message = 'Authentication failed. Try again.';
    }

    showNotificationBanner(context, message);
  }
}

// Helper function to show notification banner
void showNotificationBanner(BuildContext context, String message, {bool isSuccess = false}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => NotificationBanner(message: message, isSuccess: isSuccess),
  );

  overlay.insert(overlayEntry);
  Future.delayed(const Duration(seconds: 3), overlayEntry.remove);
}