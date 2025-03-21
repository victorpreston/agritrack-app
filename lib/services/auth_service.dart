import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/notification_banner.dart';
import '../models/user_profile.dart';
import '../screens/profile_onboarding_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';

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

      // Check if user profile exists
      final hasProfile = await _checkUserProfile(response.user!.id);
      if (hasProfile) {
        // Navigate to Dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        // Navigate to Profile Onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }

      return response; // Return response so it can be used in `login_screen.dart`
    } on AuthException catch (e) {
      _handleAuthError(context, e);
      return null;
    } catch (e) {
      showNotificationBanner(context, 'An unexpected error occurred. Try again.');
      return null;
    }
  }

  // Check if user has a profile
  Future<bool> _checkUserProfile(String userId) async {
    final response = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response != null;
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