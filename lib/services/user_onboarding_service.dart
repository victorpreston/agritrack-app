import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/farm.dart';
import '../models/crop.dart';
import '../widgets/notification_banner.dart';

class ProfileSetupService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> completeProfile({
    required UserProfile userProfile,
    required Farm farm,
    required List<Crop> crops,
    required BuildContext context,
  }) async {
    try {
      print('PROFILE SETUP: Starting profile setup process');

      // Verify authentication status
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('ERROR: User not authenticated');
        showNotificationBanner(context, 'User not authenticated. Please log in again.');
        return false;
      }

      print('PROFILE SETUP: User authenticated as ${user.id}');

      // Make sure the ID matches the authenticated user and include email and name from auth
      if (userProfile.id != user.id) {
        userProfile = UserProfile(
          id: user.id,
          fullName: userProfile.fullName,
          email: userProfile.email,
          phone: userProfile.phone,
          profilePicture: userProfile.profilePicture,
          memberSince: userProfile.memberSince,
          subscription: userProfile.subscription,
          farmId: userProfile.farmId,
        );
      }

      // STEP 1: Create/update the user profile FIRST (without farm ID for now)
      print('PROFILE SETUP: Saving initial user profile');
      final initialUserProfileData = userProfile.toJson();
      // Temporarily remove farmId if it's empty
      if (initialUserProfileData.containsKey('farm_id') &&
          (initialUserProfileData['farm_id'] == null || initialUserProfileData['farm_id'].isEmpty)) {
        initialUserProfileData.remove('farm_id');
      }

      print('Initial user profile data: $initialUserProfileData');

      // Create/update user profile
      await _supabase.from('user_profiles').upsert(initialUserProfileData);
      print('PROFILE SETUP: Initial user profile saved');

      // STEP 2: Now create the farm (owner_id should now be valid)
      print('PROFILE SETUP: Saving farm details');
      final farmData = Farm(
        id: '',
        name: farm.name,
        location: farm.location,
        totalArea: farm.totalArea,
        ownerId: user.id,
      ).toJson();

      print('Farm data: $farmData');
      final farmResponse = await _supabase.from('farms').insert(farmData).select();

      if (farmResponse.isEmpty) {
        print('ERROR: Failed to save farm details - empty response');
        showNotificationBanner(context, 'Failed to save farm details.');
        return false;
      }

      // Get the farm ID assigned by the database
      final String farmId = farmResponse[0]['id'];
      print('PROFILE SETUP: Farm saved with ID: $farmId');

      // STEP 3: Update user profile with the new farm ID
      final updatedUserProfile = UserProfile(
        id: user.id,
        fullName: userProfile.fullName,
        email: userProfile.email,
        phone: userProfile.phone,
        profilePicture: userProfile.profilePicture,
        memberSince: userProfile.memberSince,
        subscription: userProfile.subscription,
        farmId: farmId,
      );

      print('PROFILE SETUP: Updating user profile with farm ID');
      print('Updated user profile data: ${updatedUserProfile.toJson()}');
      final userResponse = await _supabase.from('user_profiles').upsert(updatedUserProfile.toJson()).select();

      if (userResponse.isEmpty) {
        print('ERROR: Failed to update user profile with farm ID - empty response');
        showNotificationBanner(context, 'Failed to update profile with farm details.');
        return false;
      }

      print('PROFILE SETUP: User profile updated with farm ID');

      // STEP 4: Insert crops with farm ID
      print('PROFILE SETUP: Saving ${crops.length} crops');
      for (var i = 0; i < crops.length; i++) {
        final cropData = Crop(
          id: '',
          name: crops[i].name,
          farmId: farmId,
          type: crops[i].type,
        ).toJson();

        print('Crop data ${i+1}: $cropData');
        await _supabase.from('crops').insert(cropData);
      }

      print('PROFILE SETUP: All crops saved successfully');

      return true;
    } catch (error) {
      print('ERROR IN PROFILE SETUP:');
      print('Error type: ${error.runtimeType}');
      print('Error details: $error');

      if (error is PostgrestException) {
        print('Postgrest error code: ${error.code}');
        print('Postgrest error message: ${error.message}');
        print('Postgrest error details: ${error.details}');
      }

      // Provide a more user-friendly error message
      String errorMessage = 'Profile setup failed.';
      if (error is PostgrestException) {
        if (error.code == '42501') {
          errorMessage = 'Permission denied. Please log out and log in again.';
        } else if (error.code == '23503') {
          errorMessage = 'Database relationship error. Please try again or contact support.';
        }
      }

      showNotificationBanner(context, errorMessage);
      return false;
    }
  }
}