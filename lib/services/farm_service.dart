import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/farm.dart';
import '../widgets/notification_banner.dart';

class FarmService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch farm by farm ID
  Future<Farm?> getFarm(String farmId, BuildContext context) async {
    try {
      final response = await _supabase
          .from('farms')
          .select()
          .eq('id', farmId)
          .single();

      return Farm.fromJson(response);
    } catch (error) {
      showNotificationBanner(context, 'Failed to fetch farm details.');
      return null;
    }
  }

  // Create a new farm
  Future<void> createFarm(Farm farm, BuildContext context) async {
    try {
      await _supabase.from('farms').insert(farm.toJson());
      showNotificationBanner(context, 'Farm created successfully!', isSuccess: true);
    } catch (error) {
      showNotificationBanner(context, 'Failed to create farm.');
    }
  }

  // Update an existing farm
  Future<void> updateFarm(Farm farm, BuildContext context) async {
    try {
      await _supabase
          .from('farms')
          .update(farm.toJson())
          .eq('id', farm.id);

      showNotificationBanner(context, 'Farm updated successfully!', isSuccess: true);
    } catch (error) {
      showNotificationBanner(context, 'Failed to update farm.');
    }
  }
}