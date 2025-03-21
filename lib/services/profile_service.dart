import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../widgets/notification_banner.dart';

class UserProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch user profile by user ID
  Future<UserProfile?> getUserProfile(String userId, BuildContext context) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      showNotificationBanner(context, 'Failed to fetch profile.');
      return null;
    }
  }

  // Create a new user profile
  Future<void> createUserProfile(UserProfile profile, BuildContext context) async {
    try {
      await _supabase.from('user_profiles').insert(profile.toJson());
      showNotificationBanner(context, 'Profile created successfully!', isSuccess: true);
    } catch (error) {
      showNotificationBanner(context, 'Failed to create profile.');
    }
  }

  // Update existing user profile
  Future<void> updateUserProfile(UserProfile profile, BuildContext context) async {
    try {
      await _supabase
          .from('user_profiles')
          .update(profile.toJson())
          .eq('id', profile.id);

      showNotificationBanner(context, 'Profile updated successfully!', isSuccess: true);
    } catch (error) {
      showNotificationBanner(context, 'Failed to update profile.');
    }
  }
}