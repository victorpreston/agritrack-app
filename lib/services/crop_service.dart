import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/crop.dart';
import '../widgets/notification_banner.dart';

class CropService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all crops for a specific farm
  Future<List<Crop>> getCropsByFarm(String farmId, BuildContext context) async {
    try {
      final response = await _supabase
          .from('crops')
          .select()
          .eq('farm_id', farmId);

      return response.map<Crop>((json) => Crop.fromJson(json)).toList();
    } catch (error) {
      showNotificationBanner(context, 'Failed to fetch crops.');
      return [];
    }
  }

  // Add a new crop
  Future<void> addCrop(Crop crop, BuildContext context) async {
    try {
      await _supabase.from('crops').insert(crop.toJson());
      showNotificationBanner(context, 'Crop added successfully!', isSuccess: true);
    } catch (error) {
      showNotificationBanner(context, 'Failed to add crop.');
    }
  }

  // Update an existing crop
  Future<void> updateCrop(Crop crop, BuildContext context) async {
    try {
      await _supabase
          .from('crops')
          .update(crop.toJson())
          .eq('id', crop.id);

      showNotificationBanner(context, 'Crop updated successfully!', isSuccess: true);
    } catch (error) {
      showNotificationBanner(context, 'Failed to update crop.');
    }
  }
}